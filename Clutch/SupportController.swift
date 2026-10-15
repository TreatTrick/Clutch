import AppKit
import Observation
import StoreKit
import SwiftUI

/// Usage stats that decide when to ask for support
struct SupportStats: Codable, Equatable {
    var triggerCount = 0
    /// Distinct local days ("yyyy-MM-dd") on which a shortcut actually fired, most recent last
    var activeDays: [String] = []
    var lastPrompt: Date?
    var dismissCount = 0
    var hasSupported = false
    var hasPurchased = false

    init() {}

    // 旧的 hasSupported 也可能来自 Star，不能把它当作购买记录。
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        triggerCount = try c.decodeIfPresent(Int.self, forKey: .triggerCount) ?? 0
        activeDays = try c.decodeIfPresent([String].self, forKey: .activeDays) ?? []
        lastPrompt = try c.decodeIfPresent(Date.self, forKey: .lastPrompt)
        dismissCount = try c.decodeIfPresent(Int.self, forKey: .dismissCount) ?? 0
        hasSupported = try c.decodeIfPresent(Bool.self, forKey: .hasSupported) ?? false
        hasPurchased = try c.decodeIfPresent(Bool.self, forKey: .hasPurchased) ?? false
    }
}

/// Links shown in the support popup. Both links are demo placeholders; replace before publishing.
enum SupportLinks {
    static let gitHub = URL(string: "https://github.com/your-name/Clutch")!
    static let appStore = URL(string: "https://apps.apple.com/app/id0000000000")!
}

/// Decides when to show the support popup and owns its floating panel
@MainActor
@Observable
final class SupportController {
    weak var state: AppState?
    private(set) var isAppStorePurchase = false

    var purchaseState: SupportModel.PurchaseState {
        if isAppStorePurchase { return .appStore }
        return state?.settings.support.hasPurchased == true ? .acknowledged : .notSupported
    }

    static let requiredActiveDays = 3
    static let snoozeDays = 14
    static let maxDismissals = 3
    static let daytimeHours = 10..<19

    private var panel: NSPanel?
    private var model: SupportModel?
    /// Opened from the menu rather than by the automatic prompt; closing it then isn't a "dismissal"
    private var openedManually = false
    private var pendingCheck: DispatchWorkItem?

    /// 仅识别正式商店购买；缺少收据时不请求交易，避免 GitHub 版弹出 Apple 账户登录。
    func recognizeAppStorePurchase() async {
        // 这里只检查发行渠道，不解析旧收据；购买状态由下面的 StoreKit 2 签名交易决定。
        let receipt = Bundle.main.bundleURL.appending(path: "Contents/_MASReceipt/receipt")
        guard FileManager.default.fileExists(atPath: receipt.path) else { return }

        do {
            guard case .verified(let transaction) = try await AppTransaction.shared,
                  transaction.environment == .production,
                  transaction.bundleID == Bundle.main.bundleIdentifier
            else { return }
            isAppStorePurchase = true
            model?.updatePurchaseState(.appStore)
        } catch {
            // 识别失败不影响免费使用；用户仍可自行选择“我已支持”。
            NSLog("Clutch: could not recognize the App Store purchase: \(error)")
        }
    }

    /// Called after every successful shortcut. Waits a moment so the action (e.g. a desktop switch) finishes first.
    func shortcutDidFire() {
        pendingCheck?.cancel()
        let work = DispatchWorkItem { [weak self] in
            guard let self, shouldPrompt() else { return }
            show(manually: false)
        }
        pendingCheck = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: work)
    }

    func shouldPrompt(now: Date = Date()) -> Bool {
        guard panel == nil, let stats = state?.settings.support,
              !purchaseState.isSupported,
              !stats.hasSupported,
              stats.dismissCount < Self.maxDismissals,
              stats.activeDays.count >= Self.requiredActiveDays,
              Self.daytimeHours.contains(Calendar.current.component(.hour, from: now))
        else { return false }
        if let last = stats.lastPrompt,
           now.timeIntervalSince(last) < TimeInterval(Self.snoozeDays * 24 * 3600) {
            return false
        }
        return !Self.frontmostAppIsFullScreen()
    }

    func show(manually: Bool) {
        if let panel {
            panel.orderFrontRegardless()
            return
        }
        guard let state else { return }
        openedManually = manually
        if !manually { state.settings.support.lastPrompt = Date() }

        let model = SupportModel(triggerCount: state.settings.support.triggerCount,
                                 purchaseState: purchaseState)
        model.onClose = { [weak self] in self?.close() }
        model.onSupported = { [weak self] in self?.state?.settings.support.hasSupported = true }
        model.onPurchaseConfirmed = { [weak self] in self?.state?.settings.support.hasPurchased = true }
        self.model = model

        // Default sizing options so fittingSize reports the SwiftUI content size
        // (.preferredContentSize alone makes it 0×0 and the panel invisible)
        let host = NSHostingView(rootView: SupportView(model: model))
        let panel = SupportPanel(contentRect: CGRect(origin: .zero, size: host.fittingSize),
                                 styleMask: [.borderless, .nonactivatingPanel],
                                 backing: .buffered, defer: false)
        panel.contentView = host
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.level = .floating
        panel.isMovableByWindowBackground = true
        panel.hidesOnDeactivate = false
        panel.isReleasedWhenClosed = false
        // Stay visible while the user switches desktops with Clutch itself
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        self.panel = panel
        model.window = panel

        // Slide in from the bottom-right corner, like a notification
        let screen = (NSScreen.main ?? NSScreen.screens[0]).visibleFrame
        let size = host.fittingSize
        let origin = CGPoint(x: screen.maxX - size.width - 20, y: screen.minY + 20)
        panel.setFrame(CGRect(origin: CGPoint(x: origin.x, y: origin.y - 24), size: size), display: false)
        panel.alphaValue = 0
        panel.orderFrontRegardless()
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.35
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            panel.animator().alphaValue = 1
            panel.animator().setFrame(CGRect(origin: origin, size: size), display: true)
        }
        model.start()
    }

    func close() {
        guard let panel, let model else { return }
        if !openedManually, !model.hasSupported {
            state?.settings.support.dismissCount += 1
        }
        model.stop()
        self.panel = nil
        self.model = nil
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.2
            panel.animator().alphaValue = 0
        }, completionHandler: {
            panel.orderOut(nil)
        })
    }

    /// Don't interrupt videos, presentations or games
    private static func frontmostAppIsFullScreen() -> Bool {
        guard let pid = NSWorkspace.shared.frontmostApplication?.processIdentifier,
              let windows = CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements],
                                                       kCGNullWindowID) as? [[String: Any]]
        else { return false }
        let screenSizes = NSScreen.screens.map(\.frame.size)
        return windows.contains { info in
            guard info[kCGWindowOwnerPID as String] as? pid_t == pid,
                  info[kCGWindowLayer as String] as? Int == 0,
                  let dict = info[kCGWindowBounds as String] as? NSDictionary,
                  let bounds = CGRect(dictionaryRepresentation: dict)
            else { return false }
            return screenSizes.contains(bounds.size)
        }
    }
}

/// Borderless panel that can still take clicks without activating Clutch
private final class SupportPanel: NSPanel {
    override var canBecomeKey: Bool { true }
}

extension SupportStats {
    /// Records one fired shortcut on the given day
    mutating func recordTrigger(on date: Date = Date()) {
        triggerCount += 1
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        let day = formatter.string(from: date)
        if activeDays.last != day, !activeDays.contains(day) {
            activeDays.append(day)
            // Only the count matters, keep the list short
            if activeDays.count > 30 { activeDays.removeFirst(activeDays.count - 30) }
        }
    }
}
