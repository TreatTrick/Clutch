# Japanese Localization Implementation Plan

**Goal:** 为当前应用增加完整日语支持，可手动选择，也可跟随系统语言。

**Architecture:** 沿用 `AppLanguage`、`Localizer` 和 `UserSettings` 的语言切换与持久化机制。扩展现有翻译生成脚本和字符串目录，不引入新的本地化层。

**Tech Stack:** SwiftUI、Foundation、Xcode String Catalog、Python。

## Implementation

1. 在 `Clutch/Localization.swift` 增加原始值为 `ja`、显示名称为「日本語」的语言选项。
2. 为 `scripts/gen_strings.py` 中的每个条目增加日语译文，保留格式占位符与换行，再生成 `Clutch/Localizable.xcstrings`。
3. 在 `Clutch.xcodeproj/project.pbxproj` 注册 `ja`，更新 README 的语言说明。
4. 校验所有语言的键和格式占位符、生成结果的可重复性，并执行可用的构建验证。

按用户要求保留已有任务注释，不新增单元测试。
