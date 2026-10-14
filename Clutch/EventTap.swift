import AppKit

/// Global mouse event tap: turns bound modifier + mouse button / scroll combos into system actions and swallows the original event
@MainActor
final class EventTap {
    private unowned let state: AppState
    private var tap: CFMachPort?
    /// Buttons whose mouse-down was swallowed; their mouse-up must be swallowed too
    private var swallowedButtons = Set<Int64>()
    private var scroll = ScrollAccumulator()

    var isRunning: Bool { tap.map(CGEvent.tapIsEnabled) ?? false }

    init(state: AppState) {
        self.state = state
    }

    func start() {
        let types: [CGEventType] = [
            .rightMouseDown, .rightMouseUp, .otherMouseDown, .otherMouseUp, .scrollWheel, .flagsChanged,
        ]
        let mask = types.reduce(CGEventMask(0)) { $0 | (1 << $1.rawValue) }

        let callback: CGEventTapCallBack = { _, type, event, userInfo in
            let tap = Unmanaged<EventTap>.fromOpaque(userInfo!).takeUnretainedValue()
            return MainActor.assumeIsolated { tap.handle(type: type, event: event) }
        }

        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mask,
            callback: callback,
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else {
            NSLog("Clutch: failed to create event tap")
            return
        }
        self.tap = tap
        let source = CFMachPortCreateRunLoopSource(nil, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
    }

    private func handle(type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        let pass = Unmanaged.passUnretained(event)
        let settings = state.settings

        switch type {
        case .tapDisabledByTimeout, .tapDisabledByUserInput:
            if let tap { CGEvent.tapEnable(tap: tap, enable: true) }
            return pass

        case .flagsChanged:
            scroll.reset()
            return pass

        case .rightMouseUp, .otherMouseUp:
            let button = event.getIntegerValueField(.mouseEventButtonNumber)
            return swallowedButtons.remove(button) == nil ? pass : nil

        default:
            break
        }

        // Let the window handle events while recording; stay out of the way when disabled
        guard settings.isEnabled, !state.isCapturingMouse else { return pass }
        let flags = event.flags

        if type == .rightMouseDown || type == .otherMouseDown {
            let button = event.getIntegerValueField(.mouseEventButtonNumber)
            guard let binding = state.binding(for: .button(Int(button)), flags: flags) else { return pass }
            swallowedButtons.insert(button)
            state.fire(binding)
            return nil
        }

        if type == .scrollWheel, let nsEvent = NSEvent(cgEvent: event) {
            var dx = nsEvent.scrollingDeltaX, dy = nsEvent.scrollingDeltaY
            if nsEvent.isDirectionInvertedFromDevice { dx = -dx; dy = -dy }
            // Only intercept bound scroll directions; others scroll normally
            guard let direction = ScrollDirection(dx: dx, dy: dy, threshold: 0),
                  state.binding(for: .scroll(direction), flags: flags) != nil
            else { return pass }

            // Swallow trackpad momentum scrolling without triggering
            if nsEvent.momentumPhase.isEmpty {
                if !nsEvent.hasPreciseScrollingDeltas {
                    // Regular mouse wheel: one notch triggers
                    dx *= ScrollAccumulator.threshold
                    dy *= ScrollAccumulator.threshold
                }
                if let fired = scroll.feed(dx: dx, dy: dy, at: ProcessInfo.processInfo.systemUptime),
                   let binding = state.binding(for: .scroll(fired), flags: flags) {
                    state.fire(binding)
                }
            }
            return nil
        }

        return pass
    }
}

/// Accumulates continuous scroll events into one directional gesture, with a cooldown so one scroll fires only once
struct ScrollAccumulator {
    static let threshold = 30.0
    static let cooldown = 0.45
    /// A pause longer than this starts a new scroll
    static let gap = 0.3

    private var sumX = 0.0, sumY = 0.0
    private var lastEvent = -Double.infinity
    private var lastFire = -Double.infinity

    mutating func feed(dx: Double, dy: Double, at time: Double) -> ScrollDirection? {
        guard time - lastFire >= Self.cooldown else { return nil }
        if time - lastEvent > Self.gap { reset() }
        lastEvent = time
        sumX += dx
        sumY += dy
        guard let direction = ScrollDirection(dx: sumX, dy: sumY, threshold: Self.threshold) else { return nil }
        lastFire = time
        sumX = 0
        sumY = 0
        return direction
    }

    mutating func reset() {
        sumX = 0
        sumY = 0
    }
}
