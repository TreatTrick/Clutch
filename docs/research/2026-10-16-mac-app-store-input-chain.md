# Clutch 的沙盒输入链路与 Mac App Store 可行性调研

调研日期：2026-10-16。范围：当前仓库代码、Apple 官方 API 文档、WWDC 演讲及 Apple DTS 工程师公开答复。仅进行源码和资料调查；未修改业务代码，未构建、运行或实测沙盒版，也未向 Apple 提交咨询或审核。

## 结论

**这条链路存在有官方依据的技术路径，值得继续验证；不能再笼统地认为“开启沙盒后，监听、吞事件、模拟快捷键全部不可用”。但当前 Clutch 尚未完成沙盒适配，也不能承诺通过 App Store 审核。**

决定性的依据是 Apple DTS 工程师 Quinn 在 2026 年 3 月明确区分三种 TCC 服务：`PostEvent`、`ListenEvent`、`Accessibility`。前两者对应的 API 兼容 App Sandbox，最后一类 API 不兼容；系统设置却把 `PostEvent` 和 `Accessibility` 都放在“辅助功能”页面，容易产生误判。他同时明确说明，DTS 的技术结论不能代替 App Review 的判断。[Apple DTS：PostEvent、ListenEvent 与沙盒的关系](https://developer.apple.com/forums/thread/820594)

| 问题 | 本次结论 | 确定程度 |
| --- | --- | --- |
| 沙盒内能否全局观察输入？ | 可以，存在官方沙盒示例及明确支持答复。 | 已确认：官方资料 |
| `.defaultTap` 能否吞掉原事件？ | 这是公开 API 定义的能力，需要控制事件的授权；仅有 `.listenOnly` 不能做到。 | 已确认：API 语义；当前 Clutch 沙盒行为未实测 |
| 沙盒内能否通过 `CGEvent.post` 发送按键？ | `PostEvent` 路径被 DTS 明确说明兼容沙盒。 | 已确认：官方技术答复 |
| 能否把这三段拼成 Clutch 的完整链路？ | 现行官方答复支持继续做最小验证；确切鼠标事件掩码、抑制行为、HID 投递点与系统动作仍需一起实测。 | 推断：尚未验证本项目 |
| 当前所有动作能否原样上架？ | 不能据此认定；私有 Dock 接口、通知中心 AX 操作及系统快捷键偏好读取要分别处理。 | 已确认：代码存在这些依赖；替代方案尚未验证 |
| 是否保证审核通过？ | 不保证。同一官方讨论截至 2026 年 9 月仍有开发者报告类似拒审；这是个案报告，不是“所有此类应用都禁止”的正式规则。 | 未知：由具体提交及 App Review 决定 |

## 1. 先分清三个常被混为一谈的东西

| 层次 | 作用 | 对 Clutch 的含义 |
| --- | --- | --- |
| App Sandbox | 限制进程能访问的资源和能力。 | 必须确认所用 API 属于沙盒可用路径。 |
| TCC 用户授权 | 用户同意应用监听或控制输入。 | 用户授权是必要条件；“设置里能勾选”并不等于所有 API 都获得沙盒豁免。 |
| App Review | 判断提交的软件和用途是否符合商店规则。 | 本地运行成功及 DTS 技术答复都不等于预先批准。 |

以上区分来自 Apple 对同一问题的直接解释。特别是“辅助功能设置里有这个应用”和“使用 AX API 操作其他应用的界面”并不是同一个技术事实。[Apple DTS 的完整说明](https://developer.apple.com/forums/thread/820594)

## 2. 识别组合：有明确的沙盒内监听路径

Apple DTS 在 2023 年用开启沙盒的测试项目验证过 `.cgSessionEventTap` + `.listenOnly`，在 macOS 13.2.1 获得用户输入监控授权后正常接收事件；同时指出 `CGPreflightListenEventAccess`、`CGRequestListenEventAccess` 可用于检查和请求权限。**这个例子证明被动监听可行，不证明主动吞事件可行。** [官方示例及完整参数](https://developer.apple.com/forums/thread/724608)

Clutch 的实际掩码是右键、其他鼠标键、滚轮和 `.flagsChanged`，没有全局监听 `.keyDown` / `.keyUp`；修饰键组合通过鼠标事件的 `flags` 匹配。因此，不应把“监听所有按键内容”的限制不加区分地套到本项目，也不应仅凭不监听字符就推断无需任何授权。当前创建的是主动 tap，权限还要结合下一节判断。[当前事件掩码与创建位置](/Users/duxiangqian/Documents/Clutch/Clutch/EventTap.swift:18)

## 3. 吞掉原鼠标事件：必须保留主动过滤能力

Apple 文档明确规定：主动过滤器可放行、修改或丢弃事件；被动监听器不能修改或转移事件。回调在主动模式下返回 `NULL` 会删除该事件，在被动模式下即使返回 `NULL` 也不会改变事件流。[CGEventTapOptions](https://developer.apple.com/documentation/coregraphics/cgeventtapoptions)、[CGEventTapCallBack](https://developer.apple.com/documentation/coregraphics/cgeventtapcallback?language=objc)

Clutch 当前使用 `.defaultTap`，命中绑定后对鼠标按下返回 `nil`，并记录该按键，以便连同松开事件一起吞掉；绑定的滚轮方向也会被吞掉。将它直接换成 `.listenOnly` 会改变产品行为：切换桌面的同时，原先的右键菜单、鼠标前进后退或页面滚动仍可能发生。[按键过滤代码](/Users/duxiangqian/Documents/Clutch/Clutch/EventTap.swift:59)、[滚轮过滤代码](/Users/duxiangqian/Documents/Clutch/Clutch/EventTap.swift:79)

WWDC19 的官方演讲直接展示将 `.listenOnly` 改为 `.defaultTap`：前者需要输入监控授权，后者因能影响事件流而需要“辅助功能”页面下的控制授权。结合 2026 年 DTS 对 `PostEvent` / `ListenEvent` 沙盒兼容性的澄清，可以推断主动过滤并非天然被 App Sandbox 排除；**本次尚未找到与 Clutch 完全相同参数、完整吞鼠标并切换桌面的官方示例，也未亲自运行确认。** [WWDC19：Advances in macOS Security，Automation 部分](https://developer.apple.com/videos/play/wwdc2019/701/)

## 4. 发送系统快捷键：公开 API 可用，动作成功需要单独判断

当前“上一个桌面／下一个桌面”创建一对键盘按下、松开事件，并投递到 `.cghidEventTap`。这是 `CGEvent.post(tap:)` 的公开投递接口，不是 `CoreDockSendNotification`。[当前实现](/Users/duxiangqian/Documents/Clutch/Clutch/ActionPerformer.swift:52)、[CGEvent.post 官方定义](https://developer.apple.com/documentation/coregraphics/cgevent/post(tap:))

两点需要准确理解：

- `tapCreate` 文档中创建 **HID 位置的监听 tap** 的 root 限制，不能直接套用到 **向 HID 位置 post 事件**。当前 Clutch 创建监听的位置是 `.cgSessionEventTap`，两处调用不是同一个操作。[tapCreate 文档](https://developer.apple.com/documentation/coregraphics/cgevent/tapcreate(tap:place:options:eventsofinterest:callback:userinfo:))
- `post(tap:)` 没有成功结果返回值；执行到这行、调用没有报错、Clutch 的使用次数增加，都不能证明系统已经切换桌面。应同时观察目标动作、键盘快捷键设置及原鼠标行为。此项为根据 API 签名和本项目调用顺序得出的实现判断。

本机 SDK 的公开 `CGEvent.h` 将 `CGPreflightPostEventAccess` / `CGRequestPostEventAccess` 描述为检查／请求 event synthesizing access，API 自 macOS 10.15 起可用；与项目最低 macOS 15 的要求相容。后续沙盒适配应优先围绕这一权限检查和请求，而非把 AX 信任状态当作整个链路的唯一门禁。[CGPreflightPostEventAccess](https://developer.apple.com/documentation/coregraphics/cgpreflightposteventaccess())、[CGRequestPostEventAccess](https://developer.apple.com/documentation/coregraphics/cgrequestposteventaccess())

Apple DTS 在 2026 年 5 月进一步说明：系统设置中的“辅助功能”授权本身就提供 posting 和 listening，通常不需要再让用户重复授予输入监控。若诊断被动监听，可以单独测 `ListenEvent`；产品应请求实际必要的能力。也不存在名为 `com.apple.security.device.audio-input-monitoring` 的补救 entitlement。[Kevin Elliott 的官方答复](https://developer.apple.com/forums/thread/828052)

## 5. 当前代码里，除了输入链路还有哪些障碍

当前 Debug、Release 都配置 `ENABLE_APP_SANDBOX = NO`，因此现有非沙盒版本的正常行为不能作为沙盒版本已可用的证据。[当前构建设置](/Users/duxiangqian/Documents/Clutch/Clutch.xcodeproj/project.pbxproj:171)

| 代码 | 现状 | 对上架版本的影响 |
| --- | --- | --- |
| `AppState.hasAccessibility`、`startEventTapWhenTrusted()` | 用 `AXIsProcessTrusted()` 作为启动监听的唯一前提。 | 应改为匹配输入控制能力的权限流程，避免把 AX 授权状态和事件投递授权混同；需要同时考虑请求、拒绝及重启后的状态。 |
| 上一个／下一个桌面 | `CGEvent` 合成系统快捷键。 | 最适合用于第一轮完整链路验证，先脱离其他动作依赖。 |
| 调度中心／应用窗口／显示桌面 | `dlopen` + `dlsym` 调用 `CoreDockSendNotification`；失败时启动 Mission Control.app。 | 私有接口不符合只使用公开 API 的要求。现有 fallback 的参数协议也未被本次确认是受支持的公开接口；不能把 fallback 的存在当作合规证明。 |
| 通知中心 | `AXUIElement` 查找其他应用的菜单栏时钟，再执行按压操作。 | 这是实际操作其他应用 UI 的 AX 路径，属于沙盒不兼容问题；需要替代实现或商店版功能调整。 |
| 读取系统快捷键 | `CFPreferencesCopyAppValue` 读取 `com.apple.symbolichotkeys` 的 `AppleSymbolicHotKeys`，使用内部 ID 79 / 81。 | 有独立的沙盒偏好读取风险；即使投递成功，也可能无法取得用户改过的快捷键。应将默认快捷键验证与自动读取自定义设置分开。 |

代码依据：[权限入口](/Users/duxiangqian/Documents/Clutch/Clutch/AppState.swift:174)、[监听启动门槛](/Users/duxiangqian/Documents/Clutch/Clutch/AppState.swift:197)、[系统快捷键读取](/Users/duxiangqian/Documents/Clutch/Clutch/ActionPerformer.swift:27)、[Dock 调用](/Users/duxiangqian/Documents/Clutch/Clutch/ActionPerformer.swift:65)、[通知中心 AX 调用](/Users/duxiangqian/Documents/Clutch/Clutch/ActionPerformer.swift:87)。

官方规则依据：App Sandbox 文档列出 assistive accessibility APIs、访问其他应用偏好等不兼容活动；它对模拟输入的现行限制具体列为 Open / Save 对话框，不能扩写成一概禁止所有 `CGEvent.post`。Apple DTS 另有明确的 AX 不兼容说明。审核指南 2.4.5 要求适当沙盒化，2.5.1 要求公开 API。[App Sandbox 文档](https://developer.apple.com/documentation/security/protecting-user-data-with-app-sandbox)、[AX 与沙盒的官方答复](https://developer.apple.com/forums/thread/789663)、[App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)

## 6. 供后续自行验证的最小方案

本节是建议步骤，不代表已实现或通过验证。目标是一次只回答一个未知，避免“事件 tap 没启动”和“目标动作不可用”混在一起。

1. **隔离验证版本。** 使用独立的 Bundle ID 和设置，保留现有版本。只启用 App Sandbox，不添加来源不明的 entitlement；通过签名 entitlement 或活动监视器确认进程确实在沙盒中。Apple 官方给出了两种确认方式。[验证 App Sandbox 的方法](https://developer.apple.com/documentation/security/protecting-user-data-with-app-sandbox)
2. **先绕开当前 AX 门禁。** 诊断页分别显示 post / listen 的 preflight 结果、tap 是否创建、回调是否命中、匹配绑定次数和尝试投递次数；只记录事件类型和计数，无需记录用户输入内容。用公开 PostEvent 请求流程进行用户授权。
3. **先观察，再吞事件。** 以相同鼠标掩码对照 `.listenOnly` 和 `.defaultTap`。选“Control + 右键”方便肉眼确认：命中时右键菜单不出现，未命中或禁用时仍正常出现；同时确认按下、松开成对处理正常。鼠标侧键另测网页前进／后退不发生，滚轮另测页面不滚动、动量不重复触发。
4. **单独验证发送。** 先手动确认系统启用了 Control + 左／右切换桌面，至少创建两个桌面。诊断按钮仅发送这组固定快捷键，不依赖 `AppleSymbolicHotKeys`，观察是否真正切换。
5. **接通完整链路。** 使用原来的 `.cgSessionEventTap` + `.defaultTap` → 回调 `nil` → `.cghidEventTap` post；验证“桌面切换一次”和“原鼠标行为没有发生”同时成立。HID 投递失败时，可将 session 投递作为单独对照实验，不能未经验证就改成最终实现。
6. **检查生命周期。** 用户拒绝、稍后授权、退出重开、关闭授权、关闭录制页面后的行为分别检查。先在最低支持的 macOS 15 和准备发布时的系统版本验证，再使用实际 TestFlight 分发构建检查权限身份。开发签名样本通过不能代替分发构建的结果。
7. **最后逐个接回其他动作。** 分别确认系统快捷键读取、三个 Dock 动作和通知中心；不要用其中一个动作的失败推翻已经通过的输入链路，也不要用一个动作成功推断其他动作可用。

| 场景 | 需要记录的证据 | 本次状态 |
| --- | --- | --- |
| 非沙盒基线 | 命中、原事件被吞、目标动作发生 | 未重新运行 |
| 沙盒 + 被动监听 | 授权状态、回调计数 | 未运行 |
| 沙盒 + 主动过滤 | tap 创建成功、原事件确实消失 | 未运行 |
| 沙盒 + 单独合成快捷键 | post 权限、系统动作确实发生 | 未运行 |
| 沙盒 + 完整链路 | 原事件消失与目标动作发生同时成立 | 未运行 |
| TestFlight 分发版本 | 新安装授权、重启后行为、完整动作 | 未提交／未运行 |

## 7. 如何判断 App Store 方案是否继续

建议继续推进最小沙盒验证，当前证据不足以否定方案二。若完整链路通过，核心的“修饰键＋鼠标映射系统快捷键”可以继续保留；接着解决私有接口、通知中心及自定义系统快捷键读取。若主动过滤或系统投递在正确授权后仍失败，应把最小复现交给 DTS，确认限制或错误，而非立刻重写整个应用。

审核准备应准确说明应用实际用途、请求 PostEvent 的原因及公开 API，引用上述 DTS 澄清。DTS 的技术答复不代表已经获得 App Review 许可；需要时向 App Review 解释或申诉，这与向 DTS 询问技术行为是两条流程。[Apple 对两种流程的区分](https://developer.apple.com/forums/thread/820594)

若后续需要咨询 DTS，可直接使用下面的问题描述（本次未发送）：

> Clutch 是 macOS 15+ 鼠标快捷键工具。请确认以下组合在 App Sandbox 中是否是受支持的公开 API 使用方式：用户通过 CGRequestPostEventAccess 授权后，创建 cgSessionEventTap / headInsertEventTap / defaultTap，只订阅 rightMouseDown、rightMouseUp、otherMouseDown、otherMouseUp、scrollWheel、flagsChanged；命中修饰键与鼠标绑定时回调返回 nil，随后通过 CGEvent 创建键盘按下／松开并 post 到 cghidEventTap，以执行用户已启用的系统桌面切换快捷键。输入链路不使用 AXUIElement 或私有 Dock API。请特别确认主动鼠标事件抑制及 HID 位置事件投递所需权限、沙盒支持边界，以及是否存在区别于 session 位置投递的限制。本问题只询问技术支持情况，不要求提前保证 App Review 通过。
