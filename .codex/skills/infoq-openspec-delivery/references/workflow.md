# InfoQ OpenSpec 交付流程

## 目的

此技能用于规范 Codex 如何通过 OpenSpec 产物与代码变更推进功能交付；当用户明确要求时，可切换到 subagent 多专家模式。

## 目录规则

- 长期项目上下文放在 `openspec/project.md`
- 当前真值 specs 放在 `openspec/specs/`
- 进行中的 change 产物放在 `openspec/changes/<change-id>/`
- 仓库级自定义 agent 真值放在 `.codex/agents/`

## 执行模式

- 默认模式：主线程先在本地创建或更新 `proposal.md`、`tasks.md` 与相关 spec delta，再进入实现
- 多专家模式：当用户明确要求 subagent 或多专家执行时，使用下方专家职责模型

## 专家职责

| Agent | Primary output |
| --- | --- |
| `requirements_expert` | `proposal.md` + spec deltas |
| `technical_designer` | `tasks.md` |
| `code_implementer` | repository code + task checklist updates |
| `auto_fixer` | repository code fixes + verification reruns |

UI 密集型改动应使用 `infoq-ui-ux-three-phase-protocol`，或由父线程直接维护 `design.md`。

`materials.md` 与 `review.md` 可选保留，仅在变更确实需要时由父线程创建。

## 跨工作区规则

每个 change 都必须显式评估以下三个应用工作区：

- `infoq-scaffold-backend`
- `infoq-scaffold-frontend-react`
- `infoq-scaffold-frontend-vue`

若某个工作区不受影响，必须在 `tasks.md` 中写明原因。

## 规划规则

当用户要求暂不实现后续阶段时，应在 active OpenSpec 产物中保留为 deferred scope，禁止静默删除。

## 验证规则

交付闭环只有在 active change 显式记录以下内容后才算完成：

- verification commands
- verification outcomes
- residual risks or blockers
- rollback trigger or rollback conditions
