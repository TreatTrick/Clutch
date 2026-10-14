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
                Toggle(L("common.enable"), isOn: $state.settings.isEnabled)
                    .toggleStyle(.switch)
                    .labelsHidden()
                    .controlSize(.small)
            }

            if !state.hasAccessibility {
                Button {
                    state.requestAccessibility()
                } label: {
                    Label(L("permission.title"), systemImage: "exclamationmark.shield.fill")
                        .foregroundStyle(.orange)
                }
                .buttonStyle(.borderless)
            }

            VStack(alignment: .leading, spacing: 8) {
                ForEach(state.settings.bindings) { binding in
                    HStack(spacing: 6) {
                        KeyCap(key: state.settings.modifier, size: 20)
                        Text(verbatim: "+").foregroundStyle(.tertiary)
                        MouseGlyph(trigger: binding.trigger, size: 14)
                        Text(binding.trigger.name).font(.caption)
                        Spacer()
                        Image(systemName: binding.action.symbol)
                            .foregroundStyle(.secondary)
                            .accessibilityHidden(true)
                        Text(binding.action.name).font(.caption)
                    }
                }
                if state.settings.bindings.isEmpty {
                    Text(L("binding.empty")).font(.caption).foregroundStyle(.secondary)
                }
            }
            .opacity(state.settings.isEnabled ? 1 : 0.4)

            Divider()

            HStack {
                Button(L("menu.settings")) {
                    openWindow(id: "main")
                    NSApp.activate(ignoringOtherApps: true)
                }
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
}
