import SwiftUI

/// Menu bar panel: quick toggle plus an overview of shortcuts
struct MenuBarView: View {
    @Environment(AppState.self) private var state
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        @Bindable var state = state
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(verbatim: "Clutch").font(.headline)
                Spacer()
                if state.hasAccessibility {
                    Toggle(L("common.enable"), isOn: $state.settings.isEnabled)
                        .toggleStyle(.switch)
                        .labelsHidden()
                        .controlSize(.small)
                }
            }

            if !state.hasAccessibility {
                Button {
                    openSettings()
                } label: {
                    Label(L("permission.title"), systemImage: "lock.shield.fill")
                        .foregroundStyle(.orange)
                }
                .buttonStyle(.borderless)
            } else if state.settings.bindings.isEmpty {
                Button(L("menu.addFirst")) { openSettings() }
                    .buttonStyle(.borderless)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(state.settings.bindings) { binding in
                        HStack(spacing: 6) {
                            ComboLabel(modifier: binding.modifier, trigger: binding.trigger, font: .caption)
                            Spacer()
                            Image(systemName: binding.action.symbol)
                                .foregroundStyle(.secondary)
                                .accessibilityHidden(true)
                            Text(binding.action.name).font(.caption)
                        }
                    }
                }
                .opacity(state.settings.isEnabled ? 1 : 0.4)
            }

            Divider()

            HStack {
                Button(L("menu.settings")) { openSettings() }
                    .keyboardShortcut(",")
                Spacer()
                Button(L("menu.quit")) { NSApp.terminate(nil) }
                    .keyboardShortcut("q")
            }
            .buttonStyle(.borderless)
        }
        .padding(14)
        .frame(width: 320)
    }

    private func openSettings() {
        openWindow(id: "main")
        NSApp.activate(ignoringOtherApps: true)
    }
}
