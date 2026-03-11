import AppKit
import SwiftUI

@MainActor
final class StreakNudgeController {
    static let shared = StreakNudgeController()

    private let panel: NSPanel
    private let nudgeState = NudgeState()
    private var isVisible = false
    private var dismissWork: DispatchWorkItem?
    private var globalMonitor: Any?

    private static let shownTodayKey = "nudgeLastShownDate"

    private init() {
        panel = NSPanel()
        panel.styleMask         = [.borderless, .nonactivatingPanel]
        panel.isOpaque          = false
        panel.backgroundColor   = .clear
        panel.level             = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.statusWindow)) + 1)
        panel.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle, .fullScreenAuxiliary]
        panel.hasShadow         = false   // SwiftUI view draws its own shadow
        panel.isMovableByWindowBackground = false

        let view = StreakNudgeView(
            state:      nudgeState,
            onDismiss:  { [weak self] in Task { @MainActor [weak self] in self?.hide() } },
            onOpenMain: { NotchPanelController.shared.show() }
        )
        panel.contentView = NSHostingView(rootView: view)
    }

    // MARK: - Public API

    /// Shows the nudge if the streak is at risk and it hasn't been shown today.
    func showIfNeeded() {
        let vm = ContributionViewModel.shared
        guard vm.streakAtRisk else { return }

        let today = isoToday()
        if UserDefaults.standard.string(forKey: Self.shownTodayKey) == today { return }
        UserDefaults.standard.set(today, forKey: Self.shownTodayKey)

        show(streak: vm.currentStreak)
    }

    /// Force-shows the nudge regardless of "shown today" gate.
    func show(streak: Int) {
        guard !isVisible else { return }

        nudgeState.streak     = streak
        nudgeState.isExpanded = false

        positionPanel()
        panel.alphaValue = 0
        panel.orderFrontRegardless()
        isVisible = true

        // Fade the panel in while the island is still a pill
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.12
            ctx.timingFunction = CAMediaTimingFunction(name: .easeOut)
            panel.animator().alphaValue = 1
        }

        // Expand to full card slightly after panel appears
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            withAnimation { self?.nudgeState.isExpanded = true }
        }

        // Auto-dismiss after 7 seconds
        scheduleDismiss(after: 7)
        installGlobalMonitor()
    }

    func hide() {
        guard isVisible else { return }
        dismissWork?.cancel()
        dismissWork = nil
        removeGlobalMonitor()

        // Shrink back to pill first
        withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
            nudgeState.isExpanded = false
        }

        // Then fade panel out after the shrink completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.38) { [weak self] in
            guard let self, self.isVisible else { return }
            NSAnimationContext.runAnimationGroup { ctx in
                ctx.duration = 0.12
                ctx.timingFunction = CAMediaTimingFunction(name: .easeIn)
                self.panel.animator().alphaValue = 0
            } completionHandler: { [weak self] in
                Task { @MainActor [weak self] in
                    self?.panel.orderOut(nil)
                    self?.isVisible = false
                }
            }
        }
    }

    // MARK: - Positioning

    private func positionPanel() {
        // The view's outer frame is (cardW + 20) × (cardH + 10)
        // We position the panel so its top edge is flush with the screen top,
        // centred on the notch. This makes the pill at the top of the view
        // appear to "live in" the notch.
        let viewW: CGFloat = 360   // cardW + 20
        let viewH: CGFloat = 138   // cardH + 10

        let screen     = NotchPositionDetector.notchScreen
        let centerX    = NotchPositionDetector.notchCenterX
        let screenTop  = NotchPositionDetector.screenTop
        let screenMinX = screen.frame.minX
        let screenMaxX = screen.frame.maxX

        let x = max(screenMinX + 8, min(centerX - viewW / 2, screenMaxX - viewW - 8))
        let y = screenTop - viewH   // top of panel == top of screen

        panel.setFrame(NSRect(x: x, y: y, width: viewW, height: viewH), display: false)
    }

    // MARK: - Helpers

    private func scheduleDismiss(after seconds: Double) {
        dismissWork?.cancel()
        let work = DispatchWorkItem { [weak self] in
            Task { @MainActor [weak self] in self?.hide() }
        }
        dismissWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: work)
    }

    private func installGlobalMonitor() {
        guard globalMonitor == nil else { return }
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                if !self.panel.frame.contains(NSEvent.mouseLocation) {
                    self.hide()
                }
            }
        }
    }

    private func removeGlobalMonitor() {
        if let m = globalMonitor { NSEvent.removeMonitor(m); globalMonitor = nil }
    }

    private func isoToday() -> String {
        let df = DateFormatter(); df.dateFormat = "yyyy-MM-dd"; return df.string(from: Date())
    }
}
