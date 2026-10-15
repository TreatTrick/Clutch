# Appearance Preferences

**Goal:** 增加浅色、深色、跟随系统三个外观选项，并与语言切换放在同一个入口。

## Design

- 主窗口顶部原语言菜单改为“偏好设置”，使用系统设置图标，按“外观”和“语言”分组；每组保留当前选择的原生勾选状态。
- 外观默认跟随系统，旧版设置缺少该字段时也使用跟随系统。
- 复用 `UserSettings` 的现有 JSON 持久化，切换后立即保存，下次启动恢复。
- 通过 `NSApplication.appearance` 应用到整个应用，覆盖主窗口、菜单栏面板、打赏弹窗和原生菜单；跟随系统时清除覆盖，让 macOS 自动更新。
- 沿用现有系统自适应颜色和控件；二维码仍保持白色背景。

## Implementation

1. 在 `Clutch/Appearance.swift` 定义外观选项、显示名称、图标和应用外观的方法。
2. 在 `Clutch/AppState.swift` 接入设置解码、保存时应用及启动时恢复。
3. 在 `Clutch/MainView.swift` 将语言菜单扩展为外观与语言的统一菜单。
4. 更新 `scripts/gen_strings.py` 和生成的 `Clutch/Localizable.xcstrings`，提供中英文文案，并更新 README。

按用户要求，不新增单元测试，不运行验证或测试，由用户自行验收。
