import AppKit
import Observation
import SwiftUI

/// Usage stats that decide when to ask for support
struct SupportStats: Codable, Equatable {
    static let reminderActiveDays = [3, 7]

    var triggerCount = 0
    /// Distinct local days ("yyyy-MM-dd") on which a shortcut actually fired, most recent last
    var activeDays: [String] = []
    var lastPrompt: Date?
    /// 仅保留以兼容旧设置；新规则在弹出时记录节点，不再按关闭次数计算。
    var dismissCount = 0
    /// 已提醒过的最后一个使用天数节点；跳过的较早节点也不再补弹。
    var lastPromptMilestone = 0
    var hasSupported = false
    var hasTipped = false

    private enum LegacyCodingKeys: String, CodingKey {
        case hasPurchased
    }

    var nextPromptMilestone: Int? {
        Self.reminderActiveDays.last { $0 <= activeDays.count && $0 > lastPromptMilestone }
    }

    init() {}

    // 旧的 hasSupported 也可能来自 Star，不能把它当作打赏记录。
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        triggerCount = try c.decodeIfPresent(Int.self, forKey: .triggerCount) ?? 0
        activeDays = try c.decodeIfPresent([String].self, forKey: .activeDays) ?? []
        lastPrompt = try c.decodeIfPresent(Date.self, forKey: .lastPrompt)
        dismissCount = try c.decodeIfPresent(Int.self, forKey: .dismissCount) ?? 0
        hasSupported = try c.decodeIfPresent(Bool.self, forKey: .hasSupported) ?? false
        // 沿用旧版手动确认的支持声明，不让升级清空用户的支持状态。
        let legacy = try decoder.container(keyedBy: LegacyCodingKeys.self)
        hasTipped = try c.decodeIfPresent(Bool.self, forKey: .hasTipped)
            ?? legacy.decodeIfPresent(Bool.self, forKey: .hasPurchased)
            ?? false
        if let milestone = try c.decodeIfPresent(Int.self, forKey: .lastPromptMilestone) {
            lastPromptMilestone = milestone
        } else if dismissCount >= Self.reminderActiveDays.count {
            // 旧版已提醒至少两次的用户，不因升级再次受到打扰。
            lastPromptMilestone = Self.reminderActiveDays.last ?? 0
        } else if lastPrompt != nil || dismissCount > 0 {
            lastPromptMilestone = Self.reminderActiveDays.first ?? 0
        }
    }
}

/// Links shown in the support popup. The payment and repository links are demo placeholders; replace before publishing.
enum SupportLinks {
    static let gitHub = URL(string: "https://github.com/your-name/Clutch")!
    static let payPal = URL(string: "https://paypal.me/your-name")!
}

/// Decides when to show the support popup and owns its floating panel
@MainActor
@Observable
final class SupportController {
    weak var state: AppState?
    var isSupported: Bool { state?.settings.support.hasTipped == true }

    var entryHelp: String {
        let help = L(isSupported ? "support.supported.help" : "menu.support")
        #if DEBUG
        return help + "\n" + L("support.debug.reset.help")
        #else
        return help
        #endif
    }

    static let daytimeHours = 10..<19

    private var panel: NSPanel?
    private var model: SupportModel?
    private var pendingCheck: DispatchWorkItem?

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
              !isSupported,
              !stats.hasSupported,
              stats.nextPromptMilestone != nil,
              Self.daytimeHours.contains(Calendar.current.component(.hour, from: now))
        else { return false }
        if let last = stats.lastPrompt, Calendar.current.isDate(last, inSameDayAs: now) {
            return false
        }
        return !Self.frontmostAppIsFullScreen()
    }

    /// 两个手动入口共用隐藏操作，正式发布版本保持正常打开行为。
    func showManually() {
        #if DEBUG
        if NSEvent.modifierFlags.contains(.option) {
            resetSupportForDebugging()
        }
        #endif
        show(manually: true)
    }

    #if DEBUG
    /// 只重置本地支持声明和提醒进度，保留快捷键、使用次数和实际使用天数。
    private func resetSupportForDebugging() {
        guard let state else { return }
        pendingCheck?.cancel()
        pendingCheck = nil
        model?.stop()
        panel?.orderOut(nil)
        model = nil
        panel = nil

        var stats = state.settings.support
        stats.hasSupported = false
        stats.hasTipped = false
        stats.lastPrompt = nil
        stats.lastPromptMilestone = 0
        stats.dismissCount = 0
        state.settings.support = stats
    }
    #endif

    func show(manually: Bool) {
        if let panel {
            panel.orderFrontRegardless()
            return
        }
        guard let state else { return }
        // 手动打开不消耗提醒节点；自动弹出即保存，避免关闭或重启后重复提醒。
        if !manually {
            guard shouldPrompt(), let milestone = state.settings.support.nextPromptMilestone else { return }
            var stats = state.settings.support
            stats.lastPrompt = Date()
            stats.lastPromptMilestone = milestone
            state.settings.support = stats
        }

        let model = SupportModel(triggerCount: state.settings.support.triggerCount,
                                 isSupported: isSupported)
        model.onClose = { [weak self] in self?.close() }
        model.onSupported = { [weak self] in self?.state?.settings.support.hasSupported = true }
        model.onTipConfirmed = { [weak self] in self?.state?.settings.support.hasTipped = true }
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
