import Foundation

/// In-app language option. `system` follows the macOS preferred language.
enum AppLanguage: String, CaseIterable, Identifiable, Codable {
    case system
    case english = "en"
    case simplifiedChinese = "zh-Hans"

    var id: String { rawValue }

    /// Language names stay in their own language so they're findable even if you can't read the current one
    var displayName: String {
        switch self {
        case .system: L("language.system")
        case .english: "English"
        case .simplifiedChinese: "简体中文"
        }
    }
}

/// Runtime language switching: loads the matching .lproj bundle
enum Localizer {
    private(set) static var bundle: Bundle = .main
    private(set) static var locale: Locale = .autoupdatingCurrent

    static func apply(_ language: AppLanguage) {
        guard language != .system,
              let path = Bundle.main.path(forResource: language.rawValue, ofType: "lproj"),
              let bundle = Bundle(path: path)
        else {
            self.bundle = .main
            locale = .autoupdatingCurrent
            return
        }
        self.bundle = bundle
        locale = Locale(identifier: language.rawValue)
    }
}

/// Looks up localized text; keys are defined in Localizable.xcstrings
func L(_ key: String) -> String {
    Localizer.bundle.localizedString(forKey: key, value: nil, table: nil)
}

func L(_ key: String, _ arguments: CVarArg...) -> String {
    String(format: L(key), locale: Localizer.locale, arguments: arguments)
}
