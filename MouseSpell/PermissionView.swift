import SwiftUI

/// Shown instead of everything else until Accessibility permission is granted
struct PermissionView: View {
    @Environment(AppState.self) private var state
    @State private var hasRequested = false
    @State private var showStuckHint = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)

            Image(systemName: "lock.shield.fill")
                .font(.system(size: 54))
                .foregroundStyle(Color.accentColor.gradient)
                .symbolEffect(.pulse, isActive: hasRequested)
                .padding(.bottom, 20)
                .accessibilityHidden(true)

            Text(L("permission.title"))
                .font(.title2.weight(.semibold))
                .multilineTextAlignment(.center)
            Text(L("permission.detail"))
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 380)
                .padding(.top, 8)

            Button {
                hasRequested = true
                state.requestAccessibility()
            } label: {
                Text(L(hasRequested ? "permission.reopen" : "permission.grant"))
                    .frame(minWidth: 200)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.extraLarge)
            .keyboardShortcut(.defaultAction)
            .padding(.top, 28)

            Group {
                if hasRequested {
                    HStack(spacing: 8) {
                        ProgressView().controlSize(.small)
                        Text(L("permission.waiting"))
                    }
                } else {
                    Text(L("permission.privacy"))
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            .frame(height: 20)
            .padding(.top, 14)

            if showStuckHint {
                VStack(spacing: 6) {
                    Text(L("permission.stuck"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Button(L("permission.reset")) { state.resetAccessibility() }
                        .buttonStyle(.link)
                        .font(.caption)
                }
                .frame(maxWidth: 380)
                .padding(.top, 18)
                .transition(.opacity)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 40)
        .frame(height: 420)
        .animation(.easeOut(duration: 0.2), value: hasRequested)
        .animation(.easeOut(duration: 0.2), value: showStuckHint)
        .task(id: hasRequested) {
            // If permission still hasn't arrived after a while, the switch is probably on for a stale entry
            guard hasRequested else { return }
            try? await Task.sleep(for: .seconds(6))
            showStuckHint = true
        }
    }
}
