import SwiftUI

struct SettingsView: View {
    @ObservedObject var vm: SettingsViewModel
    let onDone: () -> Void

    @State private var showToken = false
    @State private var saved = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("Settings")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(ColorPalette.textPrimary)
                Spacer()
                Button(action: onDone) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(ColorPalette.textSecondary)
                }
                .buttonStyle(.plain)
            }

            Divider()
                .background(ColorPalette.border)

            // Username field
            VStack(alignment: .leading, spacing: 6) {
                Text("GitHub Username")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(ColorPalette.textSecondary)
                TextField("e.g. torvalds", text: $vm.username)
                    .textFieldStyle(.plain)
                    .font(.system(size: 13))
                    .foregroundStyle(ColorPalette.textPrimary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(ColorPalette.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(ColorPalette.border, lineWidth: 1))
            }

            // Token field
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Personal Access Token")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(ColorPalette.textSecondary)
                    Spacer()
                    Button(showToken ? "Hide" : "Show") {
                        showToken.toggle()
                    }
                    .font(.system(size: 10))
                    .buttonStyle(.plain)
                    .foregroundStyle(Color(red: 0.149, green: 0.651, blue: 0.255))
                }
                Group {
                    if showToken {
                        TextField("ghp_...", text: $vm.token)
                    } else {
                        SecureField("ghp_...", text: $vm.token)
                    }
                }
                .textFieldStyle(.plain)
                .font(.system(size: 13, design: .monospaced))
                .foregroundStyle(ColorPalette.textPrimary)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(ColorPalette.surface)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(ColorPalette.border, lineWidth: 1))

                Text("Requires read:user scope. Token stored securely in Keychain.")
                    .font(.system(size: 10))
                    .foregroundStyle(ColorPalette.textSecondary.opacity(0.8))
            }

            // Save button
            HStack {
                Button("Get a token →") {
                    NSWorkspace.shared.open(URL(string: "https://github.com/settings/tokens/new?scopes=read:user")!)
                }
                .font(.system(size: 11))
                .buttonStyle(.plain)
                .foregroundStyle(Color(red: 0.149, green: 0.651, blue: 0.255))

                Spacer()

                Button(saved ? "Saved!" : "Save & Fetch") {
                    vm.save()
                    ContributionViewModel.shared.fetchContributions()
                    withAnimation {
                        saved = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation { saved = false }
                    }
                    onDone()
                }
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(ColorPalette.background)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(Color(red: 0.149, green: 0.651, blue: 0.255))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .buttonStyle(.plain)
                .disabled(vm.username.trimmingCharacters(in: .whitespaces).isEmpty)
            }

            Divider()
                .background(ColorPalette.border)

            Button(role: .destructive) {
                NSApp.terminate(nil)
            } label: {
                Label("Quit Notchd", systemImage: "power")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.red.opacity(0.75))
            }
            .buttonStyle(.plain)
        }
        .padding(20)
    }
}
