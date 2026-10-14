import SwiftUI

/// The "buy me a coffee" popup: the mascot on the left, ways to tip on the right
struct SupportView: View {
    @Bindable var model: SupportModel

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            MascotView(model: model)
                .frame(width: 170, height: 280)
                .padding(.leading, 6)

            VStack(alignment: .leading, spacing: 12) {
                Spacer().frame(height: 18)
                header
                if model.tipped {
                    ThanksCard { model.reset() }
                        .transition(.scale(scale: 0.9).combined(with: .opacity))
                } else {
                    TipCard(model: model)
                        .reportFrame(into: { model.tipRect = $0 })
                        .transition(.opacity)
                }
                actions
            }
            .padding(.trailing, 18)
            .padding(.bottom, 18)
            .frame(width: 270)
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
        .animation(.spring(duration: 0.4), value: model.tipped)
        .animation(.spring(duration: 0.4), value: model.starred)
        .onExitCommand { model.close() }
    }

    static let space = "support"

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(L("support.title"))
                .font(.title3.weight(.semibold))
            Text(model.triggerCount > 0
                 ? L("support.usage %lld", model.triggerCount)
                 : L("support.subtitle"))
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.trailing, 24) // Room for the close button
    }

    /// Both buttons always stay clickable; each shows a check once done
    private var actions: some View {
        HStack(spacing: 8) {
            Button {
                NSWorkspace.shared.open(SupportLinks.gitHub)
                model.star()
            } label: {
                Label(model.starred ? L("support.starred") : L("support.star"),
                      systemImage: model.starred ? "checkmark" : "star.fill")
                    .frame(maxWidth: .infinity)
            }
            .controlSize(.large)

            Button {
                model.tip()
            } label: {
                Label(model.tipped ? L("support.tipped.done") : L("support.tipped"),
                      systemImage: model.tipped ? "checkmark" : "cup.and.saucer.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.accentColor)
            .controlSize(.large)
            .disabled(model.tipped)
        }
    }
}

// MARK: - Mascot

private struct MascotView: View {
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

private struct TipCard: View {
    @Bindable var model: SupportModel

    var body: some View {
        VStack(spacing: 10) {
            Picker(L("support.method"), selection: $model.payment) {
                ForEach(PaymentMethod.allCases) { Text($0.name).tag($0) }
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
                        Button(L("support.paypal.open")) {
                            NSWorkspace.shared.open(SupportLinks.payPal)
                        }
                        .buttonStyle(.link)
                        .font(.caption)
                    }
                    Text(L("support.demo"))
                        .font(.caption2)
                        .foregroundStyle(.orange)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(.background.opacity(0.7)))
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
                    .padding(8)
            }
            // Brand badge in the middle, like real payment codes
            Circle()
                .fill(Color(nsColor: method.tint))
                .frame(width: 24, height: 24)
                .overlay(Circle().strokeBorder(.white, lineWidth: 3))
        }
        .id(method)
        .transition(.opacity)
        .accessibilityLabel(L("support.qr %@", method.name))
    }
}

private struct ThanksCard: View {
    let onBack: () -> Void

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: "heart.fill")
                .font(.system(size: 30))
                .foregroundStyle(.pink)
                .symbolEffect(.bounce, options: .repeat(2))
            Text(L("support.thanks.title"))
                .font(.headline)
            Text(L("support.thanks.detail"))
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 150)
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(.background.opacity(0.7)))
        .overlay(alignment: .topLeading) {
            // Lets you go back and look at the payment codes again
            Button(action: onBack) {
                Label(L("support.back"), systemImage: "chevron.left")
                    .font(.caption)
            }
            .buttonStyle(.borderless)
            .padding(10)
        }
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
