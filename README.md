# Clutch

Hold a keyboard modifier with one hand, press a mouse button with the other, and trigger macOS gestures: switch desktops, Mission Control, App Exposé, Show Desktop, Notification Center.

按住键盘修饰键，再按鼠标按键，即可触发 macOS 的系统手势功能，不用把手从鼠标挪到键盘。

## Build

Open `Clutch.xcodeproj` in Xcode 16+ and press ⌘R. Requires macOS 15+.

On first launch, grant Accessibility permission (System Settings › Privacy & Security › Accessibility). Clutch needs it to see mouse events in every app.

## How it works

- A `CGEventTap` watches mouse buttons and the scroll wheel. When the chosen modifier is held and the button is bound, the event is swallowed and the action runs.
- Previous / next desktop posts the system shortcut set in System Settings › Keyboard › Keyboard Shortcuts › Mission Control (default ⌃← / ⌃→).
- Mission Control, App Windows and Show Desktop are sent to the Dock directly.
- Notification Center is opened by pressing the menu bar clock through the Accessibility API.

## Localization

Strings live in `Clutch/Localizable.xcstrings` (English and Simplified Chinese). Edit `scripts/gen_strings.py` and run `python3 scripts/gen_strings.py` to regenerate it.

## App icon

The icon is drawn in code. Edit `scripts/make_icon.swift` and run `swift scripts/make_icon.swift` to regenerate `Clutch/Assets.xcassets/AppIcon.appiconset`.

## Support popup

After Clutch has been used on 3 different days, a small "buy me a coffee" popup appears once during the day (10:00–19:00), a few seconds after a shortcut fires. It is skipped while a full-screen app is in front, snoozed for 14 days when closed, and never shown again after 3 dismissals or after the user tips or stars. It can always be opened from the menu bar.

The QR codes and links in `SupportLinks` / `PaymentMethod` are demo placeholders.

The mascot comes from `sadtohappy2.mp4` (dejected → overjoyed, scrubbed by the mouse) and `happyJump2.mp4` (a looping jump after a star or tip). They are bundled as `MascotA.heic` and `MascotB.heic`, respectively. Regenerate the bundled frames with the mouse-interaction clip first, then the celebration clip:

```
swift scripts/make_mascot.swift <path-to-sadtohappy2.mp4> <path-to-happyJump2.mp4>
```

## License

MIT
