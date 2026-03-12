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
            NotchShape(topCornerRadius: 14, bottomCornerRadius: 14)
                .fill(Color.black)

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
}

// MARK: - Notch shape (gitisland design)

struct NotchShape: Shape {
    var topCornerRadius: CGFloat
    var bottomCornerRadius: CGFloat

    init(topCornerRadius: CGFloat = 6, bottomCornerRadius: CGFloat = 14) {
        self.topCornerRadius = topCornerRadius
        self.bottomCornerRadius = bottomCornerRadius
    }

    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { .init(topCornerRadius, bottomCornerRadius) }
        set {
            topCornerRadius = newValue.first
            bottomCornerRadius = newValue.second
        }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Start at top-left
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))

        // Top-left corner curve
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + topCornerRadius, y: rect.minY + topCornerRadius),
            control: CGPoint(x: rect.minX + topCornerRadius, y: rect.minY)
        )

        // Left edge
        path.addLine(to: CGPoint(x: rect.minX + topCornerRadius, y: rect.maxY - bottomCornerRadius))

        // Bottom-left corner curve
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + topCornerRadius + bottomCornerRadius, y: rect.maxY),
            control: CGPoint(x: rect.minX + topCornerRadius, y: rect.maxY)
        )

        // Bottom edge
        path.addLine(to: CGPoint(x: rect.maxX - topCornerRadius - bottomCornerRadius, y: rect.maxY))

        // Bottom-right corner curve
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX - topCornerRadius, y: rect.maxY - bottomCornerRadius),
            control: CGPoint(x: rect.maxX - topCornerRadius, y: rect.maxY)
        )

        // Right edge
        path.addLine(to: CGPoint(x: rect.maxX - topCornerRadius, y: rect.minY + topCornerRadius))

        // Top-right corner curve
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY),
            control: CGPoint(x: rect.maxX - topCornerRadius, y: rect.minY)
        )

        // Top edge back to start
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))

        return path
    }
}
