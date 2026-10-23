# MouseSpell 的 Google 搜索可发现性调研

调研日期：2026-10-23。范围：MouseSpell 已部署的 GitHub Pages 网站（`https://treattrick.github.io/MouseSpell/`）、仓库中的 SEO 配置，以及用户已登录的 Google Search Console。资料只采用 Google Search Central、Google Search Console 帮助中心和 Google 官方博客。本次已验证 URL-prefix 属性、提交 sitemap，并检查及请求部分页面收录；Google 的抓取和收录仍需等待处理。

## 结论

**网站当前已经具备 Google 抓取所需的主要页面信号，但“加入搜索结果”和“快速排名”都不能保证。下一步的关键动作在 Search Console，而不是继续堆叠关键词。** Google 的 Search Essentials 把要求分成技术要求、垃圾内容政策和有助于搜索表现的最佳实践；即使全部满足，Google 仍可能不抓取、不给索引或不展示某个页面。[Google Search Essentials](https://developers.google.com/search/docs/essentials) [SEO Starter Guide](https://developers.google.com/search/docs/fundamentals/seo-starter-guide)

本次核查确认：英文、中文、日文页面，以及 `robots.txt` 和 `sitemap.xml` 均返回 HTTP 200。三种语言页面各自有本地化 `<title>`、`meta description`、自指向 canonical、互相指向的 `hreflang` 和 `x-default`；robots 文件声明了 sitemap；页面包含 `SoftwareApplication` JSON-LD。Search Console 的 URL-prefix 属性已验证，sitemap 已提交。英文主页显示已收录；中文页面的收录请求已接受；日文页面实时测试可抓取、可编入索引，收录请求已加入优先抓取队列。Search Console 的 sitemap 报告仍显示无法读取/抓取，但从外部使用 Googlebot User-Agent 请求时返回 HTTP 200，响应类型为 `application/xml`，且 XML 格式有效；需要等待并复查报告，现有证据不足以判断具体原因。

有一个不能忽略的限制：Google 当前的 [Software app (SoftwareApplication) structured data](https://developers.google.com/search/docs/appearance/structured-data/software-app) 文档把 `name`、`offers.price` 和 `aggregateRating` 或 `review` 列为富结果所需字段。MouseSpell 目前的 JSON-LD 有 `name` 和免费价格 `0`，但没有真实的评分或评论，因此**不能宣称已经满足 SoftwareApplication 富结果资格，也不应为了 SEO 虚构评分**。若以后有真实、页面可见的用户评分或评论，可以按 Google 的评论政策补齐并用 Rich Results Test 验证；否则保留描述应用的结构化数据即可，但把它视为帮助 Google 理解页面的标记，不要把它当成排名保证。[SoftwareApplication 文档](https://developers.google.com/search/docs/appearance/structured-data/software-app) [通用结构化数据政策](https://developers.google.com/search/docs/appearance/structured-data/sd-policies)

## 当前页面核查

| 项目 | 已部署状态 | 判断 |
| --- | --- | --- |
| 页面可访问性 | `/`、`/zh/`、`/ja/` 均为 HTTP 200 | 满足基本可抓取前提；仍需用 URL Inspection 看 Googlebot 的实际渲染结果 |
| 页面语言 | `en`、`zh-CN`、`ja` | 与各页主要文案一致；标题和描述也使用对应语言 |
| 标题和摘要 | 每个语言页有独立 `<title>` 和 `<meta name="description">` | 符合“每页描述清楚、避免重复模板”的方向 |
| canonical | 每个语言页指向自身完整 HTTPS URL | 适合把三种翻译作为独立页面；canonical 只是给 Google 的提示，不是强制规则 |
| hreflang | HTML 和 XML sitemap 都列出 `en`、`zh-CN`、`ja`，并有 `x-default` | 满足自指向、双向、绝对 URL 的要求；发布后要检查没有漏掉新语言页 |
| robots.txt | 允许抓取，并声明 `https://treattrick.github.io/MouseSpell/sitemap.xml` | 对公开网站合适；robots.txt 不能用来阻止 URL 被索引 |
| sitemap | XML sitemap 含三个 canonical URL 及多语言 alternate 链接 | 适合提交；提交 sitemap 只是提示，不保证抓取或收录 |
| SoftwareApplication | 有名称、免费价格、系统、类别、版本、下载链接等字段；没有 `review` / `aggregateRating` | 可帮助理解页面，但当前不应期待 SoftwareApplication 富结果 |

## 让用户更容易搜到的页面内容

Google 的标题链接和摘要是自动生成的，可能改写站点提供的 `<title>`、`h1`、页面正文、`og:title`、链接文字等内容。站点可以影响这些来源，但不能手动指定搜索结果中最终显示的标题或摘要。[Influencing Title Links](https://developers.google.com/search/docs/appearance/title-link) [Control Your Snippets](https://developers.google.com/search/docs/appearance/snippet)

当前标题和描述已经包含品牌和真实功能，例如 `MouseSpell`、macOS 鼠标快捷键、切换桌面、Mission Control、鼠标按钮和 macOS 15。建议持续遵循以下边界：

- 每个语言页面保留独立、简洁、准确的标题；不要把品牌和同一组词重复多次，也不要给所有页面使用同一个模板标题。
- 描述应是一两句面向用户的摘要，说明应用做什么、支持什么系统和主要动作；Google 可能根据具体查询改用页面正文生成 snippet。
- 将自然的搜索用词放在可见的首屏标题、`h1`、功能标题、图片 `alt` 和链接文字中，并确保它们真实描述页面。英文、简体中文和日文页面分别使用对应语言，不要在中文页面堆英文变体。
- 不要新增 `<meta name="keywords">`，也不要把长关键词串塞进描述或 JSON-LD。Google 官方博客明确说明，keywords meta tag 不用于 Google 网页排名；官方摘要文档也指出关键词串不利于生成清晰摘要。[Google does not use the keywords meta tag in web ranking](https://developers.google.com/search/blog/2009/09/google-does-not-use-keywords-meta-tag) [Control Your Snippets](https://developers.google.com/search/docs/appearance/snippet)
- 网站已经是预渲染页面；发布后仍要在 URL Inspection 的渲染结果中确认正文、标题、下载链接和图片对 Google 可见。Google 需要能访问页面依赖的 CSS、JavaScript 和图片，robots.txt 不应阻断这些重要资源。[SEO Starter Guide](https://developers.google.com/search/docs/fundamentals/seo-starter-guide)

Google 还强调有用、可靠、以人为本的内容和可抓取链接。GitHub README、Release 页面和网站之间应保持互相链接；有真实相关性时，再把项目介绍到开发者社区和鼠标/macOS 工具相关页面。外部链接和实际用户发现是长期信号，不能用重复关键词替代。[Google Search Essentials](https://developers.google.com/search/docs/essentials) [SEO Starter Guide](https://developers.google.com/search/docs/fundamentals/seo-starter-guide)

## 多语言页面的规则

Google 对多语言页面支持 HTML `<link rel="alternate" hreflang="...">`、HTTP `Link` 头和 sitemap 三种方式。每个语言版本应列出自己和其他版本，URL 必须是完整的绝对 URL；如果两页没有互相指向，Google 可能忽略这组标记。`x-default` 可作为无法匹配语言的回退页。[Localized Versions of Your Pages](https://developers.google.com/search/docs/specialty/international/localized-versions)

MouseSpell 当前的英文、中文、日文页面在 HTML 和 sitemap 中都列出全套 alternate，并以英文主页作为 `x-default`，这与 Google 的要求一致。新增语言时要同时更新页面 head、sitemap 和 `lang` 属性；不要只更新导航而遗漏 reciprocal `hreflang`。各语言页的 canonical 应继续指向自身，不能把所有翻译都 canonical 到英文页。Google 将 canonical、sitemap 和 `rel="canonical"` 视为信号，并保留自行选择 canonical 的权利。[What Is URL Canonicalization](https://developers.google.com/search/docs/crawling-indexing/canonicalization)

## robots.txt、sitemap 与重命名后的 URL

Google 官方说明，robots.txt 主要用于管理 crawler 访问和请求量，**不是**把页面从搜索结果隐藏的机制。被 robots.txt 禁止的 URL 仍可能因为外部链接而被索引，只是 Google 无法读取页面内容；真正需要阻止索引时应使用 `noindex` 或访问控制，并且不能同时用 robots.txt 把 Googlebot 挡在 `noindex` 页面之外。[Robots.txt Introduction](https://developers.google.com/search/docs/crawling-indexing/robots/intro)

当前公开站点允许抓取全部语言页，并在 robots.txt 中声明 sitemap，适合 MouseSpell 的目标。XML sitemap 使用完整 HTTPS URL，只放希望出现在搜索结果中的 canonical URL。Google 说明 sitemap 有助于发现新站点、外部链接较少的页面和媒体内容，但它不保证其中 URL 一定被抓取或索引；提交后可在 Sitemaps report 查看读取和解析错误。[What Is a Sitemap](https://developers.google.com/search/docs/crawling-indexing/sitemaps/overview) [Build and Submit a Sitemap](https://developers.google.com/search/docs/crawling-indexing/sitemaps/build-sitemap) [Sitemaps report](https://support.google.com/webmasters/answer/7451001?hl=en)

网站已经从 `/Clutch/` 改为 `/MouseSpell/`，因此 Search Console 应以新地址建立或选择 URL-prefix property：

```text
https://treattrick.github.io/MouseSpell/
```

URL-prefix property 包含该前缀下的子路径，末尾 `/` 应保留；这正好覆盖 `/zh/` 和 `/ja/`。Google 的 property 文档说明，添加属性前必须证明所有权；当前网站保留了 `google-site-verification` HTML meta 标签，Search Console 中的 `https://treattrick.github.io/MouseSpell/` 属性已验证。[Add a website or platform property to Search Console](https://support.google.com/webmasters/answer/34592?hl=en)

## Search Console 状态与后续监测

本次 Search Console 检查结果如下：

1. URL-prefix property `https://treattrick.github.io/MouseSpell/` 已验证，覆盖其下的 `/zh/` 和 `/ja/` 页面。
2. Sitemap `https://treattrick.github.io/MouseSpell/sitemap.xml` 已提交。Search Console 报告仍显示无法读取/抓取；直接 HTTP 检查返回 200 且 XML 有效。等待 Google 更新报告后再判断是否需要调整。
3. 英文主页显示已收录。中文页面的收录请求已接受。日文页面的实时测试显示可供 Google 抓取且可编入索引，随后收录请求已进入优先抓取队列；提交请求不保证立即收录或排名。
4. 后续在 **Sitemaps** 和 **URL Inspection** 中复查处理结果，并在 **Performance** 报告中按页面和查询观察 `MouseSpell`、`macOS mouse shortcuts`、`macOS 鼠标快捷键`、`Mac デスクトップ切り替え` 等自然查询的 impressions、clicks、CTR 和平均位置。新页面和改动需要 Google 重新抓取、处理，通常要等待数天到数周；不要用一次搜索结果判断发布失败。[SEO Starter Guide](https://developers.google.com/search/docs/fundamentals/seo-starter-guide) [URL Inspection tool](https://support.google.com/webmasters/answer/9012289?hl=en)

## 结构化数据的处理决定

当前 JSON-LD 的免费应用价格应保持数字 `0`，并确保下载 URL、图片 URL 和页面内容都公开可抓取。Google 的 SoftwareApplication 文档列出 `applicationCategory` 和 `operatingSystem` 为推荐字段；当前值 `UtilitiesApplication` 和 `macOS 15 or later` 与产品页面一致。

`aggregateRating` 或 `review` 只有在页面真的展示了相应的用户内容时才可以添加。Google 的通用结构化数据政策要求标记内容对读者可见、与页面主题相关、不能误导，也明确警告虚假评论或评分可能导致手动措施。当前没有真实评分时，建议保持现有描述性字段并在 Rich Results Test 中记录“缺少 SoftwareApplication 富结果所需评分/评论”的预期结果，不要写入占位分数。[SoftwareApplication 文档](https://developers.google.com/search/docs/appearance/structured-data/software-app) [通用结构化数据政策](https://developers.google.com/search/docs/appearance/structured-data/sd-policies) [Rich Results Test](https://search.google.com/test/rich-results)

## 发布检查表

- [ ] 新仓库、Release、官网、下载 DMG 和页面文案统一使用 `MouseSpell`；旧 `/Clutch/` 地址的处理单独确认，不要把它当作 Google SEO 配置已自动解决。
- [ ] `/MouseSpell/`、`/zh/`、`/ja/`、`robots.txt`、`sitemap.xml` 均返回 200；sitemap 中只含完整 HTTPS canonical URL。
- [ ] 每页有唯一的本地化 title、description、`lang`、canonical、全套 reciprocal `hreflang` 和 `x-default`。
- [ ] robots.txt 不阻止公开页面或渲染所需资源，并声明新 sitemap。
- [ ] Search Console URL-prefix property 已验证；sitemap 已提交但报告仍待复查；英文主页已收录，中文和日文页面的收录请求已提交。
- [ ] Rich Results Test 和 URL Inspection 已检查 JSON-LD；没有真实评分/评论时不添加 rating/review。
- [ ] 变更发布后等待重新抓取，再用 Performance 报告和 `site:treattrick.github.io/MouseSpell/` 检查收录趋势；不把收录或排名视为即时结果。

