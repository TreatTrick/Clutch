import SwiftUI

struct MainView: View {
    @Environment(AppState.self) private var state

    var body: some View {
        VStack(spacing: 0) {
            HeaderView()
            Divider()
            if state.hasAccessibility {
                VStack(alignment: .leading, spacing: 20) {
                    RecorderView()
                        .disabled(!state.settings.isEnabled)
                        .opacity(state.settings.isEnabled ? 1 : 0.45)
                    BindingList()
                }
                .padding(20)
                .transition(.opacity)
                Divider()
                FooterView()
            } else {
                PermissionView()
                    .transition(.opacity)
            }
        }
        .frame(width: 580)
        .animation(.easeInOut(duration: 0.3), value: state.hasAccessibility)
    }
}

// MARK: - Header

private struct HeaderView: View {
    @Environment(AppState.self) private var state

    var body: some View {
        @Bindable var state = state
        HStack(spacing: 12) {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: 44, height: 44)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(verbatim: "Clutch").font(.title3.weight(.semibold))
                Text(L("app.tagline"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            PreferencesMenu()
            // Nothing to toggle until permission is granted
            if state.hasAccessibility {
                Toggle(isOn: $state.settings.isEnabled) {
                    Text(L(state.settings.isEnabled ? "common.on" : "common.off"))
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                .toggleStyle(.switch)
                .help(L(state.settings.isEnabled ? "common.enabled.help" : "common.disabled.help"))
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 30) // Leave room for the traffic lights in the hidden title bar
        .padding(.bottom, 14)
    }
}

/// Menu for switching language and appearance; lives in the header so it's reachable on every screen
private struct PreferencesMenu: View {
    @Environment(AppState.self) private var state

    var body: some View {
        @Bindable var state = state
        Menu {
            Section(L("settings.appearance")) {
                Picker(L("settings.appearance"), selection: $state.settings.appearance) {
                    ForEach(AppAppearance.allCases) { appearance in
                        Label(appearance.displayName, systemImage: appearance.symbol).tag(appearance)
                    }
                }
                .pickerStyle(.inline)
                .labelsHidden()
            }

            Divider()

            Section(L("settings.language")) {
                Picker(L("settings.language"), selection: $state.settings.language) {
                    ForEach(AppLanguage.allCases) { Text($0.displayName).tag($0) }
                }
                .pickerStyle(.inline)
                .labelsHidden()
            }
        } label: {
            // Keep appearance and language together under one visible preferences entry.
            Label(L("settings.preferences"), systemImage: "slider.horizontal.3")
                .labelStyle(.titleAndIcon)
        }
        .menuStyle(.button)
        .buttonStyle(.bordered)
        .fixedSize()
        .help(L("settings.preferences.help"))
        .accessibilityLabel(L("settings.preferences.help"))
    }
}

// MARK: - Shortcut list

private struct BindingList: View {
    @Environment(AppState.self) private var state

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(L("list.title")).font(.headline)
                if !state.settings.bindings.isEmpty {
                    Text(verbatim: "\(state.settings.bindings.count)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 1)
                        .background(Capsule().fill(.quaternary))
                }
                Spacer()
            }

            // Fixed height so adding or removing a row never resizes the window,
            // which made the list, scroller and trash buttons jitter during the animation
            Group {
                if state.settings.bindings.isEmpty {
                    Text(L("list.empty"))
                        .font(.callout)
                        .foregroundStyle(.tertiary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(RoundedRectangle(cornerRadius: 10).strokeBorder(.separator, style: StrokeStyle(dash: [4, 4])))
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(state.settings.bindings) { binding in
                                BindingRow(binding: binding)
                                    .transition(.asymmetric(insertion: .push(from: .top), removal: .opacity))
                                if binding.id != state.settings.bindings.last?.id {
                                    Divider().padding(.leading, 14)
                                }
                            }
                        }
                    }
                    .scrollBounceBehavior(.basedOnSize)
                    .background(RoundedRectangle(cornerRadius: 10).fill(.background))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(.separator))
                }
            }
            .frame(height: BindingRow.height * 4 + 3)
        }
        .animation(.spring(duration: 0.35), value: state.settings.bindings)
    }
}

private struct BindingRow: View {
    static let height: CGFloat = 44

    @Environment(AppState.self) private var state
    let binding: MouseBinding
    @State private var hovering = false

    private var highlight: Bool {
        if let fired = state.lastFired, fired.id == binding.id, Date().timeIntervalSince(fired.date) < 0.8 { return true }
        return state.lastAddedID == binding.id && state.draft.step == .done
    }

    var body: some View {
        HStack(spacing: 10) {
            ComboLabel(modifier: binding.modifier, trigger: binding.trigger)
                .frame(width: 220, alignment: .leading)
            Image(systemName: "arrow.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
                .accessibilityHidden(true)
            Label(binding.action.name, systemImage: binding.action.symbol)
                .font(.callout)
                .lineLimit(1)
            Spacer(minLength: 4)

            if !ActionPerformer.isAvailable(binding.action) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
                    .help(L("list.hotkeyDisabled"))
                    .accessibilityLabel(L("list.hotkeyDisabled"))
            }

            Button {
                state.remove(binding)
            } label: {
                Image(systemName: "trash")
            }
            .buttonStyle(.borderless)
            .foregroundStyle(hovering ? .red : .secondary)
            .opacity(hovering ? 1 : 0.35)
            .help(L("list.remove"))
            .accessibilityLabel(L("list.remove"))
        }
        .padding(.horizontal, 14)
        .frame(height: Self.height)
        .background(highlight ? Color.accentColor.opacity(0.12) : hovering ? Color.secondary.opacity(0.06) : .clear)
        .animation(.easeOut(duration: 0.3), value: highlight)
        .onHover { hovering = $0 }
        .accessibilityElement(children: .combine)
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
            .fixedSize()

            Text(L("settings.menuBarHint"))
                .font(.caption)
                .foregroundStyle(.tertiary)
                .lineLimit(1)
                .layoutPriority(-1)

            Spacer()

            BuyMeCoffeeButton()
        }
        .padding(.horizontal, 20)
        // Double the original 52 pt footer, with room for the mascot beside the coffee button.
        .frame(height: 104)
    }
}

/// Opens the support popup straight away
private struct BuyMeCoffeeButton: View {
    @Environment(AppState.self) private var state
    @Environment(\.scenePhase) private var scenePhase
    @State private var hovering = false
    @State private var mascot = SupportModel(triggerCount: 0, interaction: .coffeeButton)

    var body: some View {
        HStack(spacing: 12) {
            MascotView(model: mascot)
                .frame(width: 48, height: 96)
                .allowsHitTesting(false)

            Button {
                state.support.showManually()
            } label: {
                Label(L(state.support.isSupported ? "support.already" : "support.button"),
                      systemImage: state.support.isSupported ? "checkmark.seal.fill" : "cup.and.saucer.fill")
                    .font(.callout.weight(.medium))
                    .foregroundStyle(state.support.isSupported
                                     ? Color.primary : Color(red: 0.42, green: 0.25, blue: 0.08))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(state.support.isSupported
                                              ? Color.green.opacity(hovering ? 0.2 : 0.12)
                                              : Color(red: 1, green: 0.8, blue: 0.24).opacity(hovering ? 1 : 0.88)))
                    .contentShape(Capsule())
            }
            .buttonStyle(.plain)
            .fixedSize()
            .background(CoffeeButtonTarget(model: mascot).allowsHitTesting(false))
            .onHover { hovering = $0 }
            .help(state.support.entryHelp)
        }
        .onAppear {
            mascot.updateSupportState(state.support.isSupported)
            mascot.start()
        }
        .onChange(of: state.support.isSupported) { _, supported in
            mascot.updateSupportState(supported)
        }
        .onDisappear { mascot.stop() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                mascot.start()
            } else {
                mascot.stop()
            }
        }
    }
}

/// Resolves the real button bounds after layout, including title-bar insets and window moves.
private struct CoffeeButtonTarget: NSViewRepresentable {
    let model: SupportModel

    func makeNSView(context: Context) -> NSView {
        let view = NSView(frame: .zero)
        model.coffeeButtonView = view
        return view
    }

    func updateNSView(_ view: NSView, context: Context) {
        model.coffeeButtonView = view
    }
}
