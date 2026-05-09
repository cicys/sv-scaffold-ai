# infoq-scaffold-docs

这份 README 只描述 `infoq-scaffold-docs` 当前仓库实现。

它是 `infoq-scaffold-ai` 的文档站展示层，不是正文真值源。根 `doc/` 仍然是项目文档正文的唯一真值；本工作区负责把这些正文映射成 VitePress 站点，并补上导航、主题、同步和检查能力。

## 当前实现概览

- `site-map.mjs` 维护站点导航、侧边栏、分栏与“根 `doc/` 源文件 -> 站点目标页”的映射。
- `scripts/sync-from-root-doc.mjs` 负责从根 `doc/` 复制正文、重写链接，并把同步结果落到 `docs/`。
- `scripts/check-links.mjs` 负责扫描 `docs/` 下的 Markdown 链接，验证内部路由和 `public` 资源是否可解析。
- `docs/index.md`、`docs/*/index.md` 是站点首页和栏目首页，承担展示层入口，不替代根 `doc/` 正文。
- `docs/.vitepress/config.mts`、`docs/.vitepress/theme/*` 负责 VitePress 的导航、侧边栏、主题和样式壳。

## 模块导航

| 模块 | 当前职责 | 主要证据 |
| --- | --- | --- |
| `site-map.mjs` | 维护站点分栏、页面映射和导航数据 | `site-map.mjs` |
| `scripts` | 同步根文档、校验链接 | [`scripts/README.md`](./scripts/README.md) |
| `docs/.vitepress` | 站点配置与主题样式 | `docs/.vitepress/config.mts`、`docs/.vitepress/theme/*` |
| `docs/index.md`、`docs/*/index.md` | 站点首页与栏目入口页 | `docs/index.md`、`docs/admin/index.md`、`docs/backend/index.md`、`docs/weapp/index.md` |

## 建议阅读顺序

1. [`doc/architecture.md`](./doc/architecture.md)
   先看展示层模块关系、`site-map.mjs` 与同步脚本的职责边界。
2. [`doc/data-flow.md`](./doc/data-flow.md)
   再看根 `doc/` 到站点页面的生成链路，以及 link check / build 闭环。
3. [`scripts/README.md`](./scripts/README.md)
   最后看脚本入口、依赖方向和故障边界。

## 常用命令

```bash
pnpm install
pnpm run docs:sync
pnpm run docs:check-links
pnpm run docs:dev
pnpm run docs:build
pnpm run docs:preview
```

## 当前实现提醒

- 根 `doc/` 才是正文真值；如果要改正文内容，应优先修改根 `doc/`，再回到本工作区执行同步。
- `docs/.vitepress/cache` 和 `docs/.vitepress/dist` 是运行或构建产物，不是长期维护的源文件。
- 展示层文档只记录同步与构建实现，不应该在这里手写第二份业务手册正文。
