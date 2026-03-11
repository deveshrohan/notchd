import SwiftUI

/// Shared flag that bridges NotchPanelController → ContentView
/// so SwiftUI can own the entry/exit animation entirely.
@MainActor
final class PanelState: ObservableObject {
    static let shared = PanelState()
    @Published var isOpen = false
}
