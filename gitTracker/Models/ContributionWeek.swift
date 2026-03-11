import Foundation

struct ContributionWeek: Codable, Identifiable, Sendable {
    let id = UUID()
    let contributionDays: [ContributionDay]

    enum CodingKeys: String, CodingKey {
        case contributionDays
    }
}
