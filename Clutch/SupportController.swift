import AppKit
import SwiftUI

/// Usage stats that decide when to ask for support
struct SupportStats: Codable, Equatable {
    var triggerCount = 0
    /// Distinct local days ("yyyy-MM-dd") on which a shortcut actually fired, most recent last
    var activeDays: [String] = []
    var lastPrompt: Date?
    var dismissCount = 0
    var hasSupported = false
}

/// Links shown in the support popup. The payment links are demo placeholders.
enum SupportLinks {
    static let gitHub = URL(string: "https://github.com/your-name/Clutch")!
    static let payPal = URL(string: "https://paypal.me/your-name")!
}

/// Decides when to show the support popup and owns its floating panel
@MainActor
final class SupportController {
    weak var state: AppState?

    static let requiredActiveDays = 3
    static let snoozeDays = 14
    static let maxDismissals = 3
    static let daytimeHours = 10..<19

    private var panel: NSPanel?
    private var model: SupportModel?
    /// Opened from the menu rather than by the automatic prompt; closing it then isn't a "dismissal"
    private var openedManually = false
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

        let model = SupportModel(triggerCount: state.settings.support.triggerCount)
        model.onClose = { [weak self] in self?.close() }
        model.onSupported = { [weak self] in self?.state?.settings.support.hasSupported = true }
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
