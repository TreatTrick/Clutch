import SwiftUI

/// The "buy me a coffee" popup: the mascot on the left, ways to tip and GitHub Star on the right
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
                TipSupportCard(model: model)
                gitHubAction
                // 链接反馈预留固定高度，避免打开浏览器后弹窗布局跳动。
                Text(model.linkMessage ?? "")
                    .font(.caption2)
                    .foregroundStyle(model.linkFailed ? Color.red : Color.secondary)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 32, alignment: .topLeading)
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
            // 手动和自动打开都显示累计次数，包括尚未触发快捷键的 0 次。
            Text(L("support.usage %lld", model.triggerCount))
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            Text(L(model.isSupported ? "support.confirmed.detail" : "support.subtitle"))
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

// MARK: - Tip card

private struct TipSupportCard: View {
    @Bindable var model: SupportModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if model.showsPaymentOptions {
                Picker(L("support.method"), selection: $model.payment) {
                    ForEach(PaymentMethod.allCases) { method in
                        Text(method.name).tag(method)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()

                HStack(spacing: 12) {
                    QRCodeView(method: model.payment)
                        .frame(width: 112, height: 112)

                    VStack(alignment: .leading, spacing: 6) {
                        Text(model.payment.caption)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                        if model.payment == .payPal {
                            Button(L("support.paypal.open")) { model.openPayPal() }
                                .buttonStyle(.link)
                                .font(.caption)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                if model.isSupported {
                    Button { model.showsPaymentOptions = false } label: {
                        Label(L("support.back"), systemImage: "chevron.left")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                } else {
                    Button { model.confirmSupport() } label: {
                        Label(L("support.already"), systemImage: "checkmark")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .help(L("support.confirm.help"))
                }
            } else {
                Label(L("support.received"), systemImage: "heart.fill")
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(.pink)
                Text(L("support.thanks.detail"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
                // Lets you go back and look at the payment codes again without clearing support.
                Button { model.showsPaymentOptions = true } label: {
                    Text(L("support.payment.show"))
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
        }
        // 已支持后保留卡片高度，感谢动画和 Star 入口不会上下跳动。
        .frame(maxWidth: .infinity, minHeight: 186, alignment: .topLeading)
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(.background.opacity(0.7)))
    }
}

private struct QRCodeView: View {
    let method: PaymentMethod

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous).fill(.white)
            if let code = method.qrCode {
                Image(decorative: code, scale: 1)
                    .resizable()
                    .interpolation(.none)
                    .antialiased(false)
                    .aspectRatio(contentMode: .fit)
                    .padding(8)
            } else {
                Image(systemName: "qrcode")
                    .font(.largeTitle)
                    .foregroundStyle(.black)
            }
        }
        .accessibilityLabel(L("support.qr %@", method.name))
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
