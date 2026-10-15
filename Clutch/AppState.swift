import AppKit
import Observation
import ServiceManagement

/// User settings that are persisted
struct UserSettings: Codable, Equatable {
    var isEnabled = true
    var language: AppLanguage = .system
    var appearance: AppAppearance = .system
    var bindings: [MouseBinding] = []
    var support = SupportStats()

    init() {}

    // Decode field by field so settings saved before a field existed still load
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        isEnabled = try c.decodeIfPresent(Bool.self, forKey: .isEnabled) ?? true
        language = try c.decodeIfPresent(AppLanguage.self, forKey: .language) ?? .system
        appearance = try c.decodeIfPresent(AppAppearance.self, forKey: .appearance) ?? .system
        bindings = try c.decodeIfPresent([MouseBinding].self, forKey: .bindings) ?? []
        support = try c.decodeIfPresent(SupportStats.self, forKey: .support) ?? SupportStats()
    }
}

/// The shortcut being created in the recorder, one step at a time
struct Draft: Equatable {
    enum Step: Int, Comparable {
        case modifier, mouse, action, done

        static func < (lhs: Step, rhs: Step) -> Bool { lhs.rawValue < rhs.rawValue }
    }

    var step: Step = .modifier
    var modifier: ModifierKey?
    var trigger: MouseTrigger?
    /// Existing action that already uses the pressed combo
    var conflict: SystemAction?
    /// Direction of the last step change, used for the slide transition
    var movingForward = true
}

@MainActor
@Observable
final class AppState {
    var settings: UserSettings {
        didSet {
            guard settings != oldValue else { return }
            if settings.language != oldValue.language { Localizer.apply(settings.language) }
            if settings.appearance != oldValue.appearance { settings.appearance.apply() }
            save()
        }
    }

    private(set) var draft = Draft()
    /// Set by the recorder view so key and mouse presses are only captured while it's on screen
    var isRecorderVisible = false
    /// Most recent trigger, used to flash the matching row
    private(set) var lastFired: (id: MouseBinding.ID, date: Date)?
    /// Shortcut added most recently, highlighted in the list
    private(set) var lastAddedID: MouseBinding.ID?
    private(set) var hasAccessibility = AXIsProcessTrusted()
    private(set) var launchAtLogin = SMAppService.mainApp.status == .enabled

    /// While true, the event tap lets mouse events through so the recorder can see them
    var isCapturingMouse: Bool { isRecorderVisible && draft.step == .mouse }

    private static let defaultsKey = "settings.v2"
    private var eventTap: EventTap?
    let support = SupportController()
    private var monitors: [Any] = []
    private var doneToken = 0

    init() {
        let data = UserDefaults.standard.data(forKey: Self.defaultsKey)
        settings = data.flatMap { try? JSONDecoder().decode(UserSettings.self, from: $0) } ?? UserSettings()
        Localizer.apply(settings.language)
        settings.appearance.apply()

        installLocalMonitors()
        eventTap = EventTap(state: self)
        support.state = self
        startEventTapWhenTrusted()
    }

    // MARK: - Shortcuts

    /// The shortcut to run for a mouse trigger with the given modifier flags held
    func binding(for trigger: MouseTrigger, flags: CGEventFlags) -> MouseBinding? {
        settings.bindings.first { $0.trigger == trigger && flags.contains($0.modifier.cgFlag) }
    }

    func fire(_ binding: MouseBinding) {
        lastFired = (binding.id, Date())
        ActionPerformer.perform(binding.action)
        settings.support.recordTrigger()
        support.shortcutDidFire()
    }

    func remove(_ binding: MouseBinding) {
        settings.bindings.removeAll { $0.id == binding.id }
    }

    // MARK: - Recorder

    func recordModifier(_ modifier: ModifierKey) {
        guard draft.step == .modifier else { return }
        draft.modifier = modifier
        move(to: .mouse)
    }

    func recordTrigger(_ trigger: MouseTrigger) {
        guard draft.step == .mouse, let modifier = draft.modifier else { return }
        if let existing = settings.bindings.first(where: { $0.modifier == modifier && $0.trigger == trigger }) {
            draft.conflict = existing.action
            return
        }
        draft.trigger = trigger
        move(to: .action)
    }

    func chooseAction(_ action: SystemAction) {
        guard draft.step == .action, let modifier = draft.modifier, let trigger = draft.trigger else { return }
        let binding = MouseBinding(modifier: modifier, trigger: trigger, action: action)
        settings.bindings.append(binding)
        lastAddedID = binding.id
        move(to: .done)

        // Show the confirmation briefly, then get ready for the next shortcut
        doneToken += 1
        let token = doneToken
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) { [weak self] in
            guard let self, doneToken == token, draft.step == .done else { return }
            move(to: .modifier)
        }
    }

    /// Go back one step
    func goBack() {
        switch draft.step {
        case .mouse: move(to: .modifier)
        case .action: move(to: .mouse)
        case .modifier, .done: break
        }
    }

    /// Jump back to an earlier step, clearing whatever was chosen from that step on
    func move(to step: Draft.Step) {
        var draft = self.draft
        draft.movingForward = step > draft.step || draft.step == .done
        draft.step = step
        draft.conflict = nil
        if step <= .modifier { draft.modifier = nil }
        if step <= .mouse { draft.trigger = nil }
        self.draft = draft
    }

    // MARK: - System integration

    func setLaunchAtLogin(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            NSLog("Clutch: failed to update login item: \(error)")
        }
        launchAtLogin = SMAppService.mainApp.status == .enabled
    }

    func requestAccessibility() {
        // Show the system prompt and add Clutch to the Accessibility list
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        AXIsProcessTrustedWithOptions(options)
        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
    }

    /// Clears a stale Accessibility entry (e.g. left by an older build with a different signature) and asks again
    func resetAccessibility() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/tccutil")
        task.arguments = ["reset", "Accessibility", Bundle.main.bundleIdentifier ?? "io.github.clutch.Clutch"]
        try? task.run()
        task.waitUntilExit()
        requestAccessibility()
    }

    private func save() {
        if let data = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(data, forKey: Self.defaultsKey)
        }
    }

    /// Permission is granted asynchronously, so poll and start the event tap once trusted
    private func startEventTapWhenTrusted() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            MainActor.assumeIsolated {
                guard let self else { return timer.invalidate() }
                let trusted = AXIsProcessTrusted()
                if trusted != self.hasAccessibility {
                    self.hasAccessibility = trusted
                    // Bring the user back from System Settings to the next step
                    if trusted { NSApp.activate(ignoringOtherApps: true) }
                }
                if trusted, self.eventTap?.isRunning == false {
                    self.eventTap?.start()
                }
            }
        }.fire()
    }

    /// The menu bar panel is an NSPanel; presses there must not feed the recorder
    private func isRecorderEvent(_ event: NSEvent) -> Bool {
        isRecorderVisible && !(event.window is NSPanel)
    }

    /// In-window events that drive the recorder: modifier presses, mouse buttons, and Esc to go back
    private func installLocalMonitors() {
        monitors.append(NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
            guard let self, isRecorderEvent(event), draft.step == .modifier,
                  let key = ModifierKey(keyCode: event.keyCode),
                  event.modifierFlags.contains(key.nsFlag)
            else { return event }
            recordModifier(key)
            return event
        } as Any)

        monitors.append(NSEvent.addLocalMonitorForEvents(matching: MouseTrigger.recordMask) { [weak self] event in
            guard let self, isRecorderEvent(event), draft.step == .mouse,
                  let trigger = MouseTrigger(event: event)
            else { return event }
            recordTrigger(trigger)
            return nil
        } as Any)

        monitors.append(NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self, event.keyCode == 53, isRecorderEvent(event),
                  draft.step == .mouse || draft.step == .action
            else { return event }
            goBack()
            return nil
        } as Any)
    }
}
