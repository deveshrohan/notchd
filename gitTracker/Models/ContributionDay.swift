import Foundation

enum ContributionLevel: String, Codable, Sendable {
    case none           = "NONE"
    case firstQuartile  = "FIRST_QUARTILE"
    case secondQuartile = "SECOND_QUARTILE"
    case thirdQuartile  = "THIRD_QUARTILE"
    case fourthQuartile = "FOURTH_QUARTILE"

    var colorIndex: Int {
        switch self {
        case .none:           return 0
        case .firstQuartile:  return 1
        case .secondQuartile: return 2
        case .thirdQuartile:  return 3
        case .fourthQuartile: return 4
        }
    }
}

struct ContributionDay: Codable, Identifiable, Sendable {
    var id: String { date }
    let date: String
    let contributionCount: Int
    let contributionLevel: ContributionLevel
}
