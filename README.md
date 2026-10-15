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

## Appearance

The header's Preferences menu groups appearance and language settings. Choose Follow System (the default), Light, or Dark. The choice applies immediately to the app's windows and panels and is restored on the next launch. Follow System responds automatically to macOS appearance changes.

## App icon

The icon is drawn in code. Edit `scripts/make_icon.swift` and run `swift scripts/make_icon.swift` to regenerate `Clutch/Assets.xcassets/AppIcon.appiconset`.

## Support popup

The free edition offers a small "buy me a coffee" popup at two milestones: 3 and 7 distinct days on which a shortcut has actually been used. Each milestone can trigger only once, for at most two automatic reminders in total. The popup appears during the day (10:00–19:00), a few seconds after a shortcut fires, and avoids full-screen apps. If a milestone is delayed, it can appear at the next suitable opportunity; once the 7-day milestone is reached, an earlier missed reminder is not shown separately. Reminder records are saved when the popup appears, so closing it or restarting the app does not repeat a milestone, and two automatic reminders never appear on the same local day. App Store purchasers, users who confirm support, and users who visit GitHub receive no further automatic reminders. The popup can always be opened manually from the footer or menu bar without consuming a reminder.

"I've Supported" remembers the user's confirmation across launches, changes the footer and menu entry to the supported state, and keeps GitHub Star available. Opening the App Store alone never marks a purchase as complete; opening GitHub never claims a verified Star. Existing settings remain compatible, and older Star acknowledgements are not treated as purchases.

In Debug builds, hold Option and click the footer's coffee / supported button or the menu bar's support entry to reset local support confirmation and automatic-reminder records, then reopen the popup. Shortcuts, total usage count, and active days are preserved; the footer mascot returns to its mouse-following state. This does not override a verified production App Store purchase. The hidden reset action is excluded from Release builds.

App Store downloads are recognized through a verified StoreKit `AppTransaction` in the production environment with a matching bundle ID. A receipt-file presence check skips StoreKit requests for GitHub builds, avoiding unnecessary Apple Account prompts. Failed recognition does not restrict use; manual support confirmation is always available. Actual App Store purchase recognition needs verification with a production App Store installation.

Both URLs in `SupportLinks` (`Clutch/SupportController.swift`) are demo placeholders, as indicated in the popup. Replace `appStore` with the released app's `https://apps.apple.com/app/id…` URL and `gitHub` with the real repository URL before publishing.

The settings footer is 104 pt high, with a small mascot to the left of the coffee button. It uses the same mood clip at 24 fps: moving toward the coffee button cheers her up, moving away makes her sad, and hovering over the button keeps her happy. Small jitters are ignored; playback continues toward its endpoint when the mouse rests and pauses when the settings scene becomes inactive.

The mascot comes from `sad2Happy3.mp4` (dejected → overjoyed) and `happyJump2.mp4` (a looping jump after visiting GitHub or confirming support). They are bundled as `MascotA.heic` and `MascotB.heic`, respectively. Only within the intersection of the popup's rightmost quarter and topmost quarter (the upper-right 1/16) does approaching the close button play the mood clip backward; hovering over the close button also plays backward. Moving away plays forward, and every position outside that area always plays toward happiness. Mouse movement only selects the direction: playback stays at the video's original 24 fps, continues toward the endpoint when the mouse rests, and ignores small jitters. A GitHub visit or support confirmation finishes the mood clip from its current frame at the same speed before the celebration begins. Reopening after purchase or confirmation preserves the celebration and supported state.

Regenerate the bundled frames with the mouse-interaction clip first, then the celebration clip:

```
swift scripts/make_mascot.swift <path-to-sad2Happy3.mp4> <path-to-happyJump2.mp4>
```

## License

MIT
