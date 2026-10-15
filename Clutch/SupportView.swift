import SwiftUI

/// The "buy me a coffee" popup: the mascot on the left, App Store support and GitHub Star on the right
struct SupportView: View {
    @Bindable var model: SupportModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            MascotView(model: model)
                .frame(width: 170, height: 280)
                .padding(.leading, 6)

            VStack(alignment: .leading, spacing: 12) {
                Spacer().frame(height: 18)
                header
                AppStoreSupportCard(model: model)
                gitHubAction
                Text(model.linkMessage ?? L("support.demo"))
                    .font(.caption2)
                    .foregroundStyle(model.linkFailed ? Color.red : Color.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 32, alignment: .topLeading)
                    .lineLimit(3)
            }
            .padding(.trailing, 18)
            .padding(.bottom, 18)
            .frame(width: 294)
        }
        .coordinateSpace(name: SupportView.space)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.regularMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.08))
        )
        .overlay(alignment: .topTrailing) {
            CloseButton { model.close() }
                .reportFrame(into: { model.closeRect = $0 })
                .padding(12)
        }
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .animation(reduceMotion ? nil : .easeOut(duration: 0.2), value: model.isSupported)
        .onExitCommand { model.close() }
    }

    static let space = "support"

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(L(model.isSupported ? "support.thanks.title" : "support.title"))
                .font(.title3.weight(.semibold))
            Text(model.isSupported
                 ? L("support.thanks.detail")
                 : model.triggerCount > 0
                    ? L("support.usage %lld", model.triggerCount)
                    : L("support.subtitle"))
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.trailing, 24) // Room for the close button
    }

    /// GitHub stays clickable after support; opening the page never claims a verified Star.
    private var gitHubAction: some View {
        VStack(alignment: .leading, spacing: 6) {
            Button { model.openGitHub() } label: {
                HStack(spacing: 8) {
                    Label(L("support.star"), systemImage: "star")
                    Spacer(minLength: 0)
                    Image(systemName: "arrow.up.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .accessibilityHidden(true)
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .help(L("support.github.help"))

            Text(L("support.github.detail"))
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Mascot

struct MascotView: View {
    let model: SupportModel

    var body: some View {
        Group {
            if let image = model.image {
                Image(decorative: image, scale: 2)
                    .resizable()
                    .interpolation(.high)
                    .aspectRatio(contentMode: .fit)
            } else {
                // Frames missing from the bundle; keep the layout intact
                Image(systemName: "cup.and.saucer.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.tertiary)
            }
        }
        // Subtle breathing while she follows the mouse
        .scaleEffect(x: 1, y: 1 + model.breath * 0.006, anchor: .bottom)
        .frame(maxHeight: .infinity, alignment: .bottom)
        .accessibilityHidden(true)
    }
}

// MARK: - App Store support card

private struct AppStoreSupportCard: View {
    @Bindable var model: SupportModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: model.isSupported ? "checkmark.seal.fill" : "app.gift.fill")
                    .font(.system(size: 25))
                    .foregroundStyle(model.isSupported ? Color.green : Color.accentColor)
                    .frame(width: 30)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 3) {
                    Text(L(model.isSupported ? "support.already" : "support.store.title"))
                        .font(.callout.weight(.semibold))
                    Text(L(model.purchaseState == .appStore
                           ? "support.store.purchased"
                           : model.isSupported ? "support.confirmed.detail" : "support.store.detail"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            if model.isSupported {
                Label(L("support.received"), systemImage: "heart.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Button { model.openAppStore() } label: {
                    Label(L("support.store.open"), systemImage: "arrow.up.right")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .help(L("support.store.help"))

                Button { model.confirmSupport() } label: {
                    Text(L("support.already"))
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderless)
                .help(L("support.confirm.help"))
            }
        }
        // 已支持后保留卡片高度，感谢动画和 Star 入口不会上下跳动。
        .frame(maxWidth: .infinity, minHeight: 104, alignment: .topLeading)
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(.background.opacity(0.7)))
    }
}

// MARK: - Close button

private struct CloseButton: View {
    let action: () -> Void
    @State private var hovering = false

    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.secondary)
                .frame(width: 24, height: 24)
                .background(Circle().fill(Color.primary.opacity(hovering ? 0.14 : 0.07)))
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .onHover { hovering = $0 }
        .help(L("support.close"))
        .accessibilityLabel(L("support.close"))
    }
}

// MARK: - Frame reporting

private extension View {
    /// Reports this view's frame in the popup's coordinate space (top-left origin)
    func reportFrame(into update: @escaping (CGRect) -> Void) -> some View {
        onGeometryChange(for: CGRect.self) { $0.frame(in: .named(SupportView.space)) } action: { update($0) }
    }
}
