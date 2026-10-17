#!/usr/bin/env python3
"""Generates Clutch/Localizable.xcstrings. To add text, add an entry to STRINGS and rerun this script."""
import json
import pathlib

# key: (English, Simplified Chinese, Japanese)
STRINGS = {
    "app.tagline": ("Hold a key, press a mouse button, trigger a system gesture",
                    "按住键盘按键，再按鼠标按键，触发系统手势",
                    "キーを押しながらマウス操作でジェスチャを実行"),
    "common.enable": ("Enable", "启用", "有効にする"),
    "common.on": ("On", "已开启", "オン"),
    "common.off": ("Off", "已暂停", "一時停止中"),
    "common.enabled.help": ("Clutch is on. Turn off to pause all shortcuts.", "Clutch 已开启，关闭后所有快捷键暂停",
                            "Clutch は有効です。オフにするとすべてのショートカットを一時停止します。"),
    "common.disabled.help": ("Clutch is paused. Turn on to use your shortcuts.", "Clutch 已暂停，开启后快捷键恢复生效",
                             "Clutch は一時停止中です。オンにするとショートカットを使えます。"),

    "permission.title": ("Allow Clutch to use Accessibility", "允许 Clutch 使用辅助功能", "Clutch のアクセシビリティを許可"),
    "permission.detail": (
        "Clutch needs this to notice when you hold a key and press a mouse button in any app. Turn on Clutch in the list that opens.",
        "Clutch 需要它来识别你在任意应用中按住键盘并按下鼠标按键的操作。请在打开的列表中开启 Clutch。",
        "どのアプリでもキーとマウスボタンの同時操作を検出するために必要です。表示される一覧で Clutch をオンにしてください。"),
    "permission.grant": ("Open System Settings", "打开系统设置", "システム設定を開く"),
    "permission.reopen": ("Open System Settings Again", "再次打开系统设置", "システム設定をもう一度開く"),
    "permission.waiting": ("Waiting for permission… Clutch continues automatically.",
                           "等待授权中… 授权后会自动继续",
                           "許可を待っています… 許可後に自動で続行します。"),
    "permission.stuck": ("Already turned on but still waiting? An older copy of Clutch may be the one in the list.",
                         "已经打开了却还在等待？列表里的可能是旧版本的 Clutch。",
                         "オンにしても進まない場合、一覧に登録されているのが古い Clutch かもしれません。"),
    "permission.reset": ("Remove the old entry and try again", "清除旧的授权记录并重新授权", "古い登録を削除して再試行"),
    "permission.privacy": ("Clutch never records what you type.", "Clutch 不会记录你输入的任何内容", "Clutch は入力内容を記録しません。"),

    "modifier.option": ("Option", "Option", "Option"),
    "modifier.control": ("Control", "Control", "Control"),
    "modifier.command": ("Command", "Command", "Command"),
    "modifier.shift": ("Shift", "Shift", "Shift"),
    "modifier.fn": ("Fn", "Fn", "Fn"),

    "recorder.step.key": ("Key", "键盘按键", "キー"),
    "recorder.step.mouse": ("Mouse", "鼠标按键", "マウス"),
    "recorder.step.action": ("Action", "操作", "アクション"),
    "recorder.step.redo": ("Redo from this step", "从这一步重新开始", "このステップからやり直す"),
    "recorder.back": ("Back", "上一步", "戻る"),
    "recorder.back.help": ("Go back one step (Esc)", "返回上一步（Esc）", "前のステップに戻る（Esc）"),
    "recorder.key.title": ("Press one of these keys", "按下其中任意一个键", "いずれかのキーを押してください"),
    "recorder.key.detail": ("This is the key you'll hold with your other hand",
                            "使用时，用另一只手按住这个键", "使用時に、もう片方の手で押し続けるキーです"),
    "recorder.mouse.title": ("Now press a mouse button", "现在按下一个鼠标按键", "次にマウスボタンを押してください"),
    "recorder.mouse.detail": ("Side buttons, middle click, right click, or scroll the wheel",
                              "侧键、中键、右键，或滚动滚轮都可以", "サイドボタン、中央ボタン、右ボタン、またはホイール操作"),
    "recorder.mouse.conflict %@": ("Already used for “%@”. Try another button.",
                                   "这个组合已用于“%@”，换一个按键试试", "「%@」に使用済みです。別のボタンを試してください。"),
    "recorder.action.title": ("Choose what it does", "选择要触发的操作", "アクションを選択"),
    "recorder.done.title": ("Shortcut added", "快捷键已添加", "ショートカットを追加しました"),

    "list.title": ("Your Shortcuts", "我的快捷键", "ショートカット"),
    "list.empty": ("Shortcuts you add will appear here", "添加的快捷键会显示在这里", "追加したショートカットがここに表示されます"),
    "list.remove": ("Remove shortcut", "移除快捷键", "ショートカットを削除"),
    "list.hotkeyDisabled": (
        "The matching shortcut is turned off in System Settings › Keyboard › Keyboard Shortcuts › Mission Control.",
        "对应的系统快捷键已关闭，请在“系统设置 › 键盘 › 键盘快捷键 › 调度中心”中开启",
        "対応するショートカットが無効です。「システム設定 › キーボード › キーボードショートカット › Mission Control」で有効にしてください。"),

    "trigger.right": ("Right Button", "右键", "右ボタン"),
    "trigger.middle": ("Middle Button", "中键", "中央ボタン"),
    "trigger.back": ("Side Button · Back", "侧键 · 后退", "サイドボタン · 戻る"),
    "trigger.forward": ("Side Button · Forward", "侧键 · 前进", "サイドボタン · 進む"),
    "trigger.button %lld": ("Button %lld", "按键 %lld", "ボタン %lld"),
    "trigger.scrollUp": ("Scroll Up", "滚轮向上", "上にスクロール"),
    "trigger.scrollDown": ("Scroll Down", "滚轮向下", "下にスクロール"),
    "trigger.scrollLeft": ("Scroll Left", "滚轮向左", "左にスクロール"),
    "trigger.scrollRight": ("Scroll Right", "滚轮向右", "右にスクロール"),

    "action.previousSpace": ("Previous Desktop", "上一个桌面", "前のデスクトップ"),
    "action.nextSpace": ("Next Desktop", "下一个桌面", "次のデスクトップ"),
    "action.missionControl": ("Mission Control", "调度中心", "Mission Control"),
    "action.appExpose": ("App Windows", "应用窗口", "アプリのウインドウ"),
    "action.showDesktop": ("Show Desktop", "显示桌面", "デスクトップを表示"),
    "action.notificationCenter": ("Notification Center", "通知中心", "通知センター"),

    "gesture.previousSpace": ("3-finger swipe right", "三指右滑", "3本指で右にスワイプ"),
    "gesture.nextSpace": ("3-finger swipe left", "三指左滑", "3本指で左にスワイプ"),
    "gesture.missionControl": ("3-finger swipe up", "三指上滑", "3本指で上にスワイプ"),
    "gesture.appExpose": ("3-finger swipe down", "三指下滑", "3本指で下にスワイプ"),
    "gesture.showDesktop": ("Spread thumb and 3 fingers", "拇指与三指张开", "親指と3本の指を広げる"),
    "gesture.notificationCenter": ("2-finger swipe from right edge", "两指从右边缘左滑", "右端から2本指で左にスワイプ"),

    "settings.launchAtLogin": ("Launch at login", "开机自动启动", "ログイン時に起動"),
    "settings.language": ("Language", "语言", "言語"),
    "settings.appearance": ("Appearance", "外观", "外観"),
    "settings.preferences": ("Preferences", "偏好设置", "環境設定"),
    "settings.preferences.help": ("Appearance and language", "外观与语言", "外観と言語"),
    "settings.menuBarHint": ("Keeps running in the menu bar", "关闭窗口后仍在菜单栏运行", "閉じてもメニューバーで動作します"),
    "language.system": ("System", "跟随系统", "システムに従う"),
    "appearance.system": ("Follow System", "跟随系统", "システムに従う"),
    "appearance.light": ("Light", "浅色", "ライト"),
    "appearance.dark": ("Dark", "深色", "ダーク"),

    "menu.settings": ("Settings…", "设置…", "設定…"),
    "menu.support": ("Support Clutch", "支持 Clutch", "Clutch を応援"),
    "support.button": ("Buy me a coffee", "请我喝杯咖啡", "コーヒーで応援"),

    "support.title": ("Buy me a coffee?", "请我喝杯咖啡吧？", "コーヒーで応援しませんか？"),
    "support.subtitle": ("Clutch is free and open source. A small tip helps it go further.",
                         "Clutch 免费开源，一点小小的打赏，就能让它走得更远。",
                         "Clutch は無料でオープンソースです。少しの支援が、これからの開発を支えます。"),
    "support.usage %lld": ("You've used Clutch's shortcuts %lld times.",
                           "你已经使用 Clutch 的快捷键 %lld 次。",
                           "Clutch のショートカットを %lld 回使いました。"),
    "support.method": ("Payment method", "支付方式", "支払い方法"),
    "payment.wechat": ("WeChat", "微信", "WeChat"),
    "payment.alipay": ("Alipay", "支付宝", "Alipay"),
    "payment.payPal.caption": ("Scan with your phone, or open PayPal in the browser.",
                               "用手机扫码，或在浏览器中打开 PayPal。",
                               "スマートフォンで読み取るか、ブラウザで PayPal を開いてください。"),
    "payment.wechat.caption": ("Scan with WeChat to tip any amount.",
                               "用微信扫一扫，金额随意。", "WeChat で読み取って、好きな金額で応援できます。"),
    "payment.alipay.caption": ("Scan with Alipay to tip any amount.",
                               "用支付宝扫一扫，金额随意。", "Alipay で読み取って、好きな金額で応援できます。"),
    "support.paypal.open": ("Open PayPal", "打开 PayPal", "PayPal を開く"),
    "support.paypal.opened": ("PayPal is open. After tipping, choose “I've Supported”.",
                             "已打开 PayPal，打赏后可点击“我已支持”。",
                             "PayPal を開きました。支援後に「応援済み」を選んでください。"),
    "support.qr %@": ("%@ QR code", "%@ 收款二维码", "%@ の支援用 QR コード"),
    "support.payment.show": ("View payment codes", "查看收款码", "支援用 QR コードを見る"),
    "support.back": ("Back", "返回", "戻る"),
    "support.already": ("I've Supported", "我已支持", "応援済み"),
    "support.confirm.help": ("Remember my support and stop automatic support reminders.",
                             "记住我的支持，不再自动提醒打赏。", "応援済みとして記録し、自動の支援案内を停止します。"),
    "support.confirmed.detail": ("Your support is remembered. No more automatic reminders.",
                                 "已记下你的支持，不再自动提醒打赏。", "応援を記録しました。自動の支援案内はもう表示しません。"),
    "support.supported.help": ("Thank you! You can still visit GitHub and give Clutch a Star.",
                               "感谢支持！仍可打开 GitHub 为 Clutch 点 Star。",
                               "応援ありがとうございます！GitHub で Clutch に Star を付けることもできます。"),
    "support.debug.reset.help": ("Debug: Option-click to reset local support and reminder records.",
                                 "调试：按住 Option 点击，重置本地支持状态和提醒记录。",
                                 "デバッグ：Option キーを押しながらクリックすると、ローカルの応援状態と案内履歴をリセットします。"),
    "support.received": ("Coffee received. Thank you!", "咖啡收到啦，谢谢你！", "コーヒーをありがとう！"),
    "support.link.failed": ("Couldn't open the link. Please try again.", "暂时无法打开链接，请重试。",
                            "リンクを開けませんでした。もう一度お試しください。"),
    "support.star": ("Star on GitHub", "去 GitHub 点 Star", "GitHub で Star を付ける"),
    "support.github.help": ("Open Clutch's GitHub page. Giving a Star is optional.",
                            "打开 Clutch 的 GitHub 项目页，点 Star 完全自愿。",
                            "Clutch の GitHub ページを開きます。Star は任意です。"),
    "support.github.detail": ("A free Star helps more people discover Clutch.",
                              "免费点一颗 Star，也能让更多人发现 Clutch。",
                              "無料の Star で、もっと多くの人に Clutch を知ってもらえます。"),
    "support.github.opened": ("GitHub is open. Give Clutch a Star there if you'd like!",
                              "已打开 GitHub，喜欢的话可以在那里点一颗 Star！",
                              "GitHub を開きました。よければ Clutch に Star をお願いします！"),
    "support.thanks.title": ("Thanks for the coffee!", "谢谢你的咖啡！", "コーヒーをありがとう！"),
    "support.thanks.detail": ("Your support keeps Clutch going. You made a dragon maid very happy.",
                             "你的支持让 Clutch 走得更远，龙女仆也开心得跳起来了。",
                             "応援が Clutch の開発を支えます。ドラゴンメイドも大喜びです。"),
    "support.close": ("Close", "关闭", "閉じる"),
    "menu.addFirst": ("Add your first shortcut…", "添加第一个快捷键…", "最初のショートカットを追加…"),
    "menu.quit": ("Quit Clutch", "退出 Clutch", "Clutch を終了"),
}


def unit(value):
    return {"stringUnit": {"state": "translated", "value": value}}


catalog = {
    "sourceLanguage": "en",
    "version": "1.0",
    "strings": {
        key: {
            "extractionState": "manual",
            "localizations": {"en": unit(en), "zh-Hans": unit(zh), "ja": unit(ja)},
        }
        for key, (en, zh, ja) in sorted(STRINGS.items())
    },
}

out = pathlib.Path(__file__).resolve().parent.parent / "Clutch" / "Localizable.xcstrings"
out.write_text(json.dumps(catalog, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print(f"wrote {len(STRINGS)} strings to {out}")
