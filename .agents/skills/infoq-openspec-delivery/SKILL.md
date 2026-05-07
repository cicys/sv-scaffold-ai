---
name: infoq-openspec-delivery
description: 编排本仓库高影响级别的 OpenSpec 工作流。适用于新功能、API 契约变更、跨工作区交付、明确的 OpenSpec/spec 驱动请求，或 backend/React/Vue 的 subagent 多专家协作。
---

# InfoQ OpenSpec 交付流程

此技能用于 L3/L2 的 OpenSpec 工作（高影响或用户明确要求 OpenSpec）。对于不涉及契约变化的 L1 小范围修复，可选使用。若用户明确要求 subagent 或多专家执行，按下述专家序列执行。

## 前置条件

- `openspec/project.md`：存放长期项目上下文
- `openspec/specs/`：存放当前真值规范
- `openspec/changes/<change-id>/`：存放进行中的规划产物与 spec delta
- `.codex/agents/`：存放仓库级多专家模式自定义 agent 真值

## 工作流程

1. 在委派前先阅读 `AGENTS.md`、`openspec/project.md`、相关 specs 和真实仓库文件。
2. 创建 `change-id`，格式建议 `verb-noun` 或 `YYYY-MM-DD-short-topic`。
3. 使用下列命令初始化变更目录：

```bash
node .agents/skills/infoq-openspec-delivery/scripts/init_change_dir.mjs <change-id>
```

4. 若用户未要求 subagent，先创建或更新 `proposal.md`、`tasks.md` 及必要 spec delta，再进入实现（L2 Lite 最低要求为 `proposal.md` + `tasks.md`）。
5. 若用户明确要求 subagent 或多专家执行，按顺序拉起以下自定义 agent：
   - `requirements_expert`
   - `technical_designer`
   - `code_implementer`
   - `auto_fixer`
6. 使用 subagent 时必须保持严格依赖顺序：
   - `requirements_expert -> technical_designer`
   - 若 UI 或交互决策重要，父线程应直接产出 `design.md` 或切换到 `infoq-ui-ux-three-phase-protocol`
   - `code_implementer -> auto_fixer`
7. 所有进行中的规划产物必须存放在 `openspec/changes/<change-id>/`。
8. 在 `proposal.md` 中先写清晰的 `Why` 与 `What Changes`，再写 acceptance contract；OpenSpec 文档正文默认中文，路径名称、命令、文件名保持英文原样。
9. 若用户明确延期后续阶段，必须在 `proposal.md`、`design.md` 或 `tasks.md` 中记录延期范围，禁止静默丢弃。

## Acceptance Contract

实现前，在 `proposal.md` 中定义一个 acceptance contract，至少覆盖：

- functional scope（功能范围）
- non-goals（非目标）
- exception handling and explicit blockers（异常处理与显式阻塞）
- required logs or verification evidence（所需日志/验证证据）
- rollback trigger or rollback conditions（回滚触发条件）

若任一项缺失或冲突，先停止并暴露问题，再编码。

## 验证

以 `tasks.md` 和 spec delta 作为验证真值，按以下顺序验证：

1. 主流程验证
2. 定向测试
3. 受影响工作区的 lint/build
4. Diff 审核

发生改动时，各工作区最低验证要求：

- Backend：受影响模块的 Maven 定向测试 + 编译
- React：`pnpm test` 与 `pnpm build`
- Vue：`pnpm test:unit` 与 `pnpm run build:prod`

若某项检查不适用或无法执行，保持 change 处于 active 状态并显式记录 blocker，禁止宣称可归档。

## 产出契约

每个 active change 目录最终应包含：

- `proposal.md`
- `design.md`（需要时）
- `tasks.md`
- `materials.md`（需要时）
- `specs/.../spec.md` 下的 spec delta

验收后，由父线程决定是否归档该 change，以及是否需要 `review.md` 记录 blocker。

## 参考

请阅读：

- `references/workflow.md`
- `openspec/project.md`
- `openspec/specs/README.md`
- `openspec/changes/README.md`
