import SwiftUI

/// Keyboard keycap; sinks and highlights while held
struct KeyCap: View {
    let key: ModifierKey
    var isActive = false
    var size: CGFloat = 44
    /// Show the key name under the symbol; on by default for large keycaps
    var showsName: Bool?

    var body: some View {
        VStack(spacing: 1) {
            Text(key.symbol)
                .font(.system(size: size * 0.38, weight: .medium))
            if showsName ?? (size >= 40) {
                Text(key.name)
                    .font(.system(size: max(9, size * 0.19), weight: .medium))
                    .foregroundStyle(isActive ? Color.accentColor : .secondary)
            }
        }
        .foregroundStyle(isActive ? Color.accentColor : .primary)
        // Grow wider for long names like "Command" on small keycaps
        .padding(.horizontal, 6)
        .frame(minWidth: size * 1.3)
        .frame(height: size)
        .background {
            RoundedRectangle(cornerRadius: size * 0.2, style: .continuous)
                .fill(isActive ? Color.accentColor.opacity(0.18) : Color(nsColor: .controlBackgroundColor))
                .shadow(color: .black.opacity(isActive ? 0 : 0.16), radius: 0, y: isActive ? 0 : 2)
        }
        .overlay {
            RoundedRectangle(cornerRadius: size * 0.2, style: .continuous)
                .strokeBorder(isActive ? Color.accentColor : Color.secondary.opacity(0.25),
                              lineWidth: isActive ? 1.5 : 1)
        }
        .offset(y: isActive ? 2 : 0)
        .animation(.spring(duration: 0.2), value: isActive)
        .accessibilityElement()
        .accessibilityLabel(key.name)
    }
}

/// Mouse illustration that highlights the triggering part
struct MouseGlyph: View {
    /// nil draws a plain mouse
    let trigger: MouseTrigger?
    var size: CGFloat = 22

    var body: some View {
        ZStack {
            Image(systemName: "computermouse")
                .font(.system(size: size, weight: .light))
                .foregroundStyle(.secondary)
            if let trigger { marker(trigger) }
        }
        .frame(width: size * 1.2, height: size * 1.3)
        .accessibilityHidden(true)
    }

    @ViewBuilder private func marker(_ trigger: MouseTrigger) -> some View {
        switch trigger {
        case .button(1):
            RoundedRectangle(cornerRadius: size * 0.08).fill(Color.accentColor)
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
                .offset(x: -size * 0.42, y: n == 4 ? -size * 0.12 : size * 0.12)
        case .scroll(let direction):
            Image(systemName: "arrow.\(direction.rawValue)")
                .font(.system(size: size * 0.32, weight: .bold))
                .foregroundStyle(Color.accentColor)
                .offset(y: -size * 0.2)
        }
    }
}

/// Compact "⌥ + 🖱 Side Button" label used in breadcrumbs, the list and the menu bar
struct ComboLabel: View {
    let modifier: ModifierKey
    let trigger: MouseTrigger
    var font: Font = .callout

    var body: some View {
        HStack(spacing: 6) {
            KeyCap(key: modifier, size: 34, showsName: true)
            Text(verbatim: "+").foregroundStyle(.tertiary)
            MouseGlyph(trigger: trigger, size: 15)
            Text(trigger.name).lineLimit(1)
        }
        .font(font)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(modifier.name) + \(trigger.name)")
    }
}

/// Animated dashed border that invites the user to press something
struct PulsingBorder: ViewModifier {
    var isActive: Bool
    var cornerRadius: CGFloat = 16
    @State private var phase = false

    func body(content: Content) -> some View {
        content.overlay {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(Color.accentColor.opacity(isActive ? (phase ? 0.9 : 0.25) : 0.15),
                              style: StrokeStyle(lineWidth: 2, dash: isActive ? [7, 5] : []))
                .allowsHitTesting(false)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) { phase = true }
        }
    }
}

extension View {
    func pulsingBorder(_ isActive: Bool, cornerRadius: CGFloat = 16) -> some View {
        modifier(PulsingBorder(isActive: isActive, cornerRadius: cornerRadius))
    }
}
