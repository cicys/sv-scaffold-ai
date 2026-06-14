# SV Scaffold 文档中心

本文档中心是 SV Scaffold（Spring Boot + Vue）的完整技术文档。

## 文档分层

- **根 `doc/`**：正文真值源与资源目录，按 `guide / backend / admin / devops / collaboration` 分类维护
- **`infoq-scaffold-docs/`**：VitePress 文档站展示层，负责导航、主题、同步脚本、构建与部署

## 推荐阅读路径

### 第一次接手项目

1. [`guide/project-overview.md`](./guide/project-overview.md) - 项目定位、工作区分工、能力地图
2. [`guide/quick-start.md`](./guide/quick-start.md) - 环境准备、本地启动、最小验证
3. [`backend/handbook.md`](./backend/handbook.md) - Spring Boot 后端结构、认证、配置
4. [`admin/handbook.md`](./admin/handbook.md) - Vue 管理端路由、请求封装、页面扩展

### 快速启动

- [`guide/quick-start.md`](./guide/quick-start.md)

### 部署上线

- [`devops/deploy-prerequisites.md`](./devops/deploy-prerequisites.md) - 部署前检查
- [`devops/docker-compose-deploy.md`](./devops/docker-compose-deploy.md) - Docker Compose 部署
- [`devops/manual-deploy.md`](./devops/manual-deploy.md) - 手动部署

### 仓库协作

- [`collaboration/development-workflow.md`](./collaboration/development-workflow.md) - 开发工作流
- [`collaboration/agents-guide.md`](./collaboration/agents-guide.md) - AGENTS.md 规约
- [`collaboration/skills-guide.md`](./collaboration/skills-guide.md) - 自动化能力
- [`collaboration/mcp-servers.md`](./collaboration/mcp-servers.md) - MCP 配置

## 文档导航

### 入门

- [`guide/project-overview.md`](./guide/project-overview.md) - 项目定位、工作区分工、能力地图
- [`guide/quick-start.md`](./guide/quick-start.md) - 环境准备、本地启动、验证闭环
- [`guide/faq.md`](./guide/faq.md) - 常见问题和排障
- [`../infoq-scaffold-docs/README.md`](../infoq-scaffold-docs/README.md) - 文档站配置

### 架构与开发

- [`backend/handbook.md`](./backend/handbook.md) - Spring Boot 后端结构、认证、配置、插件
- [`admin/handbook.md`](./admin/handbook.md) - Vue 管理端目录、路由、请求封装、页面扩展
- [`collaboration/development-workflow.md`](./collaboration/development-workflow.md) - 开发工作流、AGENTS、OpenSpec、验证顺序

### 工作区实现入口

- `infoq-scaffold-backend`：[`README.md`](../infoq-scaffold-backend/README.md) → [`doc/architecture.md`](../infoq-scaffold-backend/doc/architecture.md) → [`doc/data-flow.md`](../infoq-scaffold-backend/doc/data-flow.md)
- `infoq-scaffold-frontend-vue`：[`README.md`](../infoq-scaffold-frontend-vue/README.md) → [`doc/architecture.md`](../infoq-scaffold-frontend-vue/doc/architecture.md) → [`doc/data-flow.md`](../infoq-scaffold-frontend-vue/doc/data-flow.md)
- `infoq-scaffold-docs`：[`README.md`](../infoq-scaffold-docs/README.md) → [`doc/architecture.md`](../infoq-scaffold-docs/doc/architecture.md)

### 部署与运维

- [`devops/deploy-prerequisites.md`](./devops/deploy-prerequisites.md) - 部署前检查
- [`devops/docker-compose-deploy.md`](./devops/docker-compose-deploy.md) - Docker Compose 脚本部署
- [`devops/manual-deploy.md`](./devops/manual-deploy.md) - 手动部署与运维

### 协作与自动化

- [`collaboration/agents-guide.md`](./collaboration/agents-guide.md) - AGENTS.md 分层说明
- [`collaboration/skills-guide.md`](./collaboration/skills-guide.md) - 仓库级 skills 目录与使用
- [`collaboration/mcp-servers.md`](./collaboration/mcp-servers.md) - 项目级 MCP 配置
- [`collaboration/plugin-catalog.md`](./collaboration/plugin-catalog.md) - 后端插件矩阵

## 工作区总览

| 工作区 | 作用 | 关键入口 |
| --- | --- | --- |
| `infoq-scaffold-backend` | Spring Boot 3 多模块后端 | `infoq-admin/src/main/java/cc/infoq/admin/SysAdminApplication.java` |
| `infoq-scaffold-frontend-vue` | Vue 3 + Element Plus 管理端 | `src/main.ts`、`src/router/index.ts` |
| `openspec` | 规格、变更、设计资产 | `project.md`、`specs/`、`changes/` |
| `script` | 部署、构建辅助脚本 | `script/bin/`、`script/docker/` |
| `sql` | 初始化 SQL 与升级脚本 | `infoq_scaffold_2.0.0.sql` |
| `doc` | 使用文档与参考手册 | 当前目录 |

## 根目录约定

- **正文分类**：`guide/`、`backend/`、`admin/`、`devops/`、`collaboration/`
- **资源目录**：`examples/`、`images/`、`ui-demos/`
- **临时文件**：`plan/` 存放规划，`tmp/` 存放临时产物

## 建议维护方式

- 用户手册真值源放在 `doc/` 的分类子目录里
- 根 `README.md` 保持总览，不重复展开长篇内容
- `AGENTS.md` 只保留机器协作约束，不混入用户手册
- 当命令、环境变量或部署路径变化时，优先同步更新受影响专题文档

## 快速链接

- **项目主页**：[GitHub - cicys/sv-scaffold-ai](https://github.com/cicys/sv-scaffold-ai)
- **原始项目**：[GitHub - LuckyKuang/infoq-scaffold-ai](https://github.com/LuckyKuang/infoq-scaffold-ai)
