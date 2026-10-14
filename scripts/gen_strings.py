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
    "settings.menuBarHint": ("Keeps running in the menu bar", "关闭窗口后仍在菜单栏运行"),
    "language.system": ("System", "跟随系统"),

    "menu.settings": ("Settings…", "设置…"),
    "menu.support": ("Support Clutch", "支持 Clutch"),
    "support.button": ("Buy me a coffee", "请我喝杯咖啡"),

    "support.title": ("Buy me a coffee?", "请我喝杯咖啡吧？"),
    "support.subtitle": ("Clutch is free and open source. A small tip keeps it going.",
                         "Clutch 免费开源，一点小小的打赏就能让它走得更远。"),
    "support.usage %lld": ("You've triggered %lld gestures with Clutch. A small tip keeps it going.",
                           "你已经用 Clutch 触发了 %lld 次手势，一点小小的打赏就能让它走得更远。"),
    "support.method": ("Payment method", "支付方式"),
    "payment.wechat": ("WeChat", "微信"),
    "payment.alipay": ("Alipay", "支付宝"),
    "payment.payPal.caption": ("Scan with your phone, or open PayPal in the browser.",
                               "用手机扫码，或在浏览器中打开 PayPal。"),
    "payment.wechat.caption": ("Scan with WeChat to tip any amount.", "用微信扫一扫，金额随意。"),
    "payment.alipay.caption": ("Scan with Alipay to tip any amount.", "用支付宝扫一扫，金额随意。"),
    "support.paypal.open": ("Open PayPal", "打开 PayPal"),
    "support.demo": ("Demo code, not a real account", "演示二维码，并非真实账户"),
    "support.qr %@": ("%@ QR code", "%@ 二维码"),
    "support.star": ("Star", "Star"),
    "support.tipped": ("I've Tipped", "我已打赏"),
    "support.tipped.done": ("Tipped", "已打赏"),
    "support.starred": ("Starred", "已 Star"),
    "support.back": ("Back", "返回"),
    "support.thanks.title": ("Thank you!", "谢谢你！"),
    "support.thanks.detail": ("You just made a dragon maid very happy.", "龙女仆开心得跳起来了。"),
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
