import AppKit
import SwiftUI

@MainActor
final class NotchPanelController {
    static let shared = NotchPanelController()

    private let panel: NotchPanel
    private var isVisible = false
    private var globalMonitor: Any?
    private var hoverMonitor: Any?
    private var hoverTask: Task<Void, Never>?

    private init() {
        panel = NotchPanel()
        let content = ContentView()
        let hosting = NSHostingView(rootView: content)
        hosting.translatesAutoresizingMaskIntoConstraints = false
        hosting.wantsLayer = true
        hosting.layer?.backgroundColor = .clear
        hosting.layer?.borderWidth = 0
        panel.contentView = hosting

        // Register for screen changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenDidChange),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )

        installHoverMonitor()
    }

    func toggle() {
        if isVisible { hide() } else { show() }
    }

    func show() {
        guard !isVisible else { return }
        // Bump ID so ContributionGridView recreates and re-runs its entrance animation
        ContributionViewModel.shared.displayRevisionID = UUID()
        positionPanel()
        panel.alphaValue = 0
        panel.orderFrontRegardless()
        isVisible = true
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.22
            ctx.timingFunction = CAMediaTimingFunction(name: .easeOut)
            panel.animator().alphaValue = 1
        }
        installGlobalMonitor()
    }

    func hide() {
        guard isVisible else { return }
        isVisible = false
        removeGlobalMonitor()
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.15
            ctx.timingFunction = CAMediaTimingFunction(name: .easeIn)
            panel.animator().alphaValue = 0
        } completionHandler: { [weak self] in
            Task { @MainActor [weak self] in
                self?.panel.orderOut(nil)
            }
        }
    }

    private func positionPanel() {
        // Size the hosting view to fit content
        panel.contentView?.layoutSubtreeIfNeeded()
        let fittingSize = panel.contentView?.fittingSize ?? NSSize(width: 370, height: 220)
        let panelWidth  = max(fittingSize.width, 370)
        let panelHeight = max(fittingSize.height, 160)

        let screenTop   = NotchPositionDetector.screenTop
        let centerX     = NotchPositionDetector.notchCenterX
        let screenFrame = NotchPositionDetector.screenFrame

        let x = max(screenFrame.minX + 8.0, min(centerX - panelWidth / 2.0, screenFrame.maxX - panelWidth - 8.0))
        // Panel top at screenTop — the notch (hardware cutout) hides the top portion naturally.
        // Content inside has top padding = notchHeight so it starts below the notch.
        let y = screenTop - panelHeight

        panel.setFrame(NSRect(x: x, y: y, width: panelWidth, height: panelHeight), display: false)
    }

    @objc private func screenDidChange() {
        if isVisible { positionPanel() }
    }

    private func installGlobalMonitor() {
        guard globalMonitor == nil else { return }
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            guard let self else { return }
            Task { @MainActor in
                // NSEvent.mouseLocation is in screen coordinates
                let screenLoc = NSEvent.mouseLocation
                if !self.panel.frame.contains(screenLoc) {
                    self.hide()
                }
            }
        }
    }

    private func removeGlobalMonitor() {
        if let monitor = globalMonitor {
            NSEvent.removeMonitor(monitor)
            globalMonitor = nil
        }
    }

    // MARK: - Hover-to-open

    private func installHoverMonitor() {
        hoverMonitor = NSEvent.addGlobalMonitorForEvents(matching: .mouseMoved) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }

                let loc = NSEvent.mouseLocation

                // If panel is open, dismiss when mouse strays outside the panel bounds
                if self.isVisible {
                    let expanded = self.panel.frame.insetBy(dx: -24, dy: -24)
                    if !expanded.contains(loc) {
                        self.hide()
                    }
                    return
                }

                let screenTop = NotchPositionDetector.screenTop
                let centerX   = NotchPositionDetector.notchCenterX
                let notchH    = NotchPositionDetector.notchHeight

                let nearTop    = loc.y >= screenTop - notchH - 6
                let nearCenter = abs(loc.x - centerX) < 90

                if nearTop && nearCenter {
                    self.hoverTask?.cancel()
                    self.hoverTask = Task { @MainActor [weak self] in
                        try? await Task.sleep(for: .milliseconds(150))
                        guard !Task.isCancelled else { return }
                        self?.show()
                    }
                } else {
                    self.hoverTask?.cancel()
                }
            }
        }
    }
}
