import Foundation
import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var token: String    = ""

    init() {
        username = UserDefaults.standard.string(forKey: "githubUsername") ?? ""
        token    = KeychainService.load() ?? ""
    }

    func save() {
        let trimmedUser  = username.trimmingCharacters(in: .whitespaces)
        let trimmedToken = token.trimmingCharacters(in: .whitespaces)
        UserDefaults.standard.set(trimmedUser, forKey: "githubUsername")
        if trimmedToken.isEmpty {
            KeychainService.delete()
        } else {
            KeychainService.save(token: trimmedToken)
        }
    }

    var hasCredentials: Bool {
        !username.trimmingCharacters(in: .whitespaces).isEmpty &&
        !token.trimmingCharacters(in: .whitespaces).isEmpty
    }
}
