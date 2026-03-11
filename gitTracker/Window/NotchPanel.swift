import AppKit
import SwiftUI

final class NotchPanel: NSPanel {
    init() {
        super.init(
            contentRect: .zero,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        isOpaque        = false
        backgroundColor = .clear
        level           = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.statusWindow)) + 1)
        collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle, .fullScreenAuxiliary]
        hasShadow       = true
        isMovableByWindowBackground = false
        acceptsMouseMovedEvents = true
    }

    // Allow the panel to become key (receive keyboard events) when needed
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}
