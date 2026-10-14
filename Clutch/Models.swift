import AppKit

/// Keyboard modifier to hold. Mouse shortcuts only work while it's held.
enum ModifierKey: String, CaseIterable, Identifiable, Codable {
    case option, control, command, shift, function

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .option: "⌥"
        case .control: "⌃"
        case .command: "⌘"
        case .shift: "⇧"
        case .function: "fn"
        }
    }

    var name: String {
        switch self {
        case .option: L("modifier.option")
        case .control: L("modifier.control")
        case .command: L("modifier.command")
        case .shift: L("modifier.shift")
        case .function: L("modifier.fn")
        }
    }

    /// Used for local in-window events
    var nsFlag: NSEvent.ModifierFlags {
        switch self {
        case .option: .option
        case .control: .control
        case .command: .command
        case .shift: .shift
        case .function: .function
        }
    }

    /// Used by the global event tap
    var cgFlag: CGEventFlags {
        switch self {
        case .option: .maskAlternate
        case .control: .maskControl
        case .command: .maskCommand
        case .shift: .maskShift
        case .function: .maskSecondaryFn
        }
    }
}

enum ScrollDirection: String, CaseIterable, Codable {
    case up, down, left, right
}

/// Mouse trigger. The left button (0) isn't supported to avoid clashing with normal clicks.
enum MouseTrigger: Hashable, Codable {
    /// 1 right, 2 middle, 3 back side button, 4 forward side button, 5+ extra buttons
    case button(Int)
    case scroll(ScrollDirection)

    static let right = MouseTrigger.button(1)
    static let middle = MouseTrigger.button(2)
    static let back = MouseTrigger.button(3)
    static let forward = MouseTrigger.button(4)

    /// Default triggers tried in order when adding a shortcut
    static let suggestions: [MouseTrigger] = [
        .back, .forward, .middle,
        .scroll(.up), .scroll(.down), .scroll(.left), .scroll(.right), .right,
    ]

    var name: String {
        switch self {
        case .button(1): L("trigger.right")
        case .button(2): L("trigger.middle")
        case .button(3): L("trigger.back")
        case .button(4): L("trigger.forward")
        case .button(let n): L("trigger.button %lld", n + 1)
        case .scroll(.up): L("trigger.scrollUp")
        case .scroll(.down): L("trigger.scrollDown")
        case .scroll(.left): L("trigger.scrollLeft")
        case .scroll(.right): L("trigger.scrollRight")
        }
    }
}

extension MouseTrigger {
    /// Maps an in-window mouse event to a trigger (used for recording)
    init?(event: NSEvent) {
        switch event.type {
        case .rightMouseDown:
            self = .right
        case .otherMouseDown:
            self = .button(event.buttonNumber)
        case .scrollWheel:
            var dx = event.scrollingDeltaX, dy = event.scrollingDeltaY
            if event.isDirectionInvertedFromDevice { dx = -dx; dy = -dy }
            guard let direction = ScrollDirection(dx: dx, dy: dy, threshold: 2) else { return nil }
            self = .scroll(direction)
        default:
            return nil
        }
    }

    static let recordMask: NSEvent.EventTypeMask = [.rightMouseDown, .otherMouseDown, .scrollWheel]
}

extension ScrollDirection {
    /// dx/dy are in physical direction: dy > 0 means scrolling up (away from you)
    init?(dx: Double, dy: Double, threshold: Double) {
        let magnitude = max(abs(dx), abs(dy))
        guard magnitude > 0, magnitude >= threshold else { return nil }
        if abs(dy) >= abs(dx) {
            self = dy > 0 ? .up : .down
        } else {
            self = dx > 0 ? .left : .right
        }
    }
}

/// System features otherwise reached via trackpad gestures or system shortcuts
enum SystemAction: String, CaseIterable, Identifiable, Codable {
    case previousSpace, nextSpace, missionControl, appExpose, showDesktop, notificationCenter

    var id: String { rawValue }

    var name: String { L("action.\(rawValue)") }

    /// The matching trackpad gesture, explaining what this action replaces
    var gestureHint: String { L("gesture.\(rawValue)") }

    var symbol: String {
        switch self {
        case .previousSpace: "arrow.left.square"
        case .nextSpace: "arrow.right.square"
        case .missionControl: "rectangle.3.group"
        case .appExpose: "macwindow.on.rectangle"
        case .showDesktop: "menubar.dock.rectangle"
        case .notificationCenter: "bell.badge"
        }
    }
}

struct MouseBinding: Identifiable, Hashable, Codable {
    var id = UUID()
    var trigger: MouseTrigger
    var action: SystemAction
}
