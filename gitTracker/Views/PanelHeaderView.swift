import SwiftUI

struct PanelHeaderView: View {
    let username: String
    let totalContributions: Int
    let lastUpdated: Date?
    let isLoading: Bool
    let onRefresh: () -> Void
    let onSettings: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            // Avatar placeholder
            ZStack {
                Circle()
                    .fill(ColorPalette.surface)
                    .frame(width: 32, height: 32)
                Image(systemName: "person.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(ColorPalette.textSecondary)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("@\(username)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(ColorPalette.textPrimary)
                Text("\(totalContributions) contributions this year")
                    .font(.system(size: 11))
                    .foregroundStyle(ColorPalette.textSecondary)
            }

            Spacer()

            if let updated = lastUpdated {
                Text("Updated \(relativeTime(from: updated))")
                    .font(.system(size: 9))
                    .foregroundStyle(ColorPalette.textSecondary.opacity(0.7))
            }

            Button(action: onRefresh) {
                Image(systemName: isLoading ? "arrow.clockwise" : "arrow.clockwise")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(ColorPalette.textSecondary)
                    .rotationEffect(isLoading ? .degrees(360) : .degrees(0))
                    .animation(isLoading ? .linear(duration: 1).repeatForever(autoreverses: false) : .default,
                               value: isLoading)
            }
            .buttonStyle(.plain)
            .help("Refresh")

            Button(action: onSettings) {
                Image(systemName: "gearshape")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(ColorPalette.textSecondary)
            }
            .buttonStyle(.plain)
            .help("Settings")
        }
    }

    private func relativeTime(from date: Date) -> String {
        let elapsed = -date.timeIntervalSinceNow
        if elapsed < 60 { return "just now" }
        if elapsed < 3600 { return "\(Int(elapsed / 60))m ago" }
        return "\(Int(elapsed / 3600))h ago"
    }
}
