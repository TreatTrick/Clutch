#!/usr/bin/env python3
"""Generates Clutch/Localizable.xcstrings. To add text, add an entry to STRINGS and rerun this script."""
import json
import pathlib

# key: (English, Simplified Chinese)
STRINGS = {
    "app.tagline": ("Hold a key, click your mouse, trigger a system gesture",
                    "按住键盘修饰键，再按鼠标按键，触发系统手势"),
    "common.enable": ("Enable", "启用"),

    "permission.title": ("Accessibility permission required", "需要辅助功能权限"),
    "permission.detail": ("Lets Clutch detect key + mouse combos in every app",
                          "用于在所有应用中识别键盘 + 鼠标组合"),
    "permission.grant": ("Grant Access", "去授权"),

    "modifier.title": ("Modifier Key", "修饰键"),
    "modifier.subtitle": ("Mouse shortcuts only work while this key is held",
                          "按住这个键时，鼠标快捷操作才会生效"),
    "modifier.option": ("Option", "Option"),
    "modifier.control": ("Control", "Control"),
    "modifier.command": ("Command", "Command"),
    "modifier.shift": ("Shift", "Shift"),
    "modifier.fn": ("Fn", "Fn"),

    "binding.title": ("Mouse Shortcuts", "鼠标快捷操作"),
    "binding.subtitle": ("Click a mouse button on the left to re-record it",
                         "点击左侧的鼠标按键可重新录制"),
    "binding.empty": ("No shortcuts yet. Add one below.", "还没有快捷操作，点下方按钮添加"),
    "binding.add": ("Add Shortcut", "添加快捷操作"),
    "binding.action": ("Action", "操作"),
    "binding.delete": ("Delete shortcut", "删除快捷操作"),
    "binding.recording": ("Press a mouse button…", "按下鼠标按键…"),
    "binding.recording.help": ("Press a mouse button or scroll the wheel. Esc to cancel.",
                               "按下鼠标按键或滚动滚轮，Esc 取消"),
    "binding.record.help": ("Click, then press a mouse button to record",
                            "点击后按下鼠标按键即可录制"),
    "binding.conflict": ("This mouse button is used more than once. Only the first one works.",
                         "这个鼠标按键被重复使用，只有第一个生效"),
    "binding.hotkeyDisabled": (
        "The matching shortcut is turned off in System Settings › Keyboard › Keyboard Shortcuts › Mission Control.",
        "对应的系统快捷键已关闭，请在“系统设置 › 键盘 › 键盘快捷键 › 调度中心”中开启"),
    "binding.tryIt %@": ("Hold %@ and use your mouse to try it", "按住 %@ 再操作鼠标试一试"),

    "trigger.right": ("Right Button", "右键"),
    "trigger.middle": ("Middle Button", "中键"),
    "trigger.back": ("Side Button · Back", "侧键 · 后退"),
    "trigger.forward": ("Side Button · Forward", "侧键 · 前进"),
    "trigger.button %lld": ("Button %lld", "按键 %lld"),
    "trigger.scrollUp": ("Scroll Up", "滚轮向上"),
    "trigger.scrollDown": ("Scroll Down", "滚轮向下"),
    "trigger.scrollLeft": ("Scroll Left", "滚轮向左"),
    "trigger.scrollRight": ("Scroll Right", "滚轮向右"),

    "action.previousSpace": ("Previous Desktop", "上一个桌面"),
    "action.nextSpace": ("Next Desktop", "下一个桌面"),
    "action.missionControl": ("Mission Control", "调度中心"),
    "action.appExpose": ("App Windows", "应用窗口"),
    "action.showDesktop": ("Show Desktop", "显示桌面"),
    "action.notificationCenter": ("Notification Center", "通知中心"),

    "gesture.previousSpace": ("3-finger swipe right · ⌃←", "三指右滑 · ⌃←"),
    "gesture.nextSpace": ("3-finger swipe left · ⌃→", "三指左滑 · ⌃→"),
    "gesture.missionControl": ("3-finger swipe up · ⌃↑", "三指上滑 · ⌃↑"),
    "gesture.appExpose": ("3-finger swipe down · ⌃↓", "三指下滑 · ⌃↓"),
    "gesture.showDesktop": ("Spread thumb and 3 fingers", "拇指与三指张开"),
    "gesture.notificationCenter": ("2-finger swipe from right edge", "两指从右边缘左滑"),

    "settings.launchAtLogin": ("Launch at login", "开机自动启动"),
    "settings.language": ("Language", "语言"),
    "settings.menuBarHint": ("Keeps running in the menu bar", "关闭窗口后仍在菜单栏运行"),
    "language.system": ("System", "跟随系统"),

    "menu.settings": ("Settings…", "设置…"),
    "menu.quit": ("Quit Clutch", "退出 Clutch"),
}


def unit(value):
    return {"stringUnit": {"state": "translated", "value": value}}


catalog = {
    "sourceLanguage": "en",
    "version": "1.0",
    "strings": {
        key: {
            "extractionState": "manual",
            "localizations": {"en": unit(en), "zh-Hans": unit(zh)},
        }
        for key, (en, zh) in sorted(STRINGS.items())
    },
}

out = pathlib.Path(__file__).resolve().parent.parent / "Clutch" / "Localizable.xcstrings"
out.write_text(json.dumps(catalog, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print(f"wrote {len(STRINGS)} strings to {out}")
