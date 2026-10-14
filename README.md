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

## License

MIT
