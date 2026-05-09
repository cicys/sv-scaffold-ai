# scripts

## 1. 模块定位

`scripts/` 是 `infoq-scaffold-docs` 的脚本层，负责把根 `doc/` 正文同步到站点目录，并在构建前做最基本的 Markdown 链接校验。

## 2. 子模块清单

- [`sync-from-root-doc.mjs`](./sync-from-root-doc.mjs)：从根 `doc/` 同步 Markdown、图片和示例资源。
- [`check-links.mjs`](./check-links.mjs)：扫描 `docs/` 目录下的 Markdown 链接并做存在性校验。

## 3. 子模块职责摘要

| 脚本 | 当前职责 |
| --- | --- |
| `sync-from-root-doc.mjs` | 读取 `site-map.mjs` 的页面定义，复制正文并重写链接 |
| `check-links.mjs` | 收集 `docs/` Markdown 文件，校验站内 route 与 `public` 资源路径 |

## 4. 依赖方向

- 两个脚本都依赖 Node 内置 `fs/promises`、`path`、`url`。
- `sync-from-root-doc.mjs` 还依赖 `site-map.mjs` 中的 `generatedPages`、`repoBlobBase`、`sourceDocRoot`。
- `check-links.mjs` 只依赖当前 `docs/` 目录结构，不反向修改正文源。

## 5. 典型调用链

1. `pnpm run docs:sync`
2. `pnpm run docs:check-links`
3. `pnpm run docs:build`

如果只关心同步逻辑，优先看 `sync-from-root-doc.mjs`；如果只关心失败链接排查，优先看 `check-links.mjs`。

## 6. 公共约束

- 脚本默认以根 `doc/` 为真值源。
- 链接无法解析时必须显式失败，不能静默跳过。
- 脚本负责“生成展示层文件”，不负责改写根 `doc/` 正文。

## 7. 已知边界

- 当前没有对 Markdown frontmatter、图表语法或代码块做额外语义校验。
- `check-links.mjs` 只验证链接是否可解析，不验证页面内容是否与根正文语义一致。

## 8. 下钻阅读路径

1. 工作区总览：[`../README.md`](../README.md)
2. 结构关系：[`../doc/architecture.md`](../doc/architecture.md)
3. 数据流：[`../doc/data-flow.md`](../doc/data-flow.md)
