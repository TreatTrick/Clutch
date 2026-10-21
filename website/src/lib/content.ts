export type Locale = 'en' | 'zh' | 'ja';
export const SITE_URL = 'https://treattrick.github.io/Clutch';
export const REPOSITORY_URL = 'https://github.com/TreatTrick/Clutch';
export const DOWNLOAD_URL = `${REPOSITORY_URL}/releases/download/v1.0.0/Clutch-v1.0.0-universal.dmg`;
export const LANGUAGES = [
  { code: 'en', label: 'English', html: 'en', path: '/' },
  { code: 'zh', label: '中文', html: 'zh-CN', path: '/zh/' },
  { code: 'ja', label: '日本語', html: 'ja', path: '/ja/' }
];

export const COPY = {
  en: {
    title: 'Clutch — Switch Mac Desktops with Mouse Buttons',
    description: 'Switch Mac desktops, open Mission Control, and show your desktop with modifier keys and mouse buttons. Free, open source, and built for macOS 15+.',
    skip: 'Skip to content', features: 'What it does', setup: 'How it works', source: 'Source code',
    language: 'Language', appearance: 'Appearance', system: 'System', light: 'Light', dark: 'Dark',
    badge: 'A little more Mac. From your mouse.',
    headline: ['Switch Mac desktops.', 'From your mouse.'],
    intro: 'Hold a key. Click a mouse button. Switch desktops, open Mission Control, and bring trackpad gestures to the mouse you already use.',
    download: 'Download for Mac', requirements: 'macOS 15+ · Apple Silicon & Intel', free: 'Free & open source',
    demoCaption: 'Your hand stays on the mouse. Your desktop moves on.',
    demoAlt: 'Clutch desktop-switching demo: Control and the mouse side buttons switch between Mac desktops',
    demoBinding: 'Example: Control + side buttons', play: 'Play demo', pause: 'Pause demo',
    actionsHeading: 'Familiar gestures. A new shortcut.',
    actionsIntro: 'Six macOS actions, ready for your own combinations. These are examples — you choose the bindings.',
    actions: [
      ['←', 'Previous Desktop', 'Option + back button'], ['→', 'Next Desktop', 'Option + forward button'],
      ['⌃', 'Mission Control', 'Option + middle click'], ['▤', 'App Windows', 'Control + middle click'],
      ['□', 'Show Desktop', 'Option + scroll down'], ['☰', 'Notification Center', 'Option + right click']
    ],
    triggerNote: 'Use Option, Control, Command, Shift, or fn with a mouse button or scrolling. Your regular left click stays untouched.',
    setupHeading: 'Make it yours. In three steps.',
    setupIntro: 'Clutch records what you actually press. No hunting through a wall of dropdowns.',
    steps: [
      ['Hold a modifier key', 'Press Option, Control, Command, Shift, or fn.'],
      ['Press a mouse button', 'Use a side button, middle click, right click, or scroll.'],
      ['Choose an action', 'Pick a system action. Your shortcut is ready.']
    ],
    screenshotAlt: 'Clutch settings showing the three-step shortcut recorder',
    privacyHeading: 'On your Mac. On your terms.',
    privacyText: 'The app processes shortcuts locally. No analytics, no network requests. Clutch lives quietly in your menu bar, ready when you need it.',
    privacyFacts: ['Local processing', 'No analytics', 'MIT licensed'],
    installHeading: 'Give your mouse another move.',
    installIntro: 'Download Clutch 1.0.0. A small, free utility for the way you already work.',
    installNote: 'This release is ad hoc signed and is not notarized by Apple. Read the first-launch steps below.',
    installDetails: 'Installation & first launch',
    installSteps: [
      ['Drag to Applications', 'Open the DMG and drag Clutch onto Applications. Then open the app from that folder.'],
      ['Allow the first launch', 'If macOS shows “Clutch” Not Opened, click Done. In System Settings → Privacy & Security, click Open Anyway and confirm. Only do this for a download you trust.'],
      ['Enable Accessibility', 'In System Settings → Privacy & Security → Accessibility, enable Clutch so it can respond to your mouse shortcuts.'],
      ['Enable desktop shortcuts', 'For desktop switching, enable “Move left a space” and “Move right a space” in Keyboard → Keyboard Shortcuts → Mission Control.']
    ],
    appleGuide: 'Apple’s first-launch guide', releases: 'All releases', footer: 'A small shortcut to a smoother Mac.',
    permissionsAlt: 'macOS Privacy & Security settings showing the Open Anyway button'
  },
  zh: {
    title: 'Clutch — 用鼠标侧键切换 Mac 桌面，触发系统手势',
    description: '按住修饰键，点击鼠标，即可切换 Mac 桌面、打开调度中心或显示桌面。Clutch 是免费开源的 macOS 鼠标快捷键工具，支持 macOS 15 及以上版本。',
    skip: '跳至正文', features: '支持的操作', setup: '使用方式', source: '源代码',
    language: '语言', appearance: '外观', system: '跟随系统', light: '浅色', dark: '深色',
    badge: '让手边的鼠标，多一点 Mac 的默契。',
    headline: ['切换 Mac 桌面，', '鼠标就能做到。'],
    intro: '按住一个键，点击鼠标。切换桌面、打开调度中心，把熟悉的触控板手势，交给你正在用的鼠标。',
    download: '下载 Mac 版', requirements: 'macOS 15+ · Apple Silicon 与 Intel', free: '免费 · 开源',
    demoCaption: '手留在鼠标上，桌面随你切换。',
    demoAlt: 'Clutch 桌面切换演示：按住 Control，点击鼠标侧键，在 Mac 桌面之间切换',
    demoBinding: '示例：Control + 鼠标侧键', play: '播放演示', pause: '暂停演示',
    actionsHeading: '熟悉的手势，顺手的新方式。',
    actionsIntro: '六种 macOS 系统操作，绑定方式由你决定。以下组合仅作示例。',
    actions: [
      ['←', '上一个桌面', 'Option + 后退侧键'], ['→', '下一个桌面', 'Option + 前进侧键'],
      ['⌃', '调度中心', 'Option + 鼠标中键'], ['▤', '应用程序窗口', 'Control + 鼠标中键'],
      ['□', '显示桌面', 'Option + 向下滚动'], ['☰', '通知中心', 'Option + 鼠标右键']
    ],
    triggerNote: '支持 Option、Control、Command、Shift 和 fn，搭配鼠标按键或滚轮使用。普通左键点击保持原样。',
    setupHeading: '三个步骤，设成你喜欢的样子。',
    setupIntro: '直接录下你按的组合，不用在一排排下拉菜单里寻找。',
    steps: [
      ['按住修饰键', '选择 Option、Control、Command、Shift 或 fn。'],
      ['按一下鼠标', '使用侧键、中键、右键，或者滚动滚轮。'],
      ['选择系统操作', '选好想触发的动作，快捷键就设置好了。']
    ],
    screenshotAlt: 'Clutch 设置窗口，展示修饰键、鼠标操作与系统动作的三步设置流程',
    privacyHeading: '在你的 Mac 上，由你掌控。',
    privacyText: '应用在本地处理快捷键，不收集分析数据，也不发起网络请求。Clutch 安静地待在菜单栏，需要时随时响应。',
    privacyFacts: ['本地处理', '无数据追踪', 'MIT 开源协议'],
    installHeading: '给鼠标，多一种顺手的可能。',
    installIntro: '下载 Clutch 1.0.0。一个免费的小工具，配合你原本的工作方式。',
    installNote: '此版本使用 ad hoc 签名，未经 Apple 公证。首次打开前，请阅读下方安装说明。',
    installDetails: '安装与首次打开',
    installSteps: [
      ['拖入应用程序', '打开 DMG，将 Clutch 拖到 Applications（应用程序），然后从该文件夹打开。'],
      ['允许首次打开', '如果出现“Clutch 未打开”，点击“完成”。前往“系统设置 → 隐私与安全性”，点击“仍要打开”并确认。请先确认下载来源可信。'],
      ['开启辅助功能权限', '在“系统设置 → 隐私与安全性 → 辅助功能”中启用 Clutch，让它可以响应鼠标快捷键。'],
      ['开启桌面切换快捷键', '切换桌面需要开启“键盘 → 键盘快捷键 → 调度中心”中的“向左移动一个空间”和“向右移动一个空间”。']
    ],
    appleGuide: 'Apple 首次打开说明', releases: '所有版本', footer: '一个小小的快捷键，让 Mac 更顺手。',
    permissionsAlt: 'macOS 隐私与安全性设置中的“仍要打开”按钮'
  },
  ja: {
    title: 'Clutch — マウスボタンで Mac のデスクトップを切り替え',
    description: '修飾キーとマウスボタンで、Mac のデスクトップ切り替えや Mission Control を操作。Clutch は macOS 15 以降に対応した、無料のオープンソースアプリです。',
    skip: '本文へ移動', features: 'できること', setup: '使い方', source: 'ソースコード',
    language: '言語', appearance: '外観', system: 'システム', light: 'ライト', dark: 'ダーク',
    badge: 'いつものマウスで、Mac をもっと自在に。',
    headline: ['Mac のデスクトップを、', 'マウスで切り替える。'],
    intro: 'キーを押しながら、マウスをクリック。デスクトップの切り替えも、Mission Control も。トラックパッドの操作を、いつものマウスで。',
    download: 'Mac 版をダウンロード', requirements: 'macOS 15+ · Apple Silicon / Intel', free: '無料・オープンソース',
    demoCaption: '手はマウスのまま。デスクトップは次へ。',
    demoAlt: 'Clutch のデスクトップ切り替えデモ：Control とマウスのサイドボタンで切り替え',
    demoBinding: '設定例：Control + サイドボタン', play: 'デモを再生', pause: 'デモを一時停止',
    actionsHeading: 'おなじみの操作を、もっと手軽に。',
    actionsIntro: '6 つの macOS 操作を、好きな組み合わせに。以下は設定例です。',
    actions: [
      ['←', '前のデスクトップ', 'Option + 戻るボタン'], ['→', '次のデスクトップ', 'Option + 進むボタン'],
      ['⌃', 'Mission Control', 'Option + 中クリック'], ['▤', 'アプリケーションのウインドウ', 'Control + 中クリック'],
      ['□', 'デスクトップを表示', 'Option + 下にスクロール'], ['☰', '通知センター', 'Option + 右クリック']
    ],
    triggerNote: 'Option、Control、Command、Shift、fn とマウスボタンやスクロールに対応。通常の左クリックはそのまま使えます。',
    setupHeading: '3 ステップで、自分の操作に。',
    setupIntro: '実際に押した組み合わせを記録。たくさんのメニューを探す必要はありません。',
    steps: [
      ['修飾キーを押す', 'Option、Control、Command、Shift、fn から選びます。'],
      ['マウスを操作する', 'サイドボタン、中クリック、右クリック、スクロールに対応。'],
      ['アクションを選ぶ', '使いたいシステム操作を選んだら、設定完了です。']
    ],
    screenshotAlt: '修飾キー、マウス操作、アクションを 3 ステップで登録する Clutch の設定画面',
    privacyHeading: 'あなたの Mac の中で完結。',
    privacyText: 'アプリはショートカットをローカルで処理。アクセス解析もネットワーク通信も行いません。メニューバーに常駐し、必要なときに応えます。',
    privacyFacts: ['ローカル処理', 'アクセス解析なし', 'MIT ライセンス'],
    installHeading: 'マウスに、もうひとつの使い方を。',
    installIntro: 'Clutch 1.0.0 をダウンロード。いつもの作業に寄り添う、小さな無料アプリです。',
    installNote: 'このバージョンは ad hoc 署名で、Apple の公証は受けていません。初回起動の手順をご確認ください。',
    installDetails: 'インストールと初回起動',
    installSteps: [
      ['アプリケーションへ移動', 'DMG を開き、Clutch を Applications にドラッグしてから、アプリケーションフォルダで開きます。'],
      ['初回起動を許可', '「Clutch は開かれませんでした」と表示されたら「完了」を選択。「システム設定 → プライバシーとセキュリティ」で「このまま開く」を選び、確認します。信頼できるダウンロードにのみ行ってください。'],
      ['アクセシビリティを許可', '「システム設定 → プライバシーとセキュリティ → アクセシビリティ」で Clutch を有効にします。'],
      ['デスクトップ切り替えを有効化', '「キーボード → キーボードショートカット → Mission Control」で、操作スペースを左右に移動するショートカットを有効にします。']
    ],
    appleGuide: 'Apple の初回起動ガイド', releases: 'すべてのリリース', footer: '小さなショートカットで、Mac をもっと快適に。',
    permissionsAlt: 'macOS のプライバシーとセキュリティ設定にある「このまま開く」ボタン'
  }
};
