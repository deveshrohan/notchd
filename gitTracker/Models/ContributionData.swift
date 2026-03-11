import Foundation

struct ContributionCalendar: Codable, Sendable {
    let totalContributions: Int
    let weeks: [ContributionWeek]
}

struct ContributionsCollection: Codable, Sendable {
    let contributionCalendar: ContributionCalendar
}

struct GitHubUser: Codable, Sendable {
    let contributionsCollection: ContributionsCollection
}

struct GraphQLData: Codable, Sendable {
    let user: GitHubUser?
}

struct GraphQLResponse: Codable, Sendable {
    let data: GraphQLData?
    let errors: [GraphQLError]?
}

struct GraphQLError: Codable, Sendable {
    let message: String
}
