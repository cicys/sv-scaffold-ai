# infoq-scaffold-docs 关键数据流

本文档只记录 `infoq-scaffold-docs` 当前代码能直接追到的几条主链路：

- 根 `doc/` 正文同步到站点页面
- Markdown 链接重写与静态资源复制
- 链接校验
- VitePress 构建

## 0. 链路下钻入口

- 展示层总览：[`../README.md`](../README.md)
- 结构与装配关系：[`./architecture.md`](./architecture.md)
- 脚本职责：[`../scripts/README.md`](../scripts/README.md)

## 1. 根文档同步链路

正文同步的主入口是 `pnpm run docs:sync`，对应 [`sync-from-root-doc.mjs`](../scripts/sync-from-root-doc.mjs)。

```text
repo root doc/*
-> site-map.mjs 读取 source/target 映射
-> sync-from-root-doc.mjs 逐页读取源 Markdown
-> 构建同步前言与真值源提示
-> 重写 Markdown 链接
-> 写入 infoq-scaffold-docs/docs/*
```

当前实现要点：

- 同步脚本只处理 `site-map.mjs` 里显式声明的页面，不做目录全量扫描。
- 每个同步页都会插入“内容真值源”提示，指回根 `doc/` 对应文件。
- 站点正文页的链接在同步时会被重写成内部 route、GitHub blob 链接或 `/images`、`/examples` 资源路径。

## 2. 静态资源复制链路

除了 Markdown 页面，同步脚本还会复制两类资源：

```text
repo root doc/images -> infoq-scaffold-docs/docs/public/images
repo root doc/examples -> infoq-scaffold-docs/docs/public/examples
```

这条链路由 `copyPublicDirectory()` 驱动，目的不是生成新的真值，而是让站点构建阶段能直接引用图片和示例配置。

## 3. 链接重写链路

`rewriteMarkdownLinks()` 会按目标链接类型分流：

- 指向 `.md` 且能在 `site-map.mjs` 找到映射的，改写成站内路由。
- 指向 `doc/examples/*` 的，改写成 `/examples/*`。
- 指向 `doc/images/*` 的，改写成 `/images/*`。
- 其他仓库内相对路径，改写成 GitHub blob 链接。

这意味着展示层不会保留根文档里的原始相对路径，而是把它们规范成站点或仓库可访问路径。

## 4. 链接校验链路

`pnpm run docs:check-links` 会执行 [`check-links.mjs`](../scripts/check-links.mjs)：

```text
collectMarkdownFiles(docs/)
-> buildKnownRoutes()
-> 逐页提取 Markdown 链接
-> 区分站内路由 / public 资源 / 相对路径
-> 发现缺失项则显式失败
```

当前实现要点：

- `/images/*` 与 `/examples/*` 会映射到 `docs/public/*` 做存在性检查。
- 站内绝对路径会和 `docs/` 下已知 Markdown route 对比。
- 任一链接无法解析时，脚本会输出失败列表并返回非零退出码。

## 5. 构建链路

`pnpm run docs:build` 的当前顺序是：

```text
docs:sync
-> docs:check-links
-> vitepress build docs
```

这意味着站点构建并不是直接读根 `doc/`，而是先通过同步脚本生成展示层文件，再由 VitePress 构建。

## 6. 首页与栏目入口链路

`docs/index.md` 与 `docs/*/index.md` 不走同步脚本生成，它们是本工作区手写的展示层入口页：

- 首页负责给出全站入口与推荐阅读路径。
- 栏目首页负责给出该栏目范围和跳转入口。

这些页面可以更新展示文案，但不应复制根 `doc/` 的业务正文。

## 7. 已知边界

- 当前只有 `site-map.mjs` 显式列出的正文会进入同步链路；未列出的根文档不会自动出现在站点中。
- 展示层对正文内容的理解边界止于 Markdown 文本与链接重写，不额外解析业务语义。
