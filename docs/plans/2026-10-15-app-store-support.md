# App Store Support Implementation Plan

**Goal:** 将直接打赏替换为 App Store 买断支持与 GitHub Star，已支持状态持久化，商店购买者自动显示已支持。

**Architecture:** 复用现有 SupportController、SupportModel、支持弹窗和角色视频。购买状态与 GitHub 访问独立；仅跳转商店不代表购买成功。使用 StoreKit 验证正式商店交易，旧设置默认未声明购买。

**Tech Stack:** SwiftUI、AppKit、Observation、StoreKit 2、现有中英文字符串生成脚本。

## Design

- 沿用已确认的方案二，不添加订阅、第三方支付或新的收款后台。
- 保留左侧角色及靠近关闭按钮的既有视频交互；右侧改为商店支持和 GitHub Star，移除二维码与支付方式选择。
- 未支持：商店购买为主按钮，“我已支持”为自述确认入口；确认后立即感谢、持久化并停止自动提醒。
- 已支持：显示感谢与“我已支持”，不再催促购买；GitHub Star 始终可点。再次打开弹窗也不重置已支持状态。
- 商店来源：仅在正式收据存在且 StoreKit 交易验证成功、环境和 bundle ID 匹配时识别为已购买。开发和沙盒运行不会误识别。
- 打开 GitHub 后继续保留 Star 入口，不宣称已验证 Star。保留原有访问后感谢及停止自动打扰的行为。
- 免费且未支持用户在累计实际触发手势的第 3、7 个使用日各自动提醒一次，总计最多两次；弹出即持久化节点，手动打开不消耗次数。继续避开夜间、全屏和同日重复提醒；达到第 7 天后不再单独补弹第 3 天的提醒。兼容旧记录，已提醒至少两次的用户不再提醒。
- 提醒中展示累计快捷键触发次数，并说明“如果 Clutch 帮到了你，可以前往 App Store 购买支持，让 Clutch 走得更远”；沿用买断文案，不引入订阅。
- Debug 构建中按住 Option 点击底部或菜单栏的支持入口，可重置本地支持声明和提醒记录并重新打开未支持弹窗；保留快捷键、累计触发次数和使用天数，同步恢复底部角色的鼠标交互。Release 不包含重置操作，不覆盖正式商店购买识别结果。后续验证由用户自行完成。
- 用户已授权两个链接先使用 demo 地址；界面提示演示链接，正式发布前集中替换。
- 方案比较：本次复用现有弹窗，改动集中；新建独立购买窗口会增加跳转；增加账号和服务端校验超出当前 UI 改造范围。

## Implementation

1. `Clutch/SupportController.swift`：替换链接；兼容旧设置并增加购买声明；识别正式商店交易；连接持久化、弹窗刷新及提醒抑制。
2. `Clutch/Mascot.swift`：独立购买和 GitHub 状态，保留视频播放逻辑，移除支付与二维码模型。
3. `Clutch/SupportView.swift`：重排支持操作、感谢状态、已支持确认及打开链接失败反馈；保留关闭交互。
4. `Clutch/MainView.swift`、`Clutch/MenuBarView.swift`：入口随购买状态显示“我已支持”，点击后仍能访问 Star。
5. `scripts/gen_strings.py`、`Clutch/Localizable.xcstrings`、`README.md`：同步中英文文案与配置说明，保留已有外观设置改动。

## Verification

- 按用户要求，不新增单元测试。
- 使用 Xcode 的 Debug / Release 编译验证，并检查差异与废弃支付引用。
- 检查中英文、浅深色、未支持与已支持界面；确认关闭、Escape、Star 和已支持状态的可用性。
- 正式 App Store 交易识别需要上架后的真实交易环境验证；本地验证界面及自述确认持久化，不声称已完成真实商店付款。
