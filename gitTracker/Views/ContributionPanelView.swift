import SwiftUI

struct ContributionPanelView: View {
    @ObservedObject var vm: ContributionViewModel
    let username: String
    let onSettings: () -> Void

    /// Last 26 weeks (~6 months) only.
    private var visibleWeeks: [ContributionWeek] {
        let all = vm.weeks
        return all.count > 26 ? Array(all.suffix(26)) : all
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            PanelHeaderView(
                username: username.isEmpty ? "unknown" : username,
                totalContributions: vm.totalContributions,
                lastUpdated: vm.lastUpdated,
                isLoading: vm.isLoading,
                onRefresh: { vm.fetchContributions() },
                onSettings: onSettings
            )

            // Streak row (only when data is loaded)
            if !vm.weeks.isEmpty {
                streakRow
            }

            if let error = vm.errorMessage {
                errorView(message: error)
            } else if vm.weeks.isEmpty && vm.isLoading {
                loadingView
            } else if vm.weeks.isEmpty {
                emptyView
            } else {
                ContributionGridView(weeks: visibleWeeks)
                    .id(vm.displayRevisionID)  // recreate & re-animate on every open
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Streak row

    private var streakRow: some View {
        HStack(spacing: 8) {
            AnimatedFlameView(streak: vm.currentStreak)
            if vm.currentStreak > 0 {
                Text("\(vm.currentStreak)-day streak")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(red: 0.22, green: 0.85, blue: 0.40))
            } else {
                Text("No active streak")
                    .font(.system(size: 12))
                    .foregroundStyle(ColorPalette.textSecondary)
            }

            if vm.streakAtRisk {
                Text("at risk today")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.yellow.opacity(0.9))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.yellow.opacity(0.12))
                    .clipShape(Capsule())
            } else if vm.todayCount > 0 {
                Text("✓ contributed today")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color(red: 0.22, green: 0.85, blue: 0.40).opacity(0.8))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color(red: 0.22, green: 0.85, blue: 0.40).opacity(0.10))
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 2)
    }

    private var loadingView: some View {
        HStack(spacing: 8) {
            ProgressView()
                .scaleEffect(0.7)
                .tint(ColorPalette.textSecondary)
            Text("Loading contributions…")
                .font(.system(size: 12))
                .foregroundStyle(ColorPalette.textSecondary)
        }
        .frame(maxWidth: .infinity, minHeight: 100, alignment: .center)
    }

    private var emptyView: some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 28))
                .foregroundStyle(ColorPalette.textSecondary)
            Text("No contribution data")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(ColorPalette.textSecondary)
            Text("Configure your GitHub credentials in Settings")
                .font(.system(size: 11))
                .foregroundStyle(ColorPalette.textSecondary.opacity(0.7))
            Button("Open Settings") { onSettings() }
                .font(.system(size: 11, weight: .semibold))
                .buttonStyle(.plain)
                .foregroundStyle(Color(red: 0.149, green: 0.651, blue: 0.255))
        }
        .frame(maxWidth: .infinity, minHeight: 100, alignment: .center)
    }

    private func errorView(message: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 14))
                .foregroundStyle(.yellow)
            VStack(alignment: .leading, spacing: 4) {
                Text(message)
                    .font(.system(size: 12))
                    .foregroundStyle(ColorPalette.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                Button("Open Settings") { onSettings() }
                    .font(.system(size: 11, weight: .semibold))
                    .buttonStyle(.plain)
                    .foregroundStyle(Color(red: 0.149, green: 0.651, blue: 0.255))
            }
        }
        .padding(12)
        .background(Color.yellow.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.yellow.opacity(0.2), lineWidth: 1))
    }
}
