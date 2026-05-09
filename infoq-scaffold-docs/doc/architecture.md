# infoq-scaffold-docs 架构说明

本文档只描述 `infoq-scaffold-docs` 当前代码能直接确认的展示层结构。

- 不把根 `doc/` 正文复制成第二份真值。
- 不把 VitePress 默认行为包装成仓库自定义平台能力。
- 如果未来栏目、导航或同步方式变化，应把这里视为“当前实现说明”。

## 0. 下钻阅读入口

- 工作区总览：[`../README.md`](../README.md)
- 同步与检查脚本：[`../scripts/README.md`](../scripts/README.md)
- 站点导航与页面映射：[`../site-map.mjs`](../site-map.mjs)
- VitePress 配置：[`../docs/.vitepress/config.mts`](../docs/.vitepress/config.mts)

## 1. 模块分层

当前展示层可以直接拆成四层：

1. 正文真值层
   - 仓库根 `doc/`
   - 本工作区只读取，不手工重写正文
2. 映射与同步层
   - `site-map.mjs`
   - `scripts/sync-from-root-doc.mjs`
3. 展示壳层
   - `docs/index.md`
   - `docs/*/index.md`
   - `docs/.vitepress/config.mts`
   - `docs/.vitepress/theme/*`
4. 校验与构建层
   - `scripts/check-links.mjs`
   - `pnpm run docs:build`

## 2. 各模块当前职责

| 模块 | 当前职责 | 当前证据 |
| --- | --- | --- |
| `site-map.mjs` | 维护分栏、页面描述、源文件与站点目标文件映射 | `sections`、`generatedPages`、`navItems`、`sidebar` |
| `scripts/sync-from-root-doc.mjs` | 复制根 `doc/` 页面、重写 Markdown 链接、同步 `images` 与 `examples` | `buildSyncedDocument()`、`copyPublicDirectory()`、`syncPages()` |
| `scripts/check-links.mjs` | 遍历 `docs/` 下 Markdown，校验内部路由和静态资源 | `collectMarkdownFiles()`、`validateLink()` |
| `docs/.vitepress/config.mts` | 装配站点标题、导航、侧边栏、搜索和页脚 | `defineConfig(...)` |
| `docs/.vitepress/theme/*` | 扩展默认主题并维护视觉样式 | `theme/index.ts`、`theme/custom.css` |
| `docs/index.md` 与栏目首页 | 提供站点首页与各栏目入口，不承担正文真值 | `docs/index.md`、`docs/backend/index.md`、`docs/admin/index.md`、`docs/weapp/index.md` |

## 3. 映射与装配路径

### 3.1 页面映射

`site-map.mjs` 是当前展示层的核心装配点：

- `sections` 定义栏目名称、文案和所包含的页面。
- 每个页面都显式绑定 `source`、`target`、`title`、`description`。
- `generatedPages` 会把这些元数据扁平化，供同步脚本、导航和侧边栏共同复用。

这意味着“站点有哪些正文页”不是靠扫描目录自动猜测，而是由 `site-map.mjs` 显式声明。

### 3.2 VitePress 壳

`docs/.vitepress/config.mts` 直接依赖 `site-map.mjs` 导出的 `navItems`、`sidebar`、`repoUrl`：

- 顶部导航来自 `navItems`
- 左侧栏来自 `sidebar`
- 页面风格和主题颜色由 `theme/custom.css` 扩展

因此栏目结构一旦变化，通常要先改 `site-map.mjs`，再由 VitePress 壳自动接收。

## 4. 运行时与构建期区别

- 运行或构建时生成：
  - `docs/.vitepress/cache`
  - `docs/.vitepress/dist`
- 长期维护的源文件：
  - `README.md`
  - `doc/*.md`
  - `site-map.mjs`
  - `scripts/*.mjs`
  - `docs/index.md`
  - `docs/*/index.md`
  - `docs/.vitepress/config.mts`
  - `docs/.vitepress/theme/*`

本工作区不应把构建产物当成可维护真值。

## 5. 公共约束

- 根 `doc/` 继续是正文真值源。
- 修改正文内容时，先改根 `doc/`，再执行 `pnpm run docs:sync`。
- 站点页里的链接必须能被 `scripts/check-links.mjs` 校验通过。
- 展示层实现文档只描述同步、导航、主题和构建路径，不重写业务正文。

## 6. 已知边界

- `docs/` 下除首页与栏目首页外，正文页主要由同步脚本生成；本工作区不维护它们的长期实现说明。
- 目前只能从 `site-map.mjs` 直接确认显式配置的栏目与页面；没有额外的自动发现流程。
