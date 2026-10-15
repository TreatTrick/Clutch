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
        // Decoded frames are ~0.75 MB each; keep enough for smooth back-and-forth playback
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

/// Drives the support popup and footer: tracks the mouse and picks which mascot frame to show
@MainActor
@Observable
final class SupportModel {
    enum Interaction {
        case supportPopup
        case coffeeButton
    }

    enum Phase {
        /// Mood follows mouse direction near the close button or toward the footer's coffee button
        case followingMouse
        /// After a tip or star: finish clip A at its original speed to its happiest frame
        case cheeringUp
        /// Loop the jumping-for-joy clip
        case celebrating
    }

    let triggerCount: Int
    /// Tracked separately so either button stays usable after the other was clicked
    private(set) var starred = false
    private(set) var tipped = false
    var hasSupported: Bool { starred || tipped }
    private(set) var phase = Phase.followingMouse
    private(set) var image: CGImage?
    /// -1...1, drives a gentle breathing scale while idle
    private(set) var breath: Double = 0
    var payment: PaymentMethod

    @ObservationIgnored var onClose: () -> Void = {}
    @ObservationIgnored var onSupported: () -> Void = {}
    @ObservationIgnored weak var window: NSWindow?
    /// Reported by the view, in the window's top-left-origin coordinates
    @ObservationIgnored var closeRect = CGRect.null
    /// Native view behind the footer button, used to resolve its current screen coordinates
    @ObservationIgnored weak var coffeeButtonView: NSView?

    @ObservationIgnored private let interaction: Interaction
    @ObservationIgnored private let clipA = MascotFrames(named: "MascotA")
    @ObservationIgnored private let clipB = MascotFrames(named: "MascotB")
    @ObservationIgnored private var timer: Timer?
    @ObservationIgnored private var direction = 1.0
    @ObservationIgnored private var directionAnchor: CGPoint?
    @ObservationIgnored private var cursor = 0.0
    @ObservationIgnored private var time = 0.0
    @ObservationIgnored private var lastTickTime: TimeInterval?
    @ObservationIgnored private var shownFrame = (clip: -1, index: -1)
    @ObservationIgnored private let reduceMotion = NSWorkspace.shared.accessibilityDisplayShouldReduceMotion

    private static let tickRate = 60.0
    private static let videoRate = 24.0
    private static let directionThreshold = 3.0 // pt; filter hand tremor while allowing slow motion to accumulate

    /// Always starts in the "before" state so the whole interaction can be seen again;
    /// whether the user already supported only affects automatic prompting.
    init(triggerCount: Int, interaction: Interaction = .supportPopup) {
        self.triggerCount = triggerCount
        self.interaction = interaction
        if case .coffeeButton = interaction { direction = -1 }
        // Chinese users are most likely to pay with WeChat; everyone else with PayPal
        let isChinese = Localizer.locale.language.languageCode?.identifier == "zh"
        payment = isChinese ? .wechat : .payPal
        show(clip: 0, index: 0)
    }

    func start() {
        timer?.invalidate()
        lastTickTime = ProcessInfo.processInfo.systemUptime
        directionAnchor = nil
        let timer = Timer(timeInterval: 1 / Self.tickRate, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.tick() }
        }
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        lastTickTime = nil
        directionAnchor = nil
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
        phase = .followingMouse
        cursor = 0
        direction = 1
        directionAnchor = nil
        show(clip: 0, index: 0)
    }

    /// Cheer up all the way, then jump for joy
    private func celebrate() {
        onSupported()
        guard phase == .followingMouse else { return }
        phase = .cheeringUp
    }

    private func tick() {
        let now = ProcessInfo.processInfo.systemUptime
        // Use elapsed time for video speed; avoid jumping ahead after a long run-loop stall.
        let elapsed = min(max(now - (lastTickTime ?? now), 0), 0.1)
        lastTickTime = now
        time += elapsed
        guard let clipA, let clipB else { return }
        let frameStep = Self.videoRate * elapsed

        switch phase {
        case .followingMouse:
            // Filter small mouse jitters so they don't make her flicker between playback directions.
            updateDirection()
            cursor = min(max(cursor + direction * frameStep, 0), Double(clipA.count - 1))
            show(clip: 0, index: Int(cursor))
            // Keep idle motion in the subtle breathing scale so video frames never sway back and forth.
            breath = reduceMotion ? 0 : sin(time * 2.2)

        case .cheeringUp:
            cursor += frameStep
            if cursor >= Double(clipA.count - 1) {
                phase = .celebrating
                cursor = 0
                show(clip: 1, index: 0)
            } else {
                show(clip: 0, index: Int(cursor))
            }
            breath = 0

        case .celebrating:
            // Clip B starts and ends on the same pose, so it loops seamlessly
            cursor = (cursor + frameStep).truncatingRemainder(dividingBy: Double(clipB.count))
            show(clip: 1, index: Int(cursor))
        }
    }

    /// The footer cheers up toward coffee; only the popup's upper-right sixteenth can trigger sadness there.
    private func updateDirection() {
        if case .coffeeButton = interaction {
            guard let target = coffeeButtonView, let window = target.window else { return }
            let buttonOnScreen = window.convertToScreen(target.convert(target.bounds, to: nil))
            guard !buttonOnScreen.isEmpty else { return }
            updateDirection(relativeTo: buttonOnScreen, happyWhenApproaching: true)
            return
        }

        guard let window, let content = window.contentView, !closeRect.isNull, !closeRect.isEmpty else { return }
        let point = NSEvent.mouseLocation
        // AppKit coordinates start at the bottom-left: the rightmost and topmost quarter form one sixteenth.
        let sadnessArea = CGRect(x: content.bounds.maxX - content.bounds.width / 4,
                                 y: content.bounds.maxY - content.bounds.height / 4,
                                 width: content.bounds.width / 4, height: content.bounds.height / 4)
        guard window.convertToScreen(sadnessArea).contains(point) else {
            // Star, tipping, and every position outside the close area always play toward happiness.
            direction = 1
            directionAnchor = point
            return
        }

        let buttonInWindow = CGRect(x: closeRect.minX, y: content.bounds.height - closeRect.maxY,
                                    width: closeRect.width, height: closeRect.height)
        let buttonOnScreen = window.convertToScreen(buttonInWindow)
        updateDirection(relativeTo: buttonOnScreen, happyWhenApproaching: false)
    }

    /// The same direction filter serves both targets; only the meaning of approaching changes.
    private func updateDirection(relativeTo target: CGRect, happyWhenApproaching: Bool) {
        let point = NSEvent.mouseLocation
        if target.contains(point) {
            direction = happyWhenApproaching ? 1 : -1
            directionAnchor = point
            return
        }
        guard let anchor = directionAnchor else {
            directionAnchor = point
            return
        }
        // Compare both mouse positions against the same button geometry, so moving the panel alone
        // cannot change direction. Keep the anchor until motion adds up, even with a very slow mouse.
        let change = distance(from: point, to: target) - distance(from: anchor, to: target)
        guard abs(change) >= Self.directionThreshold else { return }
        let approaching = change < 0
        direction = approaching == happyWhenApproaching ? 1 : -1
        directionAnchor = point
        // Keep this direction while the mouse rests; leaving the popup's close area always cheers her up.
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
