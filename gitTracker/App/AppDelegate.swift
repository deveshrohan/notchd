import AppKit
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!

    func applicationDidFinishLaunching(_ notification: Notification) {
        // No Dock icon
        NSApp.setActivationPolicy(.accessory)

        // Create menu bar status item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "square.grid.3x3.fill",
                                   accessibilityDescription: "gitTracker")
            button.image?.isTemplate = true
            button.target = self
            button.action = #selector(statusButtonClicked(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        // Initialize the shared controllers
        _ = NotchPanelController.shared
        _ = StreakNudgeController.shared

        // Show streak nudge once data is available
        observeContributionsForNudge()
    }

    private var nudgeObserver: NSObjectProtocol?

    private func observeContributionsForNudge() {
        // Poll until data is loaded, then evaluate nudge (max ~10s)
        var attempts = 0
        func check() {
            let vm = ContributionViewModel.shared
            if !vm.weeks.isEmpty {
                // Small delay so the user settles in before the nudge appears
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    StreakNudgeController.shared.showIfNeeded()
                }
            } else if attempts < 20 {
                attempts += 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: check)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: check)
    }

    @objc private func statusButtonClicked(_ sender: NSStatusBarButton) {
        NotchPanelController.shared.toggle()
    }
}
