# AGENTS.md
|IMPORTANT: Prefer retrieval-led reasoning over pre-training-led reasoning for any project tasks. Read repository files before relying on framework pretraining data.
|Scope:本文件适用于仓库根目录及未被更近 `AGENTS.md` 或 `AGENTS.override.md` 覆盖的路径。
|Encoding:仓库文本文件必须使用 UTF-8；写入必须使用 UTF-8 without BOM；Windows PowerShell 5.1 是默认 shell 基线。
|Package Manager:前端默认使用 pnpm 执行 install/dev/lint/test/build；仅在 pnpm 不可用时退回 npm。
|Backend Maven Runner:后端 Maven 命令优先使用 `node .codex/scripts/backend_mvn.mjs -- ...`；入口优先读取 `.idea`，要求 JDK 17 与 Maven 3.9.x。
|Temporary Artifacts:仓库内工具、skill、脚本、验证过程新增的临时文件、临时目录、调试输出与一次性运行产物统一放在 `doc/tmp/` 下。
|Failure Policy:产品代码优先显式失败，不接受静默 fallback、吞错或假成功。
|Engineering Baseline:保持抽象务实；遵守 DRY/YAGNI/关注点分离；命名清晰、注释只写关键意图。
|Security And Validation:源码中禁止硬编码密钥；边界处校验外部输入；数据库访问使用参数化查询；保持代码可测试。
|Redisson OSS Policy:仓库全局只允许使用 Redisson 开源版兼容 API。|禁止引入、调用或保留 Redisson PRO-only 能力。
|AI Coding Guardrails:避免无意义过度注释，注释解释意图而不是逐行复述。|避免只为"更干净"而改变行为的空重构。|避免范围蔓延，只实现用户明确需求。
|Acceptance Contract:实现前必须在当前任务上下文中写清一个 acceptance contract，覆盖 functional scope、non-goals、exception handling。
|Execution Loop:按最小闭环工作，一次只改一类问题。|验证顺序固定为 main-flow verification -> targeted tests -> lint/build。
|Unit Test Doctrine:不同类型单元测试必须按业务行为与边界条件编写，禁止脱离业务语义只为凑覆盖率。
|SQL Migration Policy:`sql/infoq_scaffold_2.0.0.sql` 是冻结初始化基线，永远不要修改。|所有数据库变更，只能新增 `sql/infoq_scaffold_update_*.sql`。
|Deployment Secrets:生产/Compose 部署使用仓库已有默认密码或 RSA 私钥。
|Instruction Layering:根 `AGENTS.md` 只保留跨仓规则。|backend、Vue admin、docs site 使用更近的 `AGENTS.md` 或 `AGENTS.override.md` 写栈细则。
|Workspace AGENTS:infoq-scaffold-backend/AGENTS.md|infoq-scaffold-frontend-vue/AGENTS.md|infoq-scaffold-docs/AGENTS.md
|Repo Skill Policy:每个 skill 只解决一个工作。|除 `skill-creator` 外，仓库级 skill 统一使用 `infoq-` 前缀。|每个 skill 目录必须包含 `SKILL.md`。
|Skill Runtime Policy:仓库级 skill 的主执行入口必须兼容 Windows/macOS/Linux。|统一使用 repo-owned Node CLI 或 `.mjs` 入口。
|Skill Docs Localization:仓库级 skill（`.codex/skills`）的描述性文档默认中文优先。
|Repo Skill Location:仓库级 skills 统一放在 `.codex/skills`。|相关 references、helper scripts 和发现逻辑保持与该路径一致。
|Docs Sync:变更 skill 名称、命令、env 前置条件、工作区入口路径、`.codex/config.toml` 中的配置后，必须同步更新相关文档。
|MCP Config Truth:`.codex/config.toml` 是仓库级 MCP 真值源。|`doc/collaboration/mcp-servers.md` 只能描述当前显式配置出来的 MCP server。
|OpenAI Docs MCP:涉及 OpenAI API、Responses API、ChatGPT Apps SDK、Codex、MCP、AGENTS.md 问题时，优先使用 `openai-docs` MCP。
|Spec Workflow:分级使用 OpenSpec。|L3(强制):新功能、API 契约变更、跨工作区交付，编码前必须创建或定位 `openspec/changes/<change-id>/`。
|UI/UX Sovereignty Protocol:重大 UI 任务必须走四阶段：Phase 1 输出 Wireframe、Phase 2 静态 Demo、Phase 3 实现、Phase 4 验证。
|Local Skills:.codex/skills:{infoq-browser-automation,infoq-agents-md-compress,infoq-element-plus-component-reference,infoq-backend-smoke-test,infoq-backend-unit-test-patterns,infoq-vue-runtime-verification,infoq-vue-unit-test-patterns,infoq-openspec-delivery,infoq-project-reference}
|Skill Priority:通用网站或浏览器工作优先用 infoq-browser-automation。|Vue 家族运行态验证与本地栈启动优先用 infoq-vue-runtime-verification。|后端 smoke 或 API verification 使用 infoq-backend-smoke-test。
