import SwiftUI
import AppKit

struct ContentView: View {
    @ObservedObject var contributionVM = ContributionViewModel.shared
    @StateObject var settingsVM = SettingsViewModel()
    @State private var showingSettings = false
    @State private var appeared = false

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
        .offset(y: appeared ? 0 : -(notchInset + 8))
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(AnimationConstants.panelSpring) { appeared = true }
            if settingsVM.hasCredentials && contributionVM.weeks.isEmpty {
                contributionVM.fetchContributions()
            }
        }
    }

    // MARK: - Background
    // Single shape fill — no stroke overlay, no mask trick that causes double-border artifacts.
    // Soft separation comes entirely from the directional shadow.
    private var panelBackground: some View {
        UnevenRoundedRectangle(
            topLeadingRadius: 0, bottomLeadingRadius: 14,
            bottomTrailingRadius: 14, topTrailingRadius: 0,
            style: .continuous
        )
        .fill(
            LinearGradient(
                stops: [
                    .init(color: Color(red: 0.03, green: 0.03, blue: 0.04), location: 0.00),
                    .init(color: ColorPalette.background,                   location: 0.22),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        // Shadow is handled by NSPanel's hasShadow — no SwiftUI shadow to avoid edge artifacts
    }
}
