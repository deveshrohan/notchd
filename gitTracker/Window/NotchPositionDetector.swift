import AppKit

enum NotchPositionDetector {
    /// Returns the screen with a notch (safeAreaInsets.top > 0), or NSScreen.main as fallback.
    static var notchScreen: NSScreen {
        NSScreen.screens.first { $0.safeAreaInsets.top > 0 } ?? NSScreen.main ?? NSScreen.screens[0]
    }

    /// X center of the notch screen, in screen coordinates.
    static var notchCenterX: CGFloat {
        let screen = notchScreen
        return screen.frame.origin.x + screen.frame.width / 2
    }

    /// Top of the screen in screen coordinates (for positioning the panel).
    static var screenTop: CGFloat {
        notchScreen.frame.maxY
    }

    /// Height of the notch (0 on screens without one).
    static var notchHeight: CGFloat {
        notchScreen.safeAreaInsets.top
    }

    static var screenFrame: NSRect {
        notchScreen.frame
    }
}
