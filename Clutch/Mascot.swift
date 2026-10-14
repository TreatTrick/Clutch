import AppKit
import CoreImage
import Observation

/// A bundled frame sequence (multi-image HEIC), decoded on demand
final class MascotFrames {
    private let source: CGImageSource
    let count: Int
    private let cache = NSCache<NSNumber, CGImage>()

    init?(named name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "heic"),
              let source = CGImageSourceCreateWithURL(url as CFURL, nil)
        else { return nil }
        self.source = source
        count = CGImageSourceGetCount(source)
        // Decoded frames are ~0.75 MB each; keep enough for smooth back-and-forth scrubbing
        cache.countLimit = 40
    }

    func frame(_ index: Int) -> CGImage? {
        let index = min(max(index, 0), count - 1)
        if let cached = cache.object(forKey: index as NSNumber) { return cached }
        guard let image = CGImageSourceCreateImageAtIndex(source, index, nil) else { return nil }
        cache.setObject(image, forKey: index as NSNumber)
        return image
    }
}

/// Drives the support popup: tracks the mouse and picks which mascot frame to show
@MainActor
@Observable
final class SupportModel {
    enum Phase {
        /// Mood follows the mouse: near the close button she's sad, near the tip area she lights up
        case scrubbing
        /// After a tip or star: play clip A quickly to its happiest frame
        case rushing
        /// Loop the jumping-for-joy clip
        case celebrating
    }

    let triggerCount: Int
    /// Tracked separately so either button stays usable after the other was clicked
    private(set) var starred = false
    private(set) var tipped = false
    var hasSupported: Bool { starred || tipped }
    private(set) var phase = Phase.scrubbing
    private(set) var image: CGImage?
    /// -1...1, drives a gentle breathing scale while idle
    private(set) var breath: Double = 0
    var payment: PaymentMethod

    @ObservationIgnored var onClose: () -> Void = {}
    @ObservationIgnored var onSupported: () -> Void = {}
    @ObservationIgnored weak var window: NSWindow?
    /// Reported by the view, in the window's top-left-origin coordinates
    @ObservationIgnored var closeRect = CGRect.null
    @ObservationIgnored var tipRect = CGRect.null

    @ObservationIgnored private let clipA = MascotFrames(named: "MascotA")
    @ObservationIgnored private let clipB = MascotFrames(named: "MascotB")
    @ObservationIgnored private var timer: Timer?
    @ObservationIgnored private var mood = 0.0
    @ObservationIgnored private var cursor = 0.0
    @ObservationIgnored private var time = 0.0
    @ObservationIgnored private var shownFrame = (clip: -1, index: -1)
    @ObservationIgnored private let reduceMotion = NSWorkspace.shared.accessibilityDisplayShouldReduceMotion

    private static let tickRate = 30.0
    private static let videoRate = 24.0

    /// Always starts in the "before" state so the whole interaction can be seen again;
    /// whether the user already supported only affects automatic prompting.
    init(triggerCount: Int) {
        self.triggerCount = triggerCount
        // Chinese users are most likely to pay with WeChat; everyone else with PayPal
        let isChinese = Localizer.locale.language.languageCode?.identifier == "zh"
        payment = isChinese ? .wechat : .payPal
        show(clip: 0, index: 0)
    }

    func start() {
        timer?.invalidate()
        let timer = Timer(timeInterval: 1 / Self.tickRate, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.tick() }
        }
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    func close() { onClose() }

    func star() {
        starred = true
        celebrate()
    }

    func tip() {
        tipped = true
        celebrate()
    }

    /// Back to how the popup looked before any button was clicked
    func reset() {
        starred = false
        tipped = false
        phase = .scrubbing
        cursor = 0
    }

    /// Cheer up all the way, then jump for joy
    private func celebrate() {
        onSupported()
        guard phase == .scrubbing else { return }
        cursor = mood * Double((clipA?.count ?? 1) - 1)
        phase = .rushing
    }

    private func tick() {
        time += 1 / Self.tickRate
        guard let clipA, let clipB else { return }

        switch phase {
        case .scrubbing:
            // Ease toward the target so small mouse jitters don't make her flicker
            mood += (targetMood() - mood) * 0.12
            var index = mood * Double(clipA.count - 1)
            // Sway a couple of frames around the current mood so she never freezes
            if !reduceMotion { index += sin(time * 2.4) * 2.5 }
            show(clip: 0, index: Int(index.rounded()))
            breath = reduceMotion ? 0 : sin(time * 2.2)

        case .rushing:
            cursor += 2.5
            if cursor >= Double(clipA.count - 1) {
                phase = .celebrating
                cursor = 0
            }
            show(clip: 0, index: Int(cursor))
            breath = 0

        case .celebrating:
            // Clip B starts and ends on the same pose, so it loops seamlessly
            cursor = (cursor + Self.videoRate / Self.tickRate).truncatingRemainder(dividingBy: Double(clipB.count))
            show(clip: 1, index: Int(cursor))
        }
    }

    /// 0 = right on the close button, 1 = on the tip area
    private func targetMood() -> Double {
        guard let window, let content = window.contentView, !closeRect.isNull, !tipRect.isNull else { return 0.4 }
        let local = window.convertPoint(fromScreen: NSEvent.mouseLocation)
        let point = CGPoint(x: local.x, y: content.bounds.height - local.y)
        let toClose = distance(from: point, to: closeRect)
        let toTip = distance(from: point, to: tipRect)
        return toClose / max(toClose + toTip, 1)
    }

    private func distance(from point: CGPoint, to rect: CGRect) -> Double {
        let dx = max(rect.minX - point.x, 0, point.x - rect.maxX)
        let dy = max(rect.minY - point.y, 0, point.y - rect.maxY)
        return hypot(dx, dy)
    }

    private func show(clip: Int, index: Int) {
        guard shownFrame != (clip, index) else { return }
        shownFrame = (clip, index)
        image = (clip == 0 ? clipA : clipB)?.frame(index)
    }
}

/// Ways to tip. The QR payloads are demo placeholders.
enum PaymentMethod: String, CaseIterable, Identifiable {
    case payPal, wechat, alipay

    var id: String { rawValue }

    var name: String {
        switch self {
        case .payPal: "PayPal"
        case .wechat: L("payment.wechat")
        case .alipay: L("payment.alipay")
        }
    }

    var caption: String { L("payment.\(rawValue).caption") }

    var tint: NSColor {
        switch self {
        case .payPal: NSColor(srgbRed: 0, green: 0.19, blue: 0.53, alpha: 1)
        case .wechat: NSColor(srgbRed: 0.03, green: 0.76, blue: 0.38, alpha: 1)
        case .alipay: NSColor(srgbRed: 0.09, green: 0.47, blue: 1, alpha: 1)
        }
    }

    var payload: String {
        switch self {
        case .payPal: SupportLinks.payPal.absoluteString
        case .wechat: "wxp://f2f0-clutch-demo-code"
        case .alipay: "https://qr.alipay.com/clutch-demo-code"
        }
    }

    /// Crisp QR code image; draw it with interpolation turned off
    var qrCode: CGImage? {
        let filter = CIFilter(name: "CIQRCodeGenerator")!
        filter.setValue(Data(payload.utf8), forKey: "inputMessage")
        filter.setValue("M", forKey: "inputCorrectionLevel")
        // The generator outputs one pixel per module; scale up so it stays sharp when drawn
        guard let output = filter.outputImage?.transformed(by: CGAffineTransform(scaleX: 8, y: 8)) else { return nil }
        return CIContext().createCGImage(output, from: output.extent)
    }
}
