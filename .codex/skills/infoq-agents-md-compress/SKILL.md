---
name: infoq-agents-md-compress
description: 维护本仓库受 Vercel AGENTS.md docs-index 思路启发的根级 pipe-index AGENTS 约定，使根 `AGENTS.md` 成为被动上下文检索索引。适用于已采用该压缩约定且用户要求创建、更新、压缩或校验根 AGENTS 的场景。
---

# InfoQ AGENTS 压缩技能

## 核心目标

将根 `AGENTS.md` 维护为高密度、可检索、可执行的被动上下文索引：只保留每轮都应稳定可见的高优先级规则、命令和检索入口，把长说明下沉到 `doc/`、skill `references/`、更近 `AGENTS.md` 或其他真值文件。

## 范围边界

- 根 `AGENTS.md` 负责横向、通用、每轮都应稳定可见的上下文，以及通向真值文件的检索入口。
- 动作型、垂直 workflow 优先沉淀为独立 skill；不要继续堆进根 `AGENTS.md`。
- OpenAI 相关规范仅用于约束 skill 目录结构、`SKILL.md` frontmatter、`agents/openai.yaml` metadata 和触发边界，不用于削弱本仓库的压缩契约。

## 强约束格式契约

- 第一行必须是 `# AGENTS.md`。
- 标题后的非空行必须以 `|` 开头，维持压缩型被动上下文格式。
- 顶部必须尽早出现 `|IMPORTANT: Prefer retrieval-led reasoning over pre-training-led reasoning for any project tasks.`。
- 正文只承载两类信息：
  - 检索入口：`|Category:path:{file1,file2,file3}`
  - 高优先级规则/命令：`|Category:value1|value2|value3`
- 优先写“规则、入口、门禁”，不要在根 `AGENTS.md` 内展开长解释、完整 SOP、教程或大段示例。
- 根 `AGENTS.md` 只保留跨仓规则；长 SOP 下沉到 `doc/`、skill `references/`、更近 `AGENTS.md` 或其他真值文件。
- 不保留 `##`/`###` 和代码围栏，避免把被动上下文重新膨胀成叙述文档。

## 执行流程

1. 读取当前根 `AGENTS.md` 及其引用的 `doc/`、`references/`、workspace `AGENTS.md`、skill 路由文件，识别哪些内容必须留在被动上下文中。
2. 将长 SOP、解释性段落和教程内容下沉到可检索文件；根 `AGENTS.md` 只保留检索入口和高优先级规则。
3. 校验每个索引行引用的路径、命令、skill 名、workspace 入口都真实存在，避免生成不可检索的假索引。
4. 以稳定顺序压缩重写：`IMPORTANT -> scope/layering -> retrievable paths -> commands/gates -> skill routing`。
5. 若涉及 skill 改名、命令变化或环境前置条件变化，同时同步更近 `AGENTS.md`、`README.md` 与相关 `doc/*.md`。
6. 更新 `agents/openai.yaml`，确保 UI metadata 与 `SKILL.md` 的职责和默认提示保持一致。
7. 运行校验脚本并修正失败项。

## 质量门禁

执行：

- `node .codex/skills/infoq-agents-md-compress/scripts/example.mjs AGENTS.md`

通过标准：

- 标题行正确。
- 顶部存在 retrieval-led `|IMPORTANT:` 行。
- 标题后非空行全部以 `|` 开头。
- 不含 `##`/`###`/代码围栏。
- 每条索引路径都能映射到真实文件或目录。
- 根 `AGENTS.md` 不承载长 SOP，只承载规则和检索入口。

## 参考加载指南

- 压缩模板与示例：`references/api_reference.md`
- 原则、符号、格式边界：`references/compression_principles.md`
- 检查清单与反模式：`references/checklists_and_antipatterns.md`
- 定期维护策略：`references/maintenance.md`
