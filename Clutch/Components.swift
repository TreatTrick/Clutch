import SwiftUI

/// Keyboard keycap; sinks and highlights while held
struct KeyCap: View {
    let key: ModifierKey
    var isHeld = false
    var isSelected = true
    var size: CGFloat = 44

    var body: some View {
        VStack(spacing: 1) {
            Text(key.symbol)
                .font(.system(size: size * 0.38, weight: .medium))
            if size >= 40 {
                Text(key.name)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: size * 1.3, height: size)
        .background {
            RoundedRectangle(cornerRadius: size * 0.18, style: .continuous)
                .fill(isHeld ? Color.accentColor.opacity(0.25) : Color(nsColor: .controlBackgroundColor))
                .shadow(color: .black.opacity(isHeld ? 0 : 0.18), radius: 0, y: isHeld ? 0 : 2)
        }
        .overlay {
            RoundedRectangle(cornerRadius: size * 0.18, style: .continuous)
                .strokeBorder(isSelected ? Color.accentColor : Color.secondary.opacity(0.25),
                              lineWidth: isSelected ? 1.5 : 1)
        }
        .offset(y: isHeld ? 2 : 0)
        .animation(.spring(duration: 0.15), value: isHeld)
        .accessibilityElement()
        .accessibilityLabel(key.name)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

/// Mouse illustration that highlights the triggering part
struct MouseGlyph: View {
    let trigger: MouseTrigger
    var size: CGFloat = 22

    var body: some View {
        ZStack {
            Image(systemName: "computermouse")
                .font(.system(size: size, weight: .light))
                .foregroundStyle(.secondary)
            marker
        }
        .frame(width: size * 1.2, height: size * 1.3)
        .accessibilityHidden(true)
    }

    @ViewBuilder private var marker: some View {
        switch trigger {
        case .button(1):
            RoundedRectangle(cornerRadius: 2).fill(Color.accentColor)
                .frame(width: size * 0.22, height: size * 0.3)
                .offset(x: size * 0.15, y: -size * 0.24)
        case .button(2):
            Circle().fill(Color.accentColor)
                .frame(width: size * 0.26)
                .offset(y: -size * 0.22)
        case .button(let n):
            // Side buttons sit on the left: back below, forward above
            Capsule().fill(Color.accentColor)
                .frame(width: size * 0.12, height: size * 0.28)
                .offset(x: -size * 0.42, y: n == 3 ? size * 0.12 : -size * 0.12)
        case .scroll(let direction):
            Image(systemName: "arrow.\(direction.rawValue)")
                .font(.system(size: size * 0.32, weight: .bold))
                .foregroundStyle(Color.accentColor)
                .offset(y: -size * 0.2)
        }
    }
}

/// Mouse button chip on the left of a shortcut row; click to record
struct TriggerChip: View {
    let trigger: MouseTrigger
    let isRecording: Bool
    let hasConflict: Bool
    let action: () -> Void

    @State private var pulse = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if isRecording {
                    Image(systemName: "record.circle")
                        .foregroundStyle(.red)
                        .opacity(pulse ? 0.3 : 1)
                    Text(L("binding.recording"))
                        .foregroundStyle(.secondary)
                } else {
                    MouseGlyph(trigger: trigger, size: 14)
                    Text(trigger.name)
                }
            }
            .font(.callout)
            .lineLimit(1)
            .padding(.horizontal, 10)
            .frame(width: 168, height: 30, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 7).fill(.quaternary.opacity(0.6)))
            .overlay {
                RoundedRectangle(cornerRadius: 7)
                    .strokeBorder(isRecording ? Color.red.opacity(0.7) : hasConflict ? .orange : .clear,
                                  lineWidth: 1.5)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help(isRecording ? L("binding.recording.help") : L("binding.record.help"))
        .accessibilityLabel(isRecording ? L("binding.recording") : trigger.name)
        .accessibilityHint(L("binding.record.help"))
        .onChange(of: isRecording, initial: true) { _, recording in
            pulse = false
            if recording {
                withAnimation(.easeInOut(duration: 0.6).repeatForever()) { pulse = true }
            }
        }
    }
}
