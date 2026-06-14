# SV Scaffold AI 项目上下文

## 目标

`sv-scaffold-ai` 是一个 Spring Boot 3.x + Vue 3.x 的全栈脚手架。通过 `AGENTS.md` 约束协作规则，通过 `.codex/skills` 固化自动化 SOP，并以 `OpenSpec` 管理规格与变更。

## 工作区映射

- `infoq-scaffold-backend`：Spring Boot 多模块后端
- `infoq-scaffold-frontend-vue`：Vue 3 + Element Plus 管理端
- `infoq-scaffold-docs`：VitePress 文档站展示层、同步脚本与发布入口
- `script`：部署、环境脚本
- `sql`：冻结初始化 SQL 与版本增量脚本
- `doc`：文档正文真值源、参考文档与使用指南

## 架构默认约束

- 后端主链路：`Controller -> Service -> Mapper -> Entity`
- 前端实现必须遵守 Vue 管理端的本地架构
- 优先显式失败路径，避免静默回退
- 优先最小改动，避免大范围重写

## 交付默认约束

- L3 变更（新功能、API 契约变更、跨工作区交付）在改代码前必须创建或定位 `openspec/changes/<change-id>/`
- L2 变更（单工作区行为变更且不改 API 契约）可使用 OpenSpec 精简流程，至少维护 `proposal.md` 与 `tasks.md`
- L1 变更（单工作区小修复且不改契约、改动范围小）可不创建 OpenSpec，但必须先写验收约定
- 不确定分级时默认按 L3 执行
- `sql/infoq_scaffold_2.0.0.sql` 是冻结初始化基线，任何变更不得修改该文件；数据库变更必须新增 `sql/infoq_scaffold_update_*.sql`

## 文档与工具默认约束

- OpenSpec 文档正文默认使用中文
- 路径名称、命令、文件名保持英文原样
- `openspec/` 与 `doc/plan/` 属于仓库真值资产，默认纳入版本控制
- 前端命令优先使用 `pnpm`
- 后端构建与测试使用 `mvn`
- 对重复验证流程优先复用仓库技能
