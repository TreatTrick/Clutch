import AppKit
import Observation
import ServiceManagement

/// User settings that are persisted
struct UserSettings: Codable, Equatable {
    var isEnabled = true
    var modifier: ModifierKey = .option
    var language: AppLanguage = .system
    var bindings: [MouseBinding] = [
        .init(trigger: .back, action: .previousSpace),
        .init(trigger: .forward, action: .nextSpace),
        .init(trigger: .middle, action: .missionControl),
        .init(trigger: .scroll(.down), action: .appExpose),
    ]
}

@MainActor
@Observable
final class AppState {
    var settings: UserSettings {
        didSet {
            guard settings != oldValue else { return }
            if settings.language != oldValue.language { Localizer.apply(settings.language) }
            save()
        }
    }

    /// Whether the modifier is currently held (highlights the keycap)
    var isModifierHeld = false
    /// The shortcut currently recording a mouse button
    var recordingID: MouseBinding.ID?
    /// Most recent trigger, used for in-window feedback
    var lastFired: (binding: MouseBinding, date: Date)?
    private(set) var hasAccessibility = AXIsProcessTrusted()
    private(set) var launchAtLogin = SMAppService.mainApp.status == .enabled

    /// Whether this is the first launch (decides if the settings window opens at launch)
    let isFirstLaunch: Bool

    private static let defaultsKey = "settings"
    private var eventTap: EventTap?
    private var monitors: [Any] = []

    init() {
        let data = UserDefaults.standard.data(forKey: Self.defaultsKey)
        isFirstLaunch = data == nil
        settings = data.flatMap { try? JSONDecoder().decode(UserSettings.self, from: $0) } ?? UserSettings()
        Localizer.apply(settings.language)
        // Save right away so the next launch isn't treated as the first
        if isFirstLaunch { save() }

        installLocalMonitors()
        eventTap = EventTap(state: self)
        startEventTapWhenTrusted()
    }

    // MARK: - Shortcuts

    /// The shortcut to run for a mouse trigger (the first one wins if a trigger is bound twice)
    func binding(for trigger: MouseTrigger) -> MouseBinding? {
        settings.bindings.first { $0.trigger == trigger }
    }

    func fire(_ binding: MouseBinding) {
        lastFired = (binding, Date())
        ActionPerformer.perform(binding.action)
    }

    func addBinding() {
        let usedTriggers = Set(settings.bindings.map(\.trigger))
        let usedActions = Set(settings.bindings.map(\.action))
        let binding = MouseBinding(
            trigger: MouseTrigger.suggestions.first { !usedTriggers.contains($0) } ?? .middle,
            action: SystemAction.allCases.first { !usedActions.contains($0) } ?? .missionControl
        )
        settings.bindings.append(binding)
        recordingID = binding.id
    }

    func remove(_ binding: MouseBinding) {
        settings.bindings.removeAll { $0.id == binding.id }
        if recordingID == binding.id { recordingID = nil }
    }

    func hasConflict(_ binding: MouseBinding) -> Bool {
        settings.bindings.filter { $0.trigger == binding.trigger }.count > 1
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
                self.hasAccessibility = AXIsProcessTrusted()
                if self.hasAccessibility, self.eventTap?.isRunning == false {
                    self.eventTap?.start()
                }
            }
        }.fire()
    }

    /// In-window events: record mouse buttons, cancel with Esc, and highlight the modifier even without permission
    private func installLocalMonitors() {
        monitors.append(NSEvent.addLocalMonitorForEvents(matching: MouseTrigger.recordMask) { [weak self] event in
            guard let self, let id = recordingID,
                  let trigger = MouseTrigger(event: event),
                  let index = settings.bindings.firstIndex(where: { $0.id == id })
            else { return event }
            settings.bindings[index].trigger = trigger
            recordingID = nil
            return nil
        } as Any)

        monitors.append(NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard event.keyCode == 53, self?.recordingID != nil else { return event }
            self?.recordingID = nil
            return nil
        } as Any)

        monitors.append(NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
            guard let self else { return event }
            isModifierHeld = event.modifierFlags.contains(settings.modifier.nsFlag)
            return event
        } as Any)
    }
}
