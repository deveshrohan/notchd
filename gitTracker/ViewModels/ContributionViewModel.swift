import Foundation
import SwiftUI

@MainActor
final class ContributionViewModel: ObservableObject {
    static let shared = ContributionViewModel()

    @Published var weeks: [ContributionWeek]  = []
    @Published var totalContributions: Int    = 0
    @Published var isLoading: Bool            = false
    @Published var errorMessage: String?      = nil
    @Published var lastUpdated: Date?         = nil
    /// Bumped each time the panel opens — forces grid views to re-run entrance animations.
    @Published var displayRevisionID: UUID    = UUID()

    private var refreshTimer: Timer?

    private init() {
        loadCached()
        scheduleAutoRefresh()
    }

    func fetchContributions() {
        let username = UserDefaults.standard.string(forKey: "githubUsername") ?? ""
        guard let token = KeychainService.load(), !username.isEmpty, !token.isEmpty else {
            errorMessage = "Enter your GitHub username and token in Settings."
            return
        }

        isLoading    = true
        errorMessage = nil

        Task {
            do {
                let response = try await GitHubService.fetchContributions(username: username, token: token)
                if let calendar = response.data?.user?.contributionsCollection.contributionCalendar {
                    self.weeks               = calendar.weeks
                    self.totalContributions  = calendar.totalContributions
                    self.lastUpdated         = Date()
                    self.errorMessage        = nil
                    self.persistCache(response: calendar)
                } else {
                    self.errorMessage = "No data returned. Check your username."
                }
            } catch {
                self.errorMessage = (error as? GitHubError)?.errorDescription ?? error.localizedDescription
            }
            self.isLoading = false
        }
    }

    private func scheduleAutoRefresh() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 1800, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.fetchContributions()
            }
        }
    }

    private func persistCache(response: ContributionCalendar) {
        if let data = try? JSONEncoder().encode(response) {
            UserDefaults.standard.set(data, forKey: "cachedContributions")
        }
    }

    private func loadCached() {
        guard let data = UserDefaults.standard.data(forKey: "cachedContributions"),
              let calendar = try? JSONDecoder().decode(ContributionCalendar.self, from: data)
        else { return }
        weeks              = calendar.weeks
        totalContributions = calendar.totalContributions
    }

    // MARK: - Streak

    /// Number of consecutive days with ≥1 contribution ending today (or yesterday if today is 0).
    var currentStreak: Int {
        let allDays = weeks.flatMap(\.contributionDays).sorted { $0.date < $1.date }
        guard !allDays.isEmpty else { return 0 }
        let cal = Calendar.current
        var checkDate = cal.startOfDay(for: Date())
        var streak = 0
        while true {
            let str = Self.isoDate(checkDate)
            guard let day = allDays.last(where: { $0.date == str }) else { break }
            if day.contributionCount > 0 {
                streak += 1
                checkDate = cal.date(byAdding: .day, value: -1, to: checkDate)!
            } else if streak == 0 {
                // Today is 0 — check from yesterday so we don't break streak prematurely
                checkDate = cal.date(byAdding: .day, value: -1, to: checkDate)!
                continue
            } else {
                break
            }
        }
        return streak
    }

    /// Contributions made today.
    var todayCount: Int {
        let str = Self.isoDate(Calendar.current.startOfDay(for: Date()))
        return weeks.flatMap(\.contributionDays).first(where: { $0.date == str })?.contributionCount ?? 0
    }

    /// True when user has an active streak but hasn't contributed today.
    var streakAtRisk: Bool { currentStreak > 0 && todayCount == 0 }

    private static func isoDate(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        df.timeZone = .current
        return df.string(from: date)
    }
}
