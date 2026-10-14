import SwiftUI

@main
struct ClutchApp: App {
    @State private var state = AppState()

    var body: some Scene {
        Window(Text(verbatim: "Clutch"), id: "main") {
            MainView()
                .environment(state)
                // L() reads from a static bundle, so rebuild the view tree to refresh text when the language changes
                .id(state.settings.language)
                .onAppear { NSApp.activate(ignoringOtherApps: true) }
        }
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
        // Open the settings window only on first launch; afterwards live in the menu bar
        .defaultLaunchBehavior(state.isFirstLaunch ? .presented : .suppressed)

        MenuBarExtra {
            MenuBarView()
                .environment(state)
                .id(state.settings.language)
        } label: {
            Image(systemName: state.settings.isEnabled
                  ? "hand.point.up.left.and.text.fill"
                  : "hand.point.up.left.and.text")
        }
        .menuBarExtraStyle(.window)
    }
}
