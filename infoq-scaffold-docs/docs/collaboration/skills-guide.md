---
title: "Skills 指南"
description: "仓库级 skills 的职责与使用方式。"
outline: [2, 3]
---

> [!TIP]
> 内容真值源：[`doc/skills-guide.md`](https://github.com/luckykuang/infoq-scaffold-ai/blob/main/doc/skills-guide.md)
> 本页由 `infoq-scaffold-docs/scripts/sync-from-root-doc.mjs` 自动同步生成；请优先修改根 `doc/` 后再重新同步。

# Skills 指南

`.agents/skills` 是本仓库的能力库。
它不是提示词堆积目录，而是把稳定、可复用的研发动作沉淀成仓库内 SOP。

## 1. 设计原则

当前仓库级 skill 遵循这些硬约束：

1. 每个 skill 只解决一类工作。
2. 除 `skill-creator` 外，仓库级 skill 统一使用 `infoq-` 前缀。
3. `.agents/skills` 下不保留共享底座型、README-only 或 helper-only skill 目录。
4. React 家族和 Vue 家族技能允许通过 `references/admin` 与 `references/weapp` 区分客户端，但仍必须保持单一职责。

## 2. 一个 skill 通常包含什么

| 路径 | 作用 |
| --- | --- |
| `SKILL.md` | 入口说明、触发条件、默认步骤 |
| `agents/openai.yaml` | UI 元数据 |
| `scripts/` | 可直接运行的脚本或 CLI |
| `references/` | 规则、清单、上下文材料 |
| `assets/` | 模板、图标或辅助资源 |

没有 `SKILL.md` 的目录，不应被当作仓库级 skill。

## 3. 当前关键 skills

| Skill | 职责 | 典型场景 |
| --- | --- | --- |
| `infoq-browser-automation` | 通用浏览器自动化 | `playwright-cli` 页面流转、token 注入、截图、console 证据 |
| `infoq-react-runtime-verification` | React 家族运行态验证 | React admin 登录、路由校验、weapp DevTools / smoke |
| `infoq-vue-runtime-verification` | Vue 家族运行态验证 | Vue admin 登录、路由校验、weapp DevTools / smoke |
| `infoq-react-unit-test-patterns` | React 家族单测 | React admin / weapp 单测、coverage、回归补测 |
| `infoq-vue-unit-test-patterns` | Vue 家族单测 | Vue admin / weapp 单测、coverage、回归补测 |
| `infoq-backend-unit-test-patterns` | backend 单测 | service / controller / mapper / plugin / aspect |
| `infoq-backend-smoke-test` | backend 冒烟测试 | HTTP smoke、登录、菜单、导出、受保护接口 |
| `infoq-login-success-check` | 登录链路验证 | `/auth/login`、token、受保护接口 |
| `infoq-codebase-index` | 文件与类定位、索引同步 | 查类、找文件、同步索引 |
| `infoq-openspec-delivery` | OpenSpec 交付编排 | L3 / L2 变更、跨工作区交付 |
| `infoq-project-reference` | 仓库静态参考 | 目录、入口、命令、规范 |

## 4. 浏览器 skill 的当前真值

`infoq-browser-automation` 的默认主路径已经切换为仓库内跨平台 CLI：

- `pnpm --dir .agents/skills/infoq-browser-automation/scripts run playwright-cli ...`
- `pnpm --dir .agents/skills/infoq-browser-automation/scripts run chrome-devtools-cli ...`

说明：

- 这两个 CLI 是 repo-owned 入口，适用于 Windows / macOS / Linux。
- 为兼容不同平台和 `pnpm` 参数透传差异，也接受 `run <cli-name> -- ...` 形式，但默认推荐无 `--` 写法。
- 兼容包装器同时提供两套：Windows 使用 `.ps1`，macOS / Linux 使用 `.sh`。
- `playwright` MCP 只用于临时交互探索。
- `chrome-devtools` MCP 只用于深度诊断。

## 5. skill 如何被触发

主要来源有三类：

1. 用户显式点名 skill。
2. `AGENTS.md` 的 `Skill Trigger` 命中语义。
3. Codex 读取规则后，按任务类型主动选择最合适的 skill。

因此 skill 的有效性不只取决于脚本，还取决于：

- `SKILL.md` 是否描述清楚触发场景。
- `AGENTS.md` 是否正确路由。
- `README.md` 与 `doc/*.md` 是否与 skill 实际入口一致。

## 6. 何时不该新建 skill

以下情况通常不值得单独沉淀为 skill：

- 只会执行一次的临时任务
- 没有复用价值的个人化流程
- 只有说明、没有输入输出和动作闭环的“文档片段”
- 本质上只是现有 skill 的一个 `references/<variant>`

## 7. 新增或修改 skill 的同步要求

当新增或更新 skill 时，通常还要同步检查：

1. `AGENTS.md` 是否需要新增或调整路由。
2. `README.md` 与 `doc/*.md` 是否仍然准确。
3. 如果 skill 依赖仓库级 MCP，`.codex/config.toml` 与 `doc/mcp-servers.md` 是否仍然一致。
4. 若变更了命令、环境变量、入口路径或默认行为，是否已执行 docs 站点同步。
