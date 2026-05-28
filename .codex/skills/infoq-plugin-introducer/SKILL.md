---
name: infoq-plugin-introducer
description: 依据仓库既定治理模型（基座必需 / 通用能力 / 可配置软开关）引入或重构插件，覆盖 backend+frontend 接线与验证。适用于新增插件、插件引入、插件开关化、可拔插改造、插件脚手架与插件治理更新等请求。
---

# Infoq 插件引入器

## 适用范围

当你需要新增插件模块、把现有能力迁移到 `infoq-plugin`，或判断插件应该是固定依赖、可复用能力、还是可开关能力时，使用此技能。

## 快速执行

先生成一份可执行的插件接入计划：

```bash
node .codex/skills/infoq-plugin-introducer/scripts/generate_plugin_plan.mjs \
  --name infoq-plugin-xxx \
  --class toggle \
  --frontend auto
```

分类参数可选值：
- `fixed`
- `reusable`
- `toggle`

可选输出文件：

```bash
node .codex/skills/infoq-plugin-introducer/scripts/generate_plugin_plan.mjs \
  --name infoq-plugin-xxx \
  --class reusable \
  --out doc/tmp/plugin-plan.md
```

## 先分类再编码

编码前先对插件分类：

1. `基座固定保留`:
- 属于核心运行时依赖，移除会破坏基础启动/鉴权/数据主链路。
- 作为稳定依赖保留，不需要运行期开关。

2. `通用能力插件`:
- 为多个业务模块提供可复用能力（注解/工具/事件等形态）。
- 保留插件模块，由业务模块通过依赖选择接入。

3. `可配置软关闭插件`:
- 能力可通过配置启用/关闭，且无需删除依赖。
- 在系统模块保留依赖，默认 `enabled=false`。
- 如前端依赖该能力，增加配套 `VITE_APP_*` 开关。

若分类不清晰，请先阅读：
- `doc/collaboration/plugin-catalog.md`
- `references/plugin-matrix.md`

## 后端集成

以新插件模块 `infoq-plugin-xxx` 为例：

1. 模块注册：
- 在 `infoq-scaffold-backend/infoq-plugin/pom.xml` 注册模块。

2. 版本管理：
- 在 `infoq-scaffold-backend/infoq-core/infoq-core-bom/pom.xml` 增加版本属性/依赖管理。

3. 消费方依赖：
- 在目标业务模块 `pom.xml` 增加依赖（通常是 `infoq-scaffold-backend/infoq-modules/infoq-system/pom.xml`）。
- 对共享领域能力，优先由 `infoq-core-data` 或确实需要它的模块接入。

4. 配置：
- 对软开关插件，在 `application.yml` 定义后端开关并默认 `false`。
- 避免在非条件化配置中硬编码插件启动逻辑。

5. 耦合控制：
- 保持插件 API 边界收敛（注解、接口、门面、自动配置）。
- 不向业务模块泄露插件内部实现细节。

## 前端集成（仅在需要时）

当插件影响客户端运行时行为时：

1. 增加 env 开关：
- `infoq-scaffold-frontend-vue/.env.development`
- `infoq-scaffold-frontend-vue/.env.production`
- `infoq-scaffold-frontend-react/.env.development`
- `infoq-scaffold-frontend-react/.env.production`

2. 在受影响前端的 bootstrap/hooks/utils 中，通过 env 开关控制运行时逻辑。

3. 当开关为 `false` 时，必须保留可用回退路径（避免 UI 断裂或请求悬挂）。

## 验证基线

前端验证优先使用 `pnpm`。若当前环境不可用，则使用等价 `npm` 命令。

至少执行：

```bash
node .codex/scripts/backend_mvn.mjs -- clean package -P dev -pl infoq-modules/infoq-system -am
cd infoq-scaffold-frontend-vue && pnpm run build:prod
```

如果插件影响登录/鉴权/运行时路由，执行相关冒烟验证：
- `infoq-backend-smoke-test`
- `infoq-login-success-check`
- 受影响前端对应的 `infoq-vue-runtime-verification` 或 `infoq-react-runtime-verification`

## 退出标准

以下条件必须全部满足：

1. 插件分类已记录（固定基座/可复用通用/可配置软开关）。
2. POM 接线完整且最小化。
3. 后端开关默认值正确（可开关插件默认 `false`）。
4. 涉及客户端行为时，前端开关已配套。
5. 后端打包与前端构建均通过。
6. 若运行时行为发生变化，冒烟验证通过且无明显回归。

## 参考资源

- 治理真值：`doc/collaboration/plugin-catalog.md`
- 快速矩阵：`references/plugin-matrix.md`
