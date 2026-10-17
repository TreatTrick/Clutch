# Direct Support Restoration Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 按用户要求恢复 PayPal、微信、支付宝打赏与 GitHub Star，移除 App Store 支持方案。

**Architecture:** 在现有 SupportController、SupportModel 和弹窗内恢复旧版支付选择与二维码；保留现有支持声明、提醒进度和动画，去掉 StoreKit 交易识别。原支付链接与二维码内容都是 demo，继续明确标识，正式收款配置待后续替换。

**Tech Stack:** SwiftUI、AppKit、Observation、Core Image、现有三语言字符串生成脚本。

## Design

- 用户已指定恢复原三种打赏渠道与 GitHub Star；沿用原支付选择器、二维码和 PayPal 浏览器入口，不增加收款后台。
- 保留左侧龙女仆、关闭交互和独立 GitHub Star 按钮；再次打开时保持已支持状态，也允许查看收款码。
- 只有用户主动确认“我已支持”才标记打赏；打开支付或 GitHub 链接不冒充已完成付款或 Star。
- 保留累计实际使用第 3、7 天各提醒一次、使用次数、Debug 的 Option 点击重置。
- 旧购买声明迁移为本地支持声明，保留统计和提醒进度；不再识别 App Store 来源。
- 恢复到旧提交的整个文件会丢失后续提醒、日语、动画与调试改动，因此只恢复支付相关组件与配置。

## Implementation

1. `Clutch/SupportController.swift`、`Clutch/AppState.swift`：移除 StoreKit 和商店识别，恢复 PayPal 配置，兼容旧支持记录。
2. `Clutch/Mascot.swift`：支持状态改为本地声明，恢复 PaymentMethod 与 QR 生成，保留现有动画及链接失败反馈。
3. `Clutch/SupportView.swift`：恢复三个支付渠道、二维码、PayPal 跳转与确认；保留 GitHub 入口并始终展示使用次数。
4. `Clutch/MainView.swift`、`Clutch/MenuBarView.swift`：同步入口的已支持状态与动画。
5. `scripts/gen_strings.py`、`Clutch/Localizable.xcstrings`、`README.md`：同步中英日文案，移除产品中的 App Store 发布与购买引导。

## Verification and Delivery

- 用户已明确自行验证：不新增单元测试，不运行构建、测试或 UI 验证。
- 仅审阅差异、引用和生成后的本地化资源，不声称应用已运行通过。
- 保留现有相关注释；过时的商店实现注释随移除实现清理，其余按新含义更新。
- 不自动提交，不修改签名设置、核心快捷键逻辑或已有调研文档。
