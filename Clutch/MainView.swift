import SwiftUI

struct MainView: View {
    @Environment(AppState.self) private var state

    var body: some View {
        VStack(spacing: 0) {
            HeaderView()
            Divider()
            VStack(alignment: .leading, spacing: 22) {
                if !state.hasAccessibility {
                    PermissionBanner()
                }
                ModifierSection()
                BindingsSection()
            }
            .padding(24)
            .disabled(!state.settings.isEnabled)
            .opacity(state.settings.isEnabled ? 1 : 0.45)
            .animation(.easeOut(duration: 0.2), value: state.settings.isEnabled)
            Divider()
            FooterView()
        }
        .frame(width: 560)
        .overlay(alignment: .bottom) { FiredHUD().padding(.bottom, 64) }
    }
}

// MARK: - Header

private struct HeaderView: View {
    @Environment(AppState.self) private var state

    var body: some View {
        @Bindable var state = state
        HStack(spacing: 12) {
            Image(systemName: "hand.point.up.left.and.text.fill")
                .font(.system(size: 22))
                .foregroundStyle(Color.accentColor)
                .frame(width: 40, height: 40)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.accentColor.opacity(0.12)))
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(verbatim: "Clutch").font(.title2.weight(.semibold))
                Text(L("app.tagline"))
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Toggle(L("common.enable"), isOn: $state.settings.isEnabled)
                .toggleStyle(.switch)
                .labelsHidden()
                .controlSize(.large)
        }
        .padding(.horizontal, 24)
        .padding(.top, 30) // Leave room for the traffic lights in the hidden title bar
        .padding(.bottom, 16)
    }
}

// MARK: - Permission banner

private struct PermissionBanner: View {
    @Environment(AppState.self) private var state

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.shield.fill")
                .foregroundStyle(.orange)
                .font(.title3)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(L("permission.title")).font(.callout.weight(.medium))
                Text(L("permission.detail")).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Button(L("permission.grant")) { state.requestAccessibility() }
                .controlSize(.small)
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.orange.opacity(0.1)))
    }
}

// MARK: - Step 1: modifier key

private struct ModifierSection: View {
    @Environment(AppState.self) private var state

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionTitle(step: 1, title: L("modifier.title"), subtitle: L("modifier.subtitle"))
            HStack(spacing: 10) {
                ForEach(ModifierKey.allCases) { key in
                    let selected = state.settings.modifier == key
                    Button {
                        state.settings.modifier = key
                    } label: {
                        KeyCap(key: key, isHeld: selected && state.isModifierHeld, isSelected: selected)
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
            }
        }
    }
}

// MARK: - Step 2: mouse shortcuts

private struct BindingsSection: View {
    @Environment(AppState.self) private var state

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionTitle(step: 2, title: L("binding.title"), subtitle: L("binding.subtitle"))

            VStack(spacing: 0) {
                ForEach(state.settings.bindings) { binding in
                    BindingRow(binding: binding)
                    if binding.id != state.settings.bindings.last?.id {
                        Divider().padding(.leading, 12)
                    }
                }
                if state.settings.bindings.isEmpty {
                    Text(L("binding.empty"))
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                }
            }
            .background(RoundedRectangle(cornerRadius: 10).fill(.background))
            .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(.separator))

            HStack {
                Button {
                    state.addBinding()
                } label: {
                    Label(L("binding.add"), systemImage: "plus")
                }
                Spacer()
                TryItHint()
            }
        }
    }
}

private struct BindingRow: View {
    @Environment(AppState.self) private var state
    let binding: MouseBinding

    @State private var hovering = false

    private var index: Int? { state.settings.bindings.firstIndex { $0.id == binding.id } }

    private var justFired: Bool {
        guard let fired = state.lastFired else { return false }
        return fired.binding.id == binding.id && Date().timeIntervalSince(fired.date) < 0.8
    }

    var body: some View {
        @Bindable var state = state
        HStack(spacing: 10) {
            TriggerChip(trigger: binding.trigger,
                        isRecording: state.recordingID == binding.id,
                        hasConflict: state.hasConflict(binding)) {
                state.recordingID = state.recordingID == binding.id ? nil : binding.id
            }

            Image(systemName: "arrow.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
                .accessibilityHidden(true)

            if let index {
                Picker(L("binding.action"), selection: $state.settings.bindings[index].action) {
                    ForEach(SystemAction.allCases) { action in
                        Label(action.name, systemImage: action.symbol).tag(action)
                    }
                }
                .labelsHidden()
                .frame(width: 150)
            }

            Text(binding.action.gestureHint)
                .font(.caption)
                .foregroundStyle(.tertiary)
                .lineLimit(1)

            Spacer(minLength: 4)

            if state.hasConflict(binding) {
                WarningIcon(L("binding.conflict"))
            } else if !ActionPerformer.isAvailable(binding.action) {
                WarningIcon(L("binding.hotkeyDisabled"))
            }

            Button {
                state.remove(binding)
            } label: {
                Image(systemName: "minus.circle.fill")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .opacity(hovering ? 1 : 0)
            .help(L("binding.delete"))
            .accessibilityLabel(L("binding.delete"))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(justFired ? Color.accentColor.opacity(0.12) : .clear)
        .animation(.easeOut(duration: 0.3), value: justFired)
        .onHover { hovering = $0 }
    }
}

private struct WarningIcon: View {
    let message: String
    init(_ message: String) { self.message = message }

    var body: some View {
        Image(systemName: "exclamationmark.triangle.fill")
            .foregroundStyle(.orange)
            .help(message)
            .accessibilityLabel(message)
    }
}

private struct TryItHint: View {
    @Environment(AppState.self) private var state

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "sparkles").accessibilityHidden(true)
            Text(L("binding.tryIt %@", state.settings.modifier.symbol))
        }
        .font(.caption)
        .foregroundStyle(state.isModifierHeld ? Color.accentColor : .secondary)
    }
}

private struct SectionTitle: View {
    let step: Int
    let title: String
    let subtitle: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(verbatim: "\(step)")
                .font(.caption.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 18, height: 18)
                .background(Circle().fill(Color.accentColor))
                .accessibilityHidden(true)
            Text(title).font(.headline)
            Text(subtitle).font(.caption).foregroundStyle(.secondary)
        }
    }
}

// MARK: - Footer: general settings

private struct FooterView: View {
    @Environment(AppState.self) private var state

    var body: some View {
        @Bindable var state = state
        HStack(spacing: 16) {
            Toggle(L("settings.launchAtLogin"), isOn: Binding(
                get: { state.launchAtLogin },
                set: { state.setLaunchAtLogin($0) }
            ))
            .toggleStyle(.checkbox)

            Picker(L("settings.language"), selection: $state.settings.language) {
                ForEach(AppLanguage.allCases) { Text($0.displayName).tag($0) }
            }
            .fixedSize()

            Spacer()
            Text(L("settings.menuBarHint"))
                .font(.caption)
                .foregroundStyle(.tertiary)
                .lineLimit(1)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
    }
}

// MARK: - Trigger feedback HUD

private struct FiredHUD: View {
    @Environment(AppState.self) private var state
    @State private var text: String?
    @State private var symbol = ""

    var body: some View {
        Group {
            if let text {
                HStack(spacing: 8) {
                    Image(systemName: symbol).foregroundStyle(Color.accentColor)
                    Text(text).font(.callout.weight(.medium))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(.regularMaterial, in: Capsule())
                .shadow(color: .black.opacity(0.15), radius: 10, y: 4)
                .transition(.scale(scale: 0.9).combined(with: .opacity))
            }
        }
        .animation(.spring(duration: 0.25), value: text)
        .onChange(of: state.lastFired?.date) { _, _ in
            guard let binding = state.lastFired?.binding else { return }
            let current = "\(state.settings.modifier.symbol) + \(binding.trigger.name) → \(binding.action.name)"
            symbol = binding.action.symbol
            text = current
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                if text == current { text = nil }
            }
        }
    }
}
