import AppKit

/// In-app appearance option. `system` follows macOS, including automatic day/night changes.
enum AppAppearance: String, CaseIterable, Identifiable, Codable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system: L("appearance.system")
        case .light: L("appearance.light")
        case .dark: L("appearance.dark")
        }
    }

    var symbol: String {
        switch self {
        case .system: "desktopcomputer"
        case .light: "sun.max.fill"
        case .dark: "moon.fill"
        }
    }

    @MainActor
    func apply() {
        // Apply at the application level so SwiftUI windows, menu panels and the support popup agree.
        // A nil override restores macOS appearance inheritance and automatic system updates.
        switch self {
        case .system: NSApplication.shared.appearance = nil
        case .light: NSApplication.shared.appearance = NSAppearance(named: .aqua)
        case .dark: NSApplication.shared.appearance = NSAppearance(named: .darkAqua)
        }
    }
}
