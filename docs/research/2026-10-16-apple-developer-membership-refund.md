# Apple Developer Program 年费退款：自助列表不显示时怎么办

调研日期：2026-10-16。仅查阅公开资料，没有登录私人账户、提交客服申请或更改订阅。

## 现在应走的路径

**直接联系 Apple Developer Support，请求人工处理会员年费退款。** 苹果开发者支持官网明确受理会员资格、账户问题，并提供电话或电子邮件支持；入口是[联系 Apple Developer Support](https://developer.apple.com/contact/)，也可从[中文开发者支持页](https://developer.apple.com/cn/support/)点击“马上联系”。当前联系入口需要登录，登录后的具体分类名称未核实，不应照搬旧教程中的菜单。

中国大陆电话支持提供普通话服务，时间为周一至周五 09:00–17:00（官网标注 CST）；苹果要求先在线提交问题，再连接相关专家。应使用上述入口安排联系，不把未经核实的旧电话号码当作专线。[官方全球电话支持](https://developer.apple.com/cn/support/worldwide-telephone-hours/)

无需继续反复刷新普通 App 的退款列表：苹果通用退款帮助页也明确，遇到无法在 reportaproblem.apple.com 请求的其他退款，应联系 Apple 支持。列表没有项目本身，不能用来判断退款请求已经被拒绝。[官方退款帮助](https://support.apple.com/zh-cn/118223)

若 Developer Support 确认 App 内付款必须由账单团队处理，备用入口是[官方账单与订阅支持](https://support.apple.com/zh-cn/billing)底部“仍然需要协助”→“开始准备”，进入[Apple 人工支持流程](https://getsupport.apple.com/?caller=psp)。这是联系流程，不是再次返回自助退款列表。

## 先分清购买渠道和诉求

| 情况 | 处理重点 |
| --- | --- |
| 在开发者官网购买 | 向 Developer Support 提供会员订单号、扣款日期和金额，请其核对该笔会员订单并受理退款请求。官网购买与 App 内订阅是不同的购买路径，不应预设官网订单一定出现在普通 App 退款列表。 |
| 在 Apple Developer App 内购买 | 属于自动续订的年度会员订阅。官方说明，付款使用的 Apple 账户可以不同于注册开发者时的账户，应以收据确认付款账户；既然自助退款无法选择，就转人工说明该情况。 |
| 只是不想明年再扣费 | 停止自动续订，防止未来扣款。App 内购买在系统订阅设置管理；官网购买在开发者账户会员详情管理自动续订。 |
| 想退回本次已扣年费 | 必须单独提出退款申请；取消订阅不等于退回当年费用。 |

以上渠道及续订机制见[官方注册说明](https://developer.apple.com/help/account/membership/program-enrollment/)、[Developer App 购买说明](https://developer.apple.com/help/account/membership/enrolling-in-the-app/)和[会员续订说明](https://developer.apple.com/help/account/membership/renewal/)。表中的人工处理次序是根据这些渠道差异及官方支持范围给出的建议，不是苹果公布的退款审批规则。

## 退款政策能确认到什么程度

苹果现行《Apple Developer Program License Agreement》第 8 节明确：年度 Program fee **non-refundable**；通过 Developer App 付款还适用附件 9。因此，不能承诺“刚买就一定能退”，也没有找到适用于所有地区、所有开发者会员购买的“14 天无理由退款”政策。[官方协议，第 8 节及附件 9](https://developer.apple.com/support/terms/apple-developer-program-license-agreement/)

Developer App 的官方说明进一步写明，取消会员当年已经支付的年费不予退款；取消后通常仍可使用会员权益至到期。这确认的是取消续订的通常结果，不能把取消操作当成退款成功。[官方 Developer App 会员说明](https://developer.apple.com/help/account/membership/enrolling-in-the-app/)

**人工入口用于提交申请、核对订单和请求个案复核，不代表苹果保证批准例外。** 本次没有找到苹果公开承诺：仅因改变开发计划、尚未发布 App 或预计无法通过审核，就必须退年费。是否给予个案退款，需要支持团队处理具体订单。

## 个案证据与局限

**查到了第一人称明确说“已退回”的案例，但能核实的成功案例属于注册异常；没有找到与“会员已正常开通，后来因上架障碍放弃”完全相同且明确退款成功的经历。** 这些公开帖子是当事人自述，没有独立核验银行到账，不能据此估算成功率。

| 当事人及日期 | 原因和渠道 | 公开结果与适用范围 |
| --- | --- | --- |
| Reddit 用户 dnesdan，2026-02-16 跟进 | 付款后注册无法完成、联系表单提示邮箱无效；本人说打电话联系 Apple Developer Support。 | 明确说首次电话后取消原注册申请并退费，之后重新申请、经后续电话才开通会员。证明开发者支持处理过退款；**没有证明通过邮件表单成功，也不是正常激活后反悔**。[原帖及本人跟进](https://www.reddit.com/r/appledevelopers/comments/1qmqwsb/cant_finish_apple_developer_program_enrollment/) |
| w2solo 作者 daqing，2024-08-30 发布 | 付费注册与旧 Safari Developer 会员状态冲突；多次联系客服及资深顾问，描述了电话沟通。 | 本人写“今天我收到了苹果的退款”，随后重新付款并获得会员资格。属于注册异常，未明确邮件表单是退款受理入口。[本人完整经历](https://w2solo.com/topics/4982) |
| Ask Different 提问者，2019-09-18 | 个人会员已用于提交医院 App，审核要求机构主体，转换组织会员又不符合要求；向 Apple Developer Program Support 沟通并申请退款。 | 明确自述被拒，并贴出客服以不可退款条款拒绝处理的回复。与“上架受阻后申请退款”更接近，但原因是提交主体，时间也较早。[原始问题及所贴客服回复](https://apple.stackexchange.com/questions/370350/apple-developer-program-refund-help) |
| LINUX DO 用户 theaxxx，2026-05-11 | 本人说首开年费已付，想上架但障碍太多，考虑放弃。 | 仅询问能否退款；没有披露提交申请的渠道、批准或拒绝结果。原因接近当前情况，**不能当作成功案例**。[原帖](https://linux.do/t/topic/2154385) |

所以，“有人确实说自己拿到过年费退款”有公开依据；“别人都通过这个邮件表单成功退了”没有足够依据。当前建议使用 Developer Support，是因为它的官方受理范围和下述转介证据，不能把其他原因的个案结果当成此次申请的承诺。

苹果中文支持社区有完全相近的情况：用户称 Apple Developer Program 自动续费后，在退款页面始终无法勾选该项目；社区版主 Joker_H 于 2024-01-24 建议联系 Apple 开发者支持获取协助。这是人工转介路径的补充证据，帖子没有证明退款已批准。本次通过搜索结果核读该帖，直接打开曾受网站访问限制。[《怎样申请 Apple Developer Program 退款》](https://discussionschinese.apple.com/thread/255425147)

在一则付费后会员未激活的开发者论坛帖子中，署名 Apple Developer Support、带 Apple Staff 标识的工作人员明确建议，携带 web order number 通过 developer.apple.com/contact 联系开发者支持。这是一手的订单核查路径证据，但该帖没有证明最终退款获批。[Apple 员工回复](https://developer.apple.com/forums/thread/848795)

本次没有发现公开、无需登录的“开发者年费专用退款按钮”。上述个案均不改变前述正式政策。

## 可以直接提交的说明

> 你好，我希望申请退回最近购买的 Apple Developer Program 年费。该笔会员费用在 reportaproblem.apple.com 的退款列表中不显示／无法选择，因此无法通过自助页面提交。请协助核对会员订单，并受理退款申请；如果需要其他团队处理，请转交负责该会员订单的团队。购买渠道：［官网／Apple Developer App］；订单号：［填写］；扣款日期及金额：［填写］。申请原因：［如实说明］。如果不能退款，请告知本次订单适用的政策及是否可以申请人工复核。

订单号、收据、开发者账户和付款账户如不同，均可在官方支持工单中说明；“未使用会员服务”“没有发布 App”等情况仅在确实属实时填写。
