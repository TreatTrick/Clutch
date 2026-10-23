import SwiftUI

extension Notification.Name {
    static let openSettings = Notification.Name("io.github.mousespell.openSettings")
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var launchedAsLoginItem = false

    func applicationWillFinishLaunching(_ notification: Notification) {
        // The launch Apple event carries this flag when macOS starts the app as a login item
        let event = NSAppleEventManager.shared().currentAppleEvent
        launchedAsLoginItem = event?.eventID == kAEOpenApplication
            && event?.paramDescriptor(forKeyword: keyAEPropData)?.enumCodeValue == keyAELaunchedAsLogInItem
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Started at login: stay quietly in the menu bar
        if launchedAsLoginItem {
            NSApp.windows.filter { !($0 is NSPanel) }.forEach { $0.close() }
        }
    }

    /// Launching the app again (Finder, Spotlight, Xcode) while it's running opens the settings window
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows: Bool) -> Bool {
        NotificationCenter.default.post(name: .openSettings, object: nil)
        return true
    }
}

@main
struct MouseSpellApp: App {
    @NSApplicationDelegateAdaptor private var appDelegate: AppDelegate
    @State private var state = AppState()

    var body: some Scene {
        Window(Text(verbatim: "MouseSpell"), id: "main") {
            MainView()
                .environment(state)
                // L() reads from a static bundle, so rebuild the view tree to refresh text when the language changes
                .id(state.settings.language)
                .onAppear { NSApp.activate(ignoringOtherApps: true) }
        }
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
        .defaultLaunchBehavior(.presented)

        MenuBarExtra {
            MenuBarView()
                .environment(state)
                .id(state.settings.language)
        } label: {
            MenuBarIcon(isEnabled: state.settings.isEnabled)
        }
        .menuBarExtraStyle(.window)
    }
}

/// The status item label stays alive for the app's lifetime, so it also handles requests to open the window
private struct MenuBarIcon: View {
    let isEnabled: Bool
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        // Solid when active, outline while paused
        Image(isEnabled ? "MenuBarIcon" : "MenuBarIconOff")
            .onReceive(NotificationCenter.default.publisher(for: .openSettings)) { _ in
                openWindow(id: "main")
                NSApp.activate(ignoringOtherApps: true)
            }
    }
}
