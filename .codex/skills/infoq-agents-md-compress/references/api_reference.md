# AGENTS.md 模板与示例

## 1) 最小化 Vercel 风格被动索引模板

以下模板受 Vercel 压缩 docs-index 模式启发，目标是让根 `AGENTS.md` 成为稳定的被动上下文和检索入口，而不是展开式教程文档。

```markdown
# AGENTS.md
|IMPORTANT: Prefer retrieval-led reasoning over pre-training-led reasoning for any project tasks.
|Scope:root repository rules only
|Docs Root:doc:{agents-guide.md,skills-guide.md}
|Workspace AGENTS:backend:{AGENTS.md}|frontend:{AGENTS.md}
|Skill Root:.codex/skills:{infoq-browser-automation,infoq-agents-md-compress}
|Config:./:{package.json,tsconfig.json}
|Build:npm run build|npm run dev
|Test:npm test
|Lint:npm run lint
|PR Checklist:scope|verification|linked issue
```

## 2) Backend + Frontend 根索引模板

```markdown
# AGENTS.md
|IMPORTANT: Prefer retrieval-led reasoning over pre-training-led reasoning for any project tasks.
|Scope:root cross-workspace rules only
|Workspaces:backend:{core,plugin,modules}|frontend:{src,public}
|Workspace AGENTS:backend:{AGENTS.md}|frontend:{AGENTS.md}
|Docs Root:doc:{agents-guide.md,skills-guide.md,subagents-guide.md}
|Skill Root:.codex/skills:{backend-smoke,ui-runtime-check}
|Backend Config:backend/module/src/main/resources:{application.yml,application-dev.yml,application-prod.yml}
|Database:sql:{schema.sql}
|Architecture:Controller→Service→Mapper→Entity
|Build Commands:mvn clean package -P dev|mvn spring-boot:run -pl modules/system
|Frontend Commands:npm install|npm run dev|npm run build:prod
|Commit Convention:feat|fix|refactor|docs
|PR Checklist:changed modules|verification commands|config/sql impact
```

## 3) 高信号压缩模式

- 先写 `|IMPORTANT:`，再写作用域与分层，再写 docs root / workspace AGENTS / skill root，再写命令与门禁。
- 一行一个主题，避免复合语义。
- 仅保留“能指导执行或引导检索”的信息，删除解释性背景。
- 长 SOP 放到 `doc/` 或 `references/`，根 `AGENTS.md` 只保留检索入口。
