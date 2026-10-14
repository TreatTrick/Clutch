import AppKit

/// Performs system actions: desktop switching posts the system shortcut, Mission Control actions notify the Dock, Notification Center presses the menu bar clock
enum ActionPerformer {
    static func perform(_ action: SystemAction) {
        switch action {
        case .previousSpace: postSymbolicHotKey(.moveLeftASpace)
        case .nextSpace: postSymbolicHotKey(.moveRightASpace)
        case .missionControl: sendDockNotification("com.apple.expose.awake", fallbackArgument: nil)
        case .appExpose: sendDockNotification("com.apple.expose.front.awake", fallbackArgument: "2")
        case .showDesktop: sendDockNotification("com.apple.showdesktop.awake", fallbackArgument: "1")
        case .notificationCenter: toggleNotificationCenter()
        }
    }

    /// Desktop switching relies on the system shortcut and stops working if the user disables it in System Settings
    static func isAvailable(_ action: SystemAction) -> Bool {
        switch action {
        case .previousSpace: SymbolicHotKey.moveLeftASpace.isEnabled
        case .nextSpace: SymbolicHotKey.moveRightASpace.isEnabled
        default: true
        }
    }

    // MARK: - System shortcuts

    /// IDs in com.apple.symbolichotkeys
    enum SymbolicHotKey: String {
        case moveLeftASpace = "79"
        case moveRightASpace = "81"

        private var entry: [String: Any]? {
            let all = CFPreferencesCopyAppValue("AppleSymbolicHotKeys" as CFString,
                                                "com.apple.symbolichotkeys" as CFString) as? [String: Any]
            return all?[rawValue] as? [String: Any]
        }

        /// A missing entry means the user never changed it; enabled by default
        var isEnabled: Bool { entry?["enabled"] as? Bool ?? true }

        /// Reads the user's configured key, falling back to the default ⌃← / ⌃→
        var keyCombo: (keyCode: CGKeyCode, flags: CGEventFlags) {
            let defaultFlags: CGEventFlags = [.maskControl, .maskSecondaryFn]
            let defaultKey: CGKeyCode = self == .moveLeftASpace ? 123 : 124
            guard let value = entry?["value"] as? [String: Any],
                  let parameters = value["parameters"] as? [Int], parameters.count == 3
            else { return (defaultKey, defaultFlags) }
            return (CGKeyCode(parameters[1]), CGEventFlags(rawValue: UInt64(parameters[2])))
        }
    }

    private static func postSymbolicHotKey(_ hotKey: SymbolicHotKey) {
        let (keyCode, flags) = hotKey.keyCombo
        // privateState: unaffected by the modifiers the user is physically holding
        let source = CGEventSource(stateID: .privateState)
        for keyDown in [true, false] {
            guard let event = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: keyDown) else { continue }
            event.flags = flags
            event.post(tap: .cghidEventTap)
        }
    }

    // MARK: - Mission Control / App Windows / Show Desktop

    private typealias CoreDockSendNotification = @convention(c) (CFString, Int32) -> Void

    private static let coreDockSendNotification: CoreDockSendNotification? = {
        let handle = dlopen("/System/Library/Frameworks/ApplicationServices.framework/ApplicationServices", RTLD_LAZY)
        guard let symbol = dlsym(handle, "CoreDockSendNotification") else { return nil }
        return unsafeBitCast(symbol, to: CoreDockSendNotification.self)
    }()

    private static func sendDockNotification(_ name: String, fallbackArgument: String?) {
        if let coreDockSendNotification {
            coreDockSendNotification(name as CFString, 0)
            return
        }
        // If the private API is unavailable, launch Mission Control.app instead: argument 1 shows the desktop, 2 shows app windows
        let url = URL(fileURLWithPath: "/System/Applications/Mission Control.app")
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.arguments = fallbackArgument.map { [$0] } ?? []
        NSWorkspace.shared.openApplication(at: url, configuration: configuration)
    }

    // MARK: - Notification Center

    /// Notification Center has no shortcut, so toggle it by pressing the menu bar clock via Accessibility
    private static func toggleNotificationCenter() {
        guard let app = NSRunningApplication.runningApplications(withBundleIdentifier: "com.apple.controlcenter").first
        else { return }
        let element = AXUIElementCreateApplication(app.processIdentifier)
        guard let menuBar = element.attribute(kAXExtrasMenuBarAttribute) as AXUIElement?,
              let items = menuBar.attribute(kAXChildrenAttribute) as [AXUIElement]?,
              let clock = items.first(where: { ($0.attribute(kAXIdentifierAttribute) as String?) == "com.apple.menuextra.clock" })
        else { return }
        AXUIElementPerformAction(clock, kAXPressAction as CFString)
    }
}

private extension AXUIElement {
    func attribute<T>(_ name: String) -> T? {
        var value: CFTypeRef?
        guard AXUIElementCopyAttributeValue(self, name as CFString, &value) == .success else { return nil }
        return value as? T
    }
}
