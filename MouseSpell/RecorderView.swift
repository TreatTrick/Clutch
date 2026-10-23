import SwiftUI

/// The large guided area: press a modifier → press a mouse button → pick an action
struct RecorderView: View {
    @Environment(AppState.self) private var state

    private var draft: Draft { state.draft }

    var body: some View {
        VStack(spacing: 0) {
            StepIndicator(step: draft.step) { state.move(to: $0) }
                .padding(.top, 18)

            ZStack {
                content
                    .id(draft.step)
                    .transition(.asymmetric(
                        insertion: .move(edge: draft.movingForward ? .trailing : .leading).combined(with: .opacity),
                        removal: .move(edge: draft.movingForward ? .leading : .trailing).combined(with: .opacity)
                    ))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()

            footer
                .frame(height: 36)
                .padding(.horizontal, 16)
                .padding(.bottom, 10)
        }
        .frame(height: 300)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.accentColor.opacity(draft.step == .done ? 0.1 : 0.04))
        )
        .pulsingBorder(draft.step == .modifier || draft.step == .mouse)
        .animation(.spring(duration: 0.35), value: draft)
        .onAppear { state.isRecorderVisible = true }
        .onDisappear { state.isRecorderVisible = false }
    }

    @ViewBuilder private var content: some View {
        switch draft.step {
        case .modifier: ModifierStep()
        case .mouse: MouseStep()
        case .action: ActionStep()
        case .done: DoneStep()
        }
    }

    /// Back button
    @ViewBuilder private var footer: some View {
        HStack(spacing: 10) {
            if draft.step == .mouse || draft.step == .action {
                Button {
                    state.goBack()
                } label: {
                    Label(L("recorder.back"), systemImage: "chevron.left")
                }
                .buttonStyle(.borderless)
                .help(L("recorder.back.help"))
            }
            Spacer()
        }
        .foregroundStyle(.secondary)
    }
}

// MARK: - Step indicator

private struct StepIndicator: View {
    let step: Draft.Step
    let jump: (Draft.Step) -> Void

    private let steps: [(Draft.Step, String)] = [
        (.modifier, "recorder.step.key"),
        (.mouse, "recorder.step.mouse"),
        (.action, "recorder.step.action"),
    ]

    var body: some View {
        HStack(spacing: 6) {
            ForEach(steps, id: \.0) { item, key in
                let isDone = item < step
                let isCurrent = item == step
                Button {
                    jump(item)
                } label: {
                    HStack(spacing: 5) {
                        ZStack {
                            Circle().fill(isDone || isCurrent ? Color.accentColor : Color.secondary.opacity(0.2))
                            if isDone {
                                Image(systemName: "checkmark").font(.system(size: 8, weight: .bold))
                            } else {
                                Text(verbatim: "\(item.rawValue + 1)").font(.system(size: 9, weight: .bold))
                            }
                        }
                        .foregroundStyle(isDone || isCurrent ? .white : .secondary)
                        .frame(width: 16, height: 16)
                        Text(L(key))
                            .font(.caption.weight(isCurrent ? .semibold : .regular))
                            .foregroundStyle(isCurrent ? .primary : .secondary)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                // Only completed steps can be revisited
                .disabled(!isDone || step == .done)
                .help(isDone ? L("recorder.step.redo") : "")

                if item != .action {
                    Rectangle()
                        .fill(isDone ? Color.accentColor : Color.secondary.opacity(0.2))
                        .frame(width: 28, height: 1.5)
                }
            }
        }
        .accessibilityElement(children: .contain)
    }
}

// MARK: - Step 1

private struct ModifierStep: View {
    var body: some View {
        StepLayout(title: L("recorder.key.title"), detail: L("recorder.key.detail")) {
            HStack(spacing: 12) {
                ForEach(ModifierKey.allCases) { KeyCap(key: $0, size: 50) }
            }
        }
    }
}

// MARK: - Step 2

private struct MouseStep: View {
    @Environment(AppState.self) private var state
    @State private var bounce = 0

    var body: some View {
        StepLayout(title: L("recorder.mouse.title"), detail: L("recorder.mouse.detail")) {
            VStack(spacing: 10) {
                HStack(spacing: 18) {
                    if let modifier = state.draft.modifier {
                        KeyCap(key: modifier, isActive: true, size: 64)
                    }
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.tertiary)
                    Image(systemName: "computermouse")
                        .font(.system(size: 58, weight: .ultraLight))
                        .foregroundStyle(Color.accentColor)
                        .symbolEffect(.bounce, value: bounce)
                        .frame(width: 70, height: 70)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(Color.accentColor.opacity(0.5), style: StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
                        )
                }
                if let conflict = state.draft.conflict {
                    Label(L("recorder.mouse.conflict %@", conflict.name), systemImage: "exclamationmark.triangle.fill")
                        .font(.caption)
                        .foregroundStyle(.orange)
                        .transition(.opacity)
                }
            }
        }
        .task {
            // Gentle periodic nudge so the user knows the app is waiting for the mouse
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1.6))
                bounce += 1
            }
        }
    }
}

// MARK: - Step 3

private struct ActionStep: View {
    @Environment(AppState.self) private var state

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)

    var body: some View {
        VStack(spacing: 14) {
            HStack(spacing: 14) {
                if let modifier = state.draft.modifier, let trigger = state.draft.trigger {
                    KeyCap(key: modifier, isActive: true, size: 40)
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.tertiary)
                    HStack(spacing: 6) {
                        MouseGlyph(trigger: trigger, size: 26)
                        Text(trigger.name).font(.callout.weight(.medium))
                    }
                    .padding(.horizontal, 12)
                    .frame(height: 40)
                    .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Color.accentColor.opacity(0.12)))
                    .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).strokeBorder(Color.accentColor, lineWidth: 1.5))
                }
                Image(systemName: "arrow.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.tertiary)
                Text(L("recorder.action.title"))
                    .font(.headline)
            }
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(SystemAction.allCases) { action in
                    ActionTile(action: action) { state.chooseAction(action) }
                }
            }
        }
        .padding(.horizontal, 22)
        .padding(.top, 8)
    }
}

private struct ActionTile: View {
    let action: SystemAction
    let choose: () -> Void
    @State private var hovering = false

    var body: some View {
        Button(action: choose) {
            VStack(spacing: 6) {
                Image(systemName: action.symbol)
                    .font(.system(size: 22))
                    .foregroundStyle(Color.accentColor)
                    .frame(height: 26)
                Text(action.name)
                    .font(.callout.weight(.medium))
                    .lineLimit(1)
                Text(action.gestureHint)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(hovering ? Color.accentColor.opacity(0.12) : Color(nsColor: .controlBackgroundColor))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(hovering ? Color.accentColor.opacity(0.6) : Color.secondary.opacity(0.15))
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering = $0 }
        .scaleEffect(hovering ? 1.02 : 1)
        .animation(.easeOut(duration: 0.12), value: hovering)
        .accessibilityHint(action.gestureHint)
    }
}

// MARK: - Done

private struct DoneStep: View {
    @Environment(AppState.self) private var state

    private var added: MouseBinding? {
        state.settings.bindings.first { $0.id == state.lastAddedID }
    }

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 44))
                .foregroundStyle(.green)
                .symbolEffect(.bounce, value: state.lastAddedID)
            Text(L("recorder.done.title"))
                .font(.title3.weight(.semibold))
            if let added {
                HStack(spacing: 8) {
                    ComboLabel(modifier: added.modifier, trigger: added.trigger)
                    Image(systemName: "arrow.right").foregroundStyle(.tertiary)
                    Label(added.action.name, systemImage: added.action.symbol)
                }
                .font(.callout)
            }
        }
    }
}

// MARK: - Shared layout

private struct StepLayout<Visual: View>: View {
    let title: String
    let detail: String
    @ViewBuilder let visual: Visual

    var body: some View {
        VStack(spacing: 16) {
            visual
            VStack(spacing: 4) {
                Text(title)
                    .font(.title3.weight(.semibold))
                Text(detail)
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 24)
    }
}
