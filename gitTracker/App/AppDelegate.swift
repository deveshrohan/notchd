import AppKit
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var fallbackMenu: NSMenu!

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "square.grid.3x3.fill",
                                   accessibilityDescription: "Notchd")
            button.image?.isTemplate = true
            button.target = self
            button.action = #selector(statusButtonClicked(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        // Right-click fallback menu
        fallbackMenu = NSMenu()
        fallbackMenu.addItem(withTitle: "Open Notchd",    action: #selector(openPanel),                        keyEquivalent: "")
        fallbackMenu.addItem(.separator())
        fallbackMenu.addItem(withTitle: "Quit Notchd",    action: #selector(NSApplication.terminate(_:)),      keyEquivalent: "q")
        fallbackMenu.items.forEach { $0.target = self }

        _ = NotchPanelController.shared
        _ = StreakNudgeController.shared
        observeContributionsForNudge()
    }

    @objc private func openPanel() {
        NotchPanelController.shared.show()
    }

    @objc private func statusButtonClicked(_ sender: NSStatusBarButton) {
        let event = NSApp.currentEvent
        if event?.type == .rightMouseUp {
            statusItem.menu = fallbackMenu
            statusItem.button?.performClick(nil)
            // Clear menu so left-click still calls action directly
            DispatchQueue.main.async { self.statusItem.menu = nil }
        } else {
            NotchPanelController.shared.toggle()
        }
    }

    private func observeContributionsForNudge() {
        var attempts = 0
        func check() {
            let vm = ContributionViewModel.shared
            if !vm.weeks.isEmpty {
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
}
