#!/usr/bin/env python3
"""Generates Clutch/Localizable.xcstrings. To add text, add an entry to STRINGS and rerun this script."""
import json
import pathlib

# key: (English, Simplified Chinese)
STRINGS = {
    "app.tagline": ("Hold a key, press a mouse button, trigger a system gesture",
                    "按住键盘按键，再按鼠标按键，触发系统手势"),
    "common.enable": ("Enable", "启用"),
    "common.on": ("On", "已开启"),
    "common.off": ("Off", "已暂停"),
    "common.enabled.help": ("Clutch is on. Turn off to pause all shortcuts.", "Clutch 已开启，关闭后所有快捷键暂停"),
    "common.disabled.help": ("Clutch is paused. Turn on to use your shortcuts.", "Clutch 已暂停，开启后快捷键恢复生效"),

    "permission.title": ("Allow Clutch to use Accessibility", "允许 Clutch 使用辅助功能"),
    "permission.detail": (
        "Clutch needs this to notice when you hold a key and press a mouse button in any app. Turn on Clutch in the list that opens.",
        "Clutch 需要它来识别你在任意应用中按住键盘并按下鼠标按键的操作。请在打开的列表中开启 Clutch。"),
    "permission.grant": ("Open System Settings", "打开系统设置"),
    "permission.reopen": ("Open System Settings Again", "再次打开系统设置"),
    "permission.waiting": ("Waiting for permission… Clutch continues automatically.",
                           "等待授权中… 授权后会自动继续"),
    "permission.stuck": ("Already turned on but still waiting? An older copy of Clutch may be the one in the list.",
                         "已经打开了却还在等待？列表里的可能是旧版本的 Clutch。"),
    "permission.reset": ("Remove the old entry and try again", "清除旧的授权记录并重新授权"),
    "permission.privacy": ("Clutch never records what you type.", "Clutch 不会记录你输入的任何内容"),

    "modifier.option": ("Option", "Option"),
    "modifier.control": ("Control", "Control"),
    "modifier.command": ("Command", "Command"),
    "modifier.shift": ("Shift", "Shift"),
    "modifier.fn": ("Fn", "Fn"),

    "recorder.step.key": ("Key", "键盘按键"),
    "recorder.step.mouse": ("Mouse", "鼠标按键"),
    "recorder.step.action": ("Action", "操作"),
    "recorder.step.redo": ("Redo from this step", "从这一步重新开始"),
    "recorder.back": ("Back", "上一步"),
    "recorder.back.help": ("Go back one step (Esc)", "返回上一步（Esc）"),
    "recorder.key.title": ("Press one of these keys", "按下其中任意一个键"),
    "recorder.key.detail": ("This is the key you'll hold with your other hand",
                            "使用时，用另一只手按住这个键"),
    "recorder.mouse.title": ("Now press a mouse button", "现在按下一个鼠标按键"),
    "recorder.mouse.detail": ("Side buttons, middle click, right click, or scroll the wheel",
                              "侧键、中键、右键，或滚动滚轮都可以"),
    "recorder.mouse.conflict %@": ("Already used for “%@”. Try another button.",
                                   "这个组合已用于“%@”，换一个按键试试"),
    "recorder.action.title": ("Choose what it does", "选择要触发的操作"),
    "recorder.done.title": ("Shortcut added", "快捷键已添加"),

    "list.title": ("Your Shortcuts", "我的快捷键"),
    "list.empty": ("Shortcuts you add will appear here", "添加的快捷键会显示在这里"),
    "list.remove": ("Remove shortcut", "移除快捷键"),
    "list.hotkeyDisabled": (
        "The matching shortcut is turned off in System Settings › Keyboard › Keyboard Shortcuts › Mission Control.",
        "对应的系统快捷键已关闭，请在“系统设置 › 键盘 › 键盘快捷键 › 调度中心”中开启"),

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

    "gesture.previousSpace": ("3-finger swipe right", "三指右滑"),
    "gesture.nextSpace": ("3-finger swipe left", "三指左滑"),
    "gesture.missionControl": ("3-finger swipe up", "三指上滑"),
    "gesture.appExpose": ("3-finger swipe down", "三指下滑"),
    "gesture.showDesktop": ("Spread thumb and 3 fingers", "拇指与三指张开"),
    "gesture.notificationCenter": ("2-finger swipe from right edge", "两指从右边缘左滑"),

    "settings.launchAtLogin": ("Launch at login", "开机自动启动"),
    "settings.language": ("Language", "语言"),
    "settings.appearance": ("Appearance", "外观"),
    "settings.preferences": ("Preferences", "偏好设置"),
    "settings.preferences.help": ("Appearance and language", "外观与语言"),
    "settings.menuBarHint": ("Keeps running in the menu bar", "关闭窗口后仍在菜单栏运行"),
    "language.system": ("System", "跟随系统"),
    "appearance.system": ("Follow System", "跟随系统"),
    "appearance.light": ("Light", "浅色"),
    "appearance.dark": ("Dark", "深色"),

    "menu.settings": ("Settings…", "设置…"),
    "menu.support": ("Support Clutch", "支持 Clutch"),
    "support.button": ("Buy me a coffee", "请我喝杯咖啡"),

    "support.title": ("Buy me a coffee?", "请我喝杯咖啡吧？"),
    "support.subtitle": ("Clutch is free and open source. Buying the App Store edition helps Clutch go further.",
                         "Clutch 免费开源，购买 App Store 版支持，可让 Clutch 走得更远。"),
    "support.usage %lld": ("You've used Clutch's shortcuts %lld times.\nIf Clutch has helped you, buying the App Store edition helps Clutch go further.",
                           "你已经使用 Clutch 的快捷键 %lld 次。\n如果 Clutch 帮到了你，可以前往 App Store 购买支持，让 Clutch 走得更远。"),
    "support.store.title": ("Support with the App Store", "通过 App Store 支持"),
    "support.store.detail": ("A one-time purchase supports Clutch's development.",
                             "一次购买，支持 Clutch 后续开发。"),
    "support.store.open": ("Support on the App Store", "在 App Store 购买支持"),
    "support.store.help": ("Open the App Store to buy Clutch. The GitHub edition stays free.",
                           "打开 App Store 购买 Clutch，GitHub 版仍可免费使用。"),
    "support.store.opened": ("After buying, choose “I've Supported” to stop purchase reminders.",
                             "购买后，点击“我已支持”即可停止购买提醒。"),
    "support.store.purchased": ("You purchased Clutch on the App Store. Thank you!",
                               "你已通过 App Store 购买，感谢支持！"),
    "support.already": ("I've Supported", "我已支持"),
    "support.confirm.help": ("Remember my support and stop purchase reminders.",
                             "记住我的支持，不再提醒购买。"),
    "support.confirmed.detail": ("Your support is remembered. No more purchase reminders.",
                                 "已记下你的支持，不再提醒购买。"),
    "support.supported.help": ("Thank you! You can still visit GitHub and give Clutch a Star.",
                               "感谢支持！仍可打开 GitHub 为 Clutch 点 Star。"),
    "support.debug.reset.help": ("Debug: Option-click to reset local support and reminder records.",
                                 "调试：按住 Option 点击，重置本地支持状态和提醒记录。"),
    "support.received": ("Coffee received. Thank you!", "咖啡收到啦，谢谢你！"),
    "support.demo": ("Demo links. Replace them before publishing.", "当前为演示链接，正式发布前替换。"),
    "support.link.failed": ("Couldn't open the link. Please try again.", "暂时无法打开链接，请重试。"),
    "support.star": ("Star on GitHub", "去 GitHub 点 Star"),
    "support.github.help": ("Open Clutch's GitHub page. Giving a Star is optional.",
                            "打开 Clutch 的 GitHub 项目页，点 Star 完全自愿。"),
    "support.github.detail": ("A free Star helps more people discover Clutch.",
                              "免费点一颗 Star，也能让更多人发现 Clutch。"),
    "support.github.opened": ("GitHub is open. Give Clutch a Star there if you'd like!",
                              "已打开 GitHub，喜欢的话可以在那里点一颗 Star！"),
    "support.thanks.title": ("Thanks for the coffee!", "谢谢你的咖啡！"),
    "support.thanks.detail": ("Your support keeps Clutch going. You made a dragon maid very happy.",
                             "你的支持让 Clutch 走得更远，龙女仆也开心得跳起来了。"),
    "support.close": ("Close", "关闭"),
    "menu.addFirst": ("Add your first shortcut…", "添加第一个快捷键…"),
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
