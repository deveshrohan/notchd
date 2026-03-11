import SwiftUI

// Shared state bridge between StreakNudgeController and the SwiftUI view.
@MainActor
final class NudgeState: ObservableObject {
    @Published var isExpanded = false
    @Published var streak     = 0
}

struct StreakNudgeView: View {
    @ObservedObject var state: NudgeState
    let onDismiss: () -> Void
    let onOpenMain: () -> Void

    // Notch pill dimensions (approximate MacBook Pro notch)
    private let pillW: CGFloat = 126
    private let pillH: CGFloat = 37

    // Expanded card dimensions
    private let cardW: CGFloat = 340
    private let cardH: CGFloat = 128

    // Spring used for the island morph
    private let islandSpring = Animation.spring(response: 0.42, dampingFraction: 0.72)

    var body: some View {
        // Fixed frame = full card size, anchored to top-center so the pill
        // appears to "come from" the notch at the top of this view.
        ZStack(alignment: .top) {
            morphingContainer
        }
        .frame(width: cardW + 20, height: cardH + 10, alignment: .top)
    }

    // MARK: - Morphing island shape

    private var morphingContainer: some View {
        ZStack {
            pillLabel
                .opacity(state.isExpanded ? 0 : 1)
                .animation(state.isExpanded ? .easeIn(duration: 0.08) : .easeOut(duration: 0.12).delay(0.25),
                           value: state.isExpanded)

            cardContent
                .opacity(state.isExpanded ? 1 : 0)
                .animation(state.isExpanded ? .easeOut(duration: 0.18).delay(0.18) : .easeIn(duration: 0.08),
                           value: state.isExpanded)
        }
        // Island morph: pill → card
        .frame(
            width:  state.isExpanded ? cardW  : pillW,
            height: state.isExpanded ? cardH  : pillH
        )
        .background(islandBackground)
        .clipShape(RoundedRectangle(cornerRadius: state.isExpanded ? 22 : pillH / 2,
                                    style: .continuous))
        .shadow(color: .black.opacity(state.isExpanded ? 0.55 : 0), radius: 22, y: 6)
        .animation(islandSpring, value: state.isExpanded)
    }

    // MARK: - Background gradient

    private var islandBackground: some View {
        ZStack {
            Color(red: 0.06, green: 0.07, blue: 0.09)
            if state.isExpanded {
                LinearGradient(
                    colors: [
                        Color(red: 0.00, green: 0.27, blue: 0.12).opacity(0.35),
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
    }

    // MARK: - Pill state (tiny label)

    private var pillLabel: some View {
        HStack(spacing: 5) {
            Text("🔥")
                .font(.system(size: 13))
            Text("\(state.streak)")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(Color(red: 0.22, green: 0.85, blue: 0.40))
        }
    }

    // MARK: - Expanded card

    private var cardContent: some View {
        HStack(spacing: 14) {
            // Left: flame badge
            ZStack {
                Circle()
                    .fill(Color(red: 0.00, green: 0.27, blue: 0.12).opacity(0.5))
                    .frame(width: 44, height: 44)
                Text("🔥")
                    .font(.system(size: 22))
            }

            // Right: text + actions
            VStack(alignment: .leading, spacing: 5) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(state.streak)-day streak")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(red: 0.22, green: 0.85, blue: 0.40))
                    Text("at risk")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color(red: 0.93, green: 0.93, blue: 0.94).opacity(0.6))
                }

                Text("You haven't contributed today.\nDon't break the chain.")
                    .font(.system(size: 11))
                    .foregroundStyle(Color(red: 0.93, green: 0.93, blue: 0.94).opacity(0.7))
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 10) {
                    Button("Open GitHub") {
                        NSWorkspace.shared.open(URL(string: "https://github.com")!)
                        onDismiss()
                    }
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Color(red: 0.06, green: 0.07, blue: 0.09))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color(red: 0.22, green: 0.85, blue: 0.40))
                    .clipShape(Capsule())
                    .buttonStyle(.plain)

                    Button("View Stats") {
                        onOpenMain()
                        onDismiss()
                    }
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color(red: 0.93, green: 0.93, blue: 0.94).opacity(0.7))
                    .buttonStyle(.plain)
                }
            }

            Spacer(minLength: 0)

            // Dismiss ×
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(Color(red: 0.93, green: 0.93, blue: 0.94).opacity(0.4))
                    .frame(width: 18, height: 18)
                    .background(Color.white.opacity(0.07))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .padding(.trailing, 2)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(width: cardW, height: cardH)
    }
}
