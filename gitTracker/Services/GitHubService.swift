import Foundation

enum GitHubError: LocalizedError {
    case noCredentials
    case unauthorized
    case userNotFound(String)
    case rateLimited
    case networkError(Error)
    case decodingError(Error)
    case apiError(String)

    var errorDescription: String? {
        switch self {
        case .noCredentials:           return "Enter your GitHub username and token in Settings."
        case .unauthorized:            return "Invalid token. Check Settings and try again."
        case .userNotFound(let user):  return "GitHub user '\(user)' not found."
        case .rateLimited:             return "GitHub API rate limit exceeded. Try again later."
        case .networkError(let e):     return "Network error: \(e.localizedDescription)"
        case .decodingError(let e):    return "Failed to parse response: \(e.localizedDescription)"
        case .apiError(let msg):       return "GitHub error: \(msg)"
        }
    }
}

enum GitHubService {
    private static let endpoint = URL(string: "https://api.github.com/graphql")!

    private static let query = """
    query($username: String!) {
      user(login: $username) {
        contributionsCollection {
          contributionCalendar {
            totalContributions
            weeks {
              contributionDays {
                date
                contributionCount
                contributionLevel
              }
            }
          }
        }
      }
    }
    """

    static func fetchContributions(username: String, token: String) async throws -> GraphQLResponse {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let body: [String: Any] = [
            "query": query,
            "variables": ["username": username],
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw GitHubError.networkError(error)
        }

        if let http = response as? HTTPURLResponse {
            switch http.statusCode {
            case 401: throw GitHubError.unauthorized
            case 403: throw GitHubError.rateLimited
            case 404: throw GitHubError.userNotFound(username)
            default: break
            }
        }

        let decoded: GraphQLResponse
        do {
            decoded = try JSONDecoder().decode(GraphQLResponse.self, from: data)
        } catch {
            throw GitHubError.decodingError(error)
        }

        if let errors = decoded.errors, let first = errors.first {
            if first.message.lowercased().contains("could not resolve to a user") {
                throw GitHubError.userNotFound(username)
            }
            throw GitHubError.apiError(first.message)
        }

        return decoded
    }
}
