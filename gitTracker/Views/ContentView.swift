import SwiftUI
import AppKit

struct ContentView: View {
    @ObservedObject var contributionVM = ContributionViewModel.shared
    @ObservedObject var panelState     = PanelState.shared
    @StateObject var settingsVM = SettingsViewModel()
    @State private var showingSettings = false

    private var notchInset: CGFloat { NotchPositionDetector.notchHeight }

    var body: some View {
        ZStack(alignment: .top) {
            panelBackground

            Group {
                if showingSettings {
                    SettingsView(vm: settingsVM) {
                        withAnimation(AnimationConstants.panelSpring) { showingSettings = false }
                    }
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
                } else {
                    ContributionPanelView(vm: contributionVM, username: settingsVM.username) {
                        withAnimation(AnimationConstants.panelSpring) { showingSettings = true }
                    }
                    .transition(.opacity.combined(with: .move(edge: .leading)))
                }
            }
            .animation(AnimationConstants.panelSpring, value: showingSettings)
            .padding(.top, notchInset)
        }
        .frame(width: 370)
        .fixedSize(horizontal: true, vertical: true)
        // Slide from notch on open, slide back on close.
        // Never use scaleEffect(y: 0) — zero Y scale is non-invertible and crashes ScrollView.
        .offset(y: panelState.isOpen ? 0 : -(notchInset + 10))
        .scaleEffect(
            x: panelState.isOpen ? 1.0 : 0.92,
            y: panelState.isOpen ? 1.0 : 0.82,
            anchor: UnitPoint(x: 0.5, y: 0)
        )
        .opacity(panelState.isOpen ? 1.0 : 0.0)
        .animation(
            .spring(response: 0.38, dampingFraction: 0.72),
            value: panelState.isOpen
        )
        .onAppear {
            if settingsVM.hasCredentials && contributionVM.weeks.isEmpty {
                contributionVM.fetchContributions()
            }
        }
    }

    // MARK: - Background — pitch black at top to merge with the notch
    private var panelBackground: some View {
        UnevenRoundedRectangle(
            topLeadingRadius: 0, bottomLeadingRadius: 14,
            bottomTrailingRadius: 14, topTrailingRadius: 0,
            style: .continuous
        )
        .fill(Color.black)
    }
}
