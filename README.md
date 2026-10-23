<div align="center">

<!-- TODO: keep docs/assets/icon.png in sync with AppIcon (256×256 PNG displayed at 128 px) -->
<img src="docs/assets/icon.png" width="128" alt="MouseSpell app icon">

# MouseSpell

### All the Trackpad Gestures. None of the Trackpad.

Hold a key. Click the mouse. Trigger a gesture.

**English** · [简体中文](README.zh-CN.md)

[Website](https://treattrick.github.io/MouseSpell/) · [中文官网](https://treattrick.github.io/MouseSpell/zh/) · [日本語](https://treattrick.github.io/MouseSpell/ja/)

[![macOS 15+](https://img.shields.io/badge/macOS-15%2B-000000?logo=apple&logoColor=white)](#-install)
[![Swift](https://img.shields.io/badge/Swift-5-F05138?logo=swift&logoColor=white)](https://swift.org)
[![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-0A84FF?logo=swift&logoColor=white)](https://developer.apple.com/xcode/swiftui/)
[![License: MIT](https://img.shields.io/badge/License-MIT-34C759)](#-license)
[![Languages](https://img.shields.io/badge/i18n-English%20%7C%20%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87%20%7C%20%E6%97%A5%E6%9C%AC%E8%AA%9E-FF9F0A)](#-localization)
[![GitHub stars](https://img.shields.io/github/stars/TreatTrick/MouseSpell?style=social)](https://github.com/TreatTrick/MouseSpell)

[Download v1.0.1](https://github.com/TreatTrick/MouseSpell/releases/download/v1.0.1/MouseSpell-v1.0.1-universal.dmg) · [Install](#-install) · [How it works](#-three-steps-to-your-first-shortcut) · [Meet the maid](#-meet-the-maid) · [Under the hood](#-under-the-hood)

<br>

<!-- TODO: expand desktop-switching-demo.gif with Mission Control and Show Desktop (aim for about 1200×700, under 10 MB)
     Hand on the mouse, Control held: click the forward side button → desktop slides left;
     click the back side button → desktop slides right.
     ⌥ + middle click → Mission Control opens, ⌥ + scroll down → Show Desktop.
     A keystroke overlay (e.g. KeyCastr) in the corner helps viewers follow along.
     The current desktop-switching-demo.gif is converted from a recording; the editable illustration remains in desktop-switching-demo.svg. -->
<img src="docs/assets/desktop-switching-demo.gif" width="860" alt="MouseSpell demo: Control + the forward mouse button slides the desktop left; Control + the back mouse button slides it right">

</div>

<br>

## 🖱️ Why MouseSpell?

macOS hides some of its best features behind trackpad gestures: swipe between desktops, swipe up for Mission Control, spread your fingers to see the desktop. On a mouse, you're left with keyboard shortcuts, which means taking your hand off the mouse right in the middle of what you're doing.

MouseSpell adds a second option. Rest one hand on the keyboard and keep the other on the mouse. Hold a modifier key, press a mouse button or turn the wheel, and the gesture fires. Your mouse hand stays where it is.

<table>
<tr>
<td width="50%" valign="top">

#### ✋ Without MouseSpell
Reach over for <kbd>⌃</kbd> <kbd>→</kbd>, find your place, go back to the mouse, aim the cursor again.

</td>
<td width="50%" valign="top">

#### ⚡ With MouseSpell
Hold <kbd>⌥</kbd>, click the forward side button. You're on the next desktop and your hand hasn't moved.

</td>
</tr>
</table>

## ✨ What it can do

Bind any of six system features to any combination of a modifier and a mouse trigger.

| | Action | Replaces this trackpad gesture | Example binding |
|:-:|---|---|---|
| ⬅️ | **Previous Desktop** | 3-finger swipe right | <kbd>⌥</kbd> + Back button |
| ➡️ | **Next Desktop** | 3-finger swipe left | <kbd>⌥</kbd> + Forward button |
| 🪟 | **Mission Control** | 3-finger swipe up | <kbd>⌥</kbd> + Middle click |
| 🗂️ | **App Windows** (App Exposé) | 3-finger swipe down | <kbd>⌃</kbd> + Middle click |
| 🖥️ | **Show Desktop** | Spread thumb and 3 fingers | <kbd>⌥</kbd> + Scroll down |
| 🔔 | **Notification Center** | 2-finger swipe from right edge | <kbd>⌥</kbd> + Right click |

**Modifiers:** <kbd>⌥ Option</kbd> <kbd>⌃ Control</kbd> <kbd>⌘ Command</kbd> <kbd>⇧ Shift</kbd> <kbd>fn</kbd>

**Mouse triggers:** right click, middle click, back and forward side buttons, extra buttons (6, 7, …), and scrolling in any of four directions. The left button is left alone so ordinary clicks never get caught.

## 🎯 Three steps to your first shortcut

No preference panes or dropdowns. MouseSpell asks for one thing at a time and records what you actually press.

<!-- TODO: step1.png, the recorder on step 1 showing the five large keycaps -->
<!-- TODO: step2.png, step 2 with the chosen keycap, "+" and the bouncing dashed mouse -->
<!-- TODO: step3.png, step 3 with the 3×2 grid of action tiles -->
<!-- TODO: refresh shortcut-setup-steps.gif when the recorder flow changes, from step 1 to the green ✓ "Shortcut added" screen -->
<p align="center"><img src="docs/assets/shortcut-setup-steps.gif" width="600" alt="Three steps to add a shortcut, with synchronized STEP 1, STEP 2, and STEP 3 captions: press a key, press a mouse button, then pick an action"></p>

1. **Press a key.** Hold ⌥, ⌃, ⌘, ⇧ or fn. MouseSpell picks it up straight away.
2. **Press a mouse button.** Click, side-click or scroll. If that combo is already taken, MouseSpell warns you before you continue.
3. **Pick an action.** Each tile shows the trackpad gesture it replaces.

Changed your mind? Use **Back**, press <kbd>Esc</kbd>, or click any completed step to redo it. Saved shortcuts appear in a plain list, and you remove one with the trash button.

## 🐉 Meet the maid

MouseSpell is free and open source. After you've used it for a while, a small dragon maid drops by to ask for a coffee. She **follows your cursor**:

- 😢 move toward the close button and she gets sadder, frame by frame
- 🥰 move anywhere else and she perks up
- 🎉 star the repo or support the app and she jumps for joy

<div align="center">

<!-- TODO: optional mascot video version. Drag docs/assets/mascot.mp4 into the GitHub README editor and replace this
     block with the generated https://github.com/user-attachments/assets/… URL on its own line,
     which GitHub renders as an inline player. Source clips: sad2Happy3.mp4 (mood) and happyJump2.mp4 (celebration). -->
<!-- TODO: refresh mascot-interaction-demo.gif when the support popup changes, including how it slides in while the cursor moves
     toward the close button (she gets sad) and then back to the support button (she cheers up) -->
<img src="docs/assets/mascot-interaction-demo.gif" width="560" alt="The dragon maid and support popup: the mascot reacts to the cursor">

</div>

She's polite about it:

- She shows up **at most twice**, after **3** and after **7** separate days on which you actually used a shortcut. She never shows up twice on the same day.
- Only between **10:00 and 19:00**, a few seconds after a shortcut fires, and never over a full-screen app.
- After you support the app or visit GitHub, she doesn't come back on her own.
- You can still call her from the ☕ button in the footer or the menu bar. Opening her yourself never counts as a reminder.

She also lives in the settings window footer, next to the coffee button, and watches your cursor there too. Reduce Motion is respected.

## 🧩 Thoughtful details

<table>
<tr>
<td width="50%" valign="top">

🔐 **Permission first.** The first screen does one thing: grant Accessibility. MouseSpell notices the change on its own, and if macOS gets stuck there's a one-click reset.

🌗 **Light, dark or system.** Pick an appearance from Preferences. It applies instantly and is remembered.

🌐 **English, 简体中文 and 日本語.** Switch language inside the app, no restart needed.

</td>
<td width="50%" valign="top">

📍 **Lives in the menu bar.** Toggle MouseSpell on or off, check your shortcuts, or open settings from there. The icon dims when MouseSpell is paused.

🚀 **Launch at login.** One checkbox. MouseSpell starts quietly without opening its window.

⚠️ **Honest warnings.** If a desktop-switch shortcut is disabled in System Settings, the list tells you so you aren't left guessing.

</td>
</tr>
</table>

<!-- TODO: keep settings.png (light) and settings-dark.png (dark) in sync with the shortcut recorder UI.
     Optionally swap in a <picture> element with prefers-color-scheme to match the reader's theme. -->
<p align="center">
  <img src="docs/assets/settings.png" width="49%" alt="Settings window, light appearance">
  <img src="docs/assets/settings-dark.png" width="49%" alt="Settings window, dark appearance">
</p>

## 🔒 Privacy

MouseSpell needs **Accessibility** permission so it can see mouse events in every app. That's all it uses the permission for.

- It only reacts when a modifier you bound is held together with a mouse trigger you bound. Everything else passes through untouched.
- It makes no network requests and has no analytics. Usage counts stay in local `UserDefaults` and only decide when the maid appears.
- It's open source, so you can check all of this yourself.

## 📦 Install

<!-- TODO: keep the versioned download links in sync with future GitHub Releases -->

**[Download MouseSpell v1.0.1 — Universal DMG](https://github.com/TreatTrick/MouseSpell/releases/download/v1.0.1/MouseSpell-v1.0.1-universal.dmg)** · [All releases](https://github.com/TreatTrick/MouseSpell/releases)

Requirements: macOS 15 Sequoia or later, on **Apple Silicon or Intel**.

> [!NOTE]
> This release is signed with an Apple Developer ID certificate and notarized by Apple. macOS verifies the app when you open it.

1. Open the downloaded **DMG**, then drag **MouseSpell** onto the **Applications** shortcut in the installer window. You can also double-click **INSTALL.html** in that window to read this guide offline, with buttons to switch between English and Simplified Chinese.
2. Open MouseSpell from **Applications**. If macOS asks whether to open it, verify the app name and choose **Open**.
3. In MouseSpell, click **Open System Settings** and enable MouseSpell under **Privacy & Security › Accessibility**. MouseSpell picks up the change by itself.

To add your first shortcut, hold a modifier key in the recorder, press a mouse button or scroll, then choose an action. See [the three-step guide](#-three-steps-to-your-first-shortcut). MouseSpell keeps running in the menu bar when you close its window. After copying the app, you can eject the installer disk.

> [!TIP]
> Desktop switching uses the system shortcuts in *System Settings › Keyboard › Keyboard Shortcuts › Mission Control* ("Move left/right a space"). Keep them enabled; their key combination doesn't matter.

## 🌐 Localization

MouseSpell ships in **English**, **简体中文** and **日本語**, and you can switch languages from *Preferences* at any time, or follow your system language. To add a language, add a column to `scripts/gen_strings.py`, regenerate, add an option to `AppLanguage` in `MouseSpell/Localization.swift`, and add the region to the Xcode project. Pull requests are welcome.

## 🤝 Contributing

Bug reports, ideas and PRs are all welcome. Some good places to start:

- More actions (Launchpad, Spotlight, screenshot, …)
- More languages
- Better behavior on multi-display setups

Please keep code comments in English, and run the app through the recorder flow once before you open a PR.

## ☕ Support

If MouseSpell saves your mouse hand a trip to the keyboard:

- ⭐ **Star this repo.** It helps other people find MouseSpell, and the maid gets very happy.
- ☕ **Tip with PayPal, WeChat, or Alipay.** Open the coffee button in MouseSpell to choose a payment method. After tipping, choose **I've Supported** to turn off automatic reminders.

<!-- TODO: keep the PayPal link in sync when replacing the bundled payment QR images -->
The app includes payment QR codes for PayPal, WeChat, and Alipay. You can also open PayPal directly in your browser.

<div align="center">

<!-- TODO: keep mascot-jump.gif in sync with the celebration clip (MascotB), preserving its transparent background -->
<img src="docs/assets/mascot-jump.gif" width="180" alt="The dragon maid jumping for joy">

<sub>Thank you. She means it.</sub>

</div>

## 📄 License

[MIT](LICENSE) © MouseSpell contributors
