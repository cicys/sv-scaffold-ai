<div align="center">

<img src="doc/images/logo.png" width="120" alt="SV-Scaffold Logo" />

# SV-Scaffold-AI

> Spring Boot 3.x + Vue 3.x 全栈脚手架。以 AI 为主力研发，通过 `AGENTS.md` 约束协作规则，`.codex/skills` 固化自动化 SOP，`OpenSpec` 管理规格与变更。

![Version](https://img.shields.io/badge/Version-2.1.5-f66a39)
![JDK](https://img.shields.io/badge/JDK-17-1677FF)
![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.5.14-6DB33F)
![Vue](https://img.shields.io/badge/Vue-3.5.35-42B883)
![Element Plus](https://img.shields.io/badge/Element%20Plus-2.14.1-409EFF)
![License](https://img.shields.io/badge/License-MIT-F7C948)

</div>

---

## 项目简介

`sv-scaffold-ai` 是一个 Spring Boot 3.x + Vue 3.x 的精简全栈脚手架。从原 `infoq-scaffold-ai` 裁剪而来，移除了 React 管理端和小程序端，聚焦于 Spring Boot 后端 + Vue 管理端的最佳实践。

当前仓库包含：

- **Spring Boot 3.5 多模块后端**
- **Vue 3 + Element Plus 管理端**
- **完整的 AI 协作资产**：AGENTS.md、.codex/skills、OpenSpec
- **Docker Compose 一键部署**：包括 MySQL、Redis、MinIO、Spring Boot、Vue
- **数据库初始化脚本**：完整的 SQL 初始化和升级脚本
- **文档和部署脚本**

## 项目定位

本项目适合以下场景：

1. **AI-first 工程协作**：通过 `AGENTS.md`、`skills`、`OpenSpec`、MCP 让 AI 按规约工作
2. **Spring Boot + Vue 技术栈**：提供完整的后端和前端实现
3. **可运行、可验证、可部署**：本地联调、单元测试、Docker Compose 部署都在同一仓库完成
4. **企业级管理后台**：包含用户、角色、权限、菜单、部门、字典等核心模块

## 仓库结构

```text
sv-scaffold-ai
├── AGENTS.md                          # AI 协作规约
├── .codex/                            # AI 自动化能力
├── openspec/                          # 规格和变更管理
├── infoq-scaffold-backend/            # Spring Boot 后端
│   ├── infoq-admin/                   # 启动模块
│   ├── infoq-core/                    # 公共基础
│   ├── infoq-modules/                 # 业务模块
│   └── infoq-plugin/                  # 插件扩展
├── infoq-scaffold-frontend-vue/       # Vue 管理端
├── infoq-scaffold-docs/               # 文档站（可选）
├── script/                            # 部署脚本
├── sql/                               # 数据库脚本
└── doc/                               # 文档
```

## 技术栈

| 维度 | 技术栈 |
| --- | --- |
| **后端** | Spring Boot `3.5.14`、JDK `17`、MyBatis-Plus `3.5.16`、Sa-Token `1.44.0` |
| **Vue 管理端** | Vue `3.5.35`、TypeScript `6.0.3`、Vite `8.0.16`、Element Plus `2.14.1`、Pinia、Vue Router `5.1.0` |
| **数据库** | MySQL `8`、Redis `7`、MinIO |
| **构建和测试** | Maven、pnpm、Vitest |
| **部署** | Docker Compose |

## 环境要求

| 组件 | 版本 |
| --- | --- |
| **Docker & Docker Compose** | 最新版本 |
| **JDK** | 17 (本地开发时) |
| **Maven** | 3.9+ (本地开发时) |
| **Node.js** | `^20.19.0 || ^22.13.0 || >=24.0.0` (本地开发时) |
| **pnpm** | `>= 10.0.0` (本地开发时) |

## 快速开始

### 方式一：Docker Compose（推荐，无需本地数据库）

```bash
# 1. 进入项目
cd sv-scaffold-ai

# 2. 进入 Docker 目录
cd script/docker

# 3. 设置安全密钥
export SECURITY_TOKEN_SECRET="your-secure-token-at-least-32-chars"

# 4. 启动所有服务
docker-compose up -d

# 5. 检查运行状态
docker-compose ps
```

### 启动后可以访问：

| 服务 | 地址 | 说明 |
| --- | --- | --- |
| **Vue 管理端** | http://localhost/vue | 前端页面 |
| **后端 API** | http://localhost:9090 | Spring Boot（通过 Nginx 代理为 /prod-api） |
| **MySQL** | localhost:3306 | 用户：root，密码：root |
| **Redis** | localhost:6379 | 密码：123456 |
| **MinIO** | http://localhost:9001 | 用户：infoq，密码：infoq123 |

### 默认登录凭证：

- **用户名**：admin
- **密码**：admin123

### 方式二：本地开发（需要手动搭建 MySQL、Redis）

#### 后端：

```bash
cd infoq-scaffold-backend
node ../../.codex/scripts/backend_mvn.mjs -- clean install -DskipTests
java -jar infoq-admin/target/infoq-admin.jar --spring.profiles.active=local
```

访问：`http://127.0.0.1:8080`

#### 前端（新终端）：

```bash
cd infoq-scaffold-frontend-vue
pnpm install
pnpm run dev
```

## 常用命令

### Docker 操作

```bash
# 启动所有服务
cd script/docker
docker-compose up -d

# 查看日志
docker-compose logs -f infoq-admin

# 停止所有服务
docker-compose down

# 清理所有数据（谨慎！）
docker-compose down -v
```

### 后端开发

```bash
cd infoq-scaffold-backend

# 编译
node ../../.codex/scripts/backend_mvn.mjs -- clean package -P dev

# 运行单元测试
node ../../.codex/scripts/backend_mvn.mjs -- -pl infoq-modules/infoq-system -am -DskipTests=false test
```

### 前端开发

```bash
cd infoq-scaffold-frontend-vue

# 安装依赖
pnpm install

# 开发
pnpm run dev

# 单元测试
pnpm run test:unit

# 构建生产版本
pnpm run build:prod

# ESLint 检查
pnpm run lint:eslint
```

## 系统功能

### 核心模块

- **用户管理**：用户添加、修改、删除、重置密码
- **角色管理**：角色权限配置
- **菜单权限**：动态菜单和权限管理
- **部门管理**：组织架构
- **岗位管理**：岗位配置
- **字典管理**：系统字典
- **参数设置**：系统配置
- **通知公告**：系统通知
- **文件管理**：文件上传、下载
- **客户端管理**：应用授权

### 系统监控

- **在线用户**：实时在线用户查看
- **登录日志**：登录记录查询
- **操作日志**：用户操作记录
- **定时任务**：Quartz 任务管理
- **缓存监控**：Redis 缓存监控
- **服务监控**：系统服务状态
- **连接池监控**：数据库连接池监控

## 部署

详见 `doc/devops/` 目录：

- [`doc/devops/deploy-prerequisites.md`](./doc/devops/deploy-prerequisites.md) - 部署前检查
- [`doc/devops/docker-compose-deploy.md`](./doc/devops/docker-compose-deploy.md) - Docker Compose 部署
- [`doc/devops/manual-deploy.md`](./doc/devops/manual-deploy.md) - 手动部署

## 验证建议

提交前至少执行最小验证：

### 后端变更

```bash
cd infoq-scaffold-backend
node ../../.codex/scripts/backend_mvn.mjs -- clean package -P dev
```

### 前端变更

```bash
cd infoq-scaffold-frontend-vue
pnpm run test:unit
pnpm run build:prod
```

## 文档导航

- **项目文档中心**：[`doc/README.md`](./doc/README.md)
- **后端手册**：[`doc/backend/handbook.md`](./doc/backend/handbook.md)
- **管理端手册**：[`doc/admin/handbook.md`](./doc/admin/handbook.md)
- **协作体系**：[`doc/collaboration/development-workflow.md`](./doc/collaboration/development-workflow.md)

## 变更记录

### v2.1.5 (Spring Boot + Vue Only)

- ✂️ 从 infoq-scaffold-ai 裁剪而来
- ❌ 移除 React 管理端 (`infoq-scaffold-frontend-react/`)
- ❌ 移除 Vue 小程序端 (`infoq-scaffold-frontend-weapp-vue/`)
- ❌ 移除 React 小程序端 (`infoq-scaffold-frontend-weapp-react/`)
- ✅ 保留 Spring Boot 3.5 后端
- ✅ 保留 Vue 3 + Element Plus 管理端
- ✅ 保留完整的 Docker Compose 部署方案

## 许可证

[MIT License](./LICENSE)

## 参考

- 原始项目：[LuckyKuang/infoq-scaffold-ai](https://github.com/LuckyKuang/infoq-scaffold-ai)
- Fork 项目：[cicys/sv-scaffold-ai](https://github.com/cicys/sv-scaffold-ai)
