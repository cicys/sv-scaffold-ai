# Admin 命令

以下命令优先使用 `pnpm`。若当前环境不可用，可替换为等价 `npm` 命令。

## 安装与初始化

```bash
cd infoq-scaffold-frontend-vue
pnpm install
```

## 运行单个测试文件

```bash
cd infoq-scaffold-frontend-vue
npx vitest --config vitest.config.ts --run tests/utils/request.test.ts
```

## 运行 P1 插件与实时能力批次

```bash
cd infoq-scaffold-frontend-vue
npx vitest --config vitest.config.ts --run \
  tests/plugins/download.test.ts \
  tests/plugins/modal.test.ts \
  tests/plugins/tab.test.ts \
  tests/utils/sse.test.ts \
  tests/utils/websocket.test.ts
```

## 运行 P2 组件与轻量页面

```bash
cd infoq-scaffold-frontend-vue
npx vitest --config vitest.config.ts --run \
  tests/components/Breadcrumb.test.ts \
  tests/components/Pagination.test.ts \
  tests/components/RightToolbar.test.ts \
  tests/components/DictTag.test.ts \
  tests/components/IconSelect.test.ts \
  tests/views/error401.test.ts \
  tests/views/error404.test.ts \
  tests/views/redirect.test.ts \
  tests/views/index.test.ts
```

## 运行 P3 重型系统/监控页面

```bash
cd infoq-scaffold-frontend-vue
npx vitest --config vitest.config.ts --run \
  tests/views/system/menu/index.test.ts \
  tests/views/system/user/index.test.ts \
  tests/views/system/notice/index.test.ts \
  tests/views/system/config/index.test.ts \
  tests/views/system/client/index.test.ts \
  tests/views/system/oss/index.test.ts \
  tests/views/system/oss/config.test.ts \
  tests/views/monitor/online/index.test.ts \
  tests/views/monitor/loginInfo/index.test.ts \
  tests/views/monitor/cache/index.test.ts \
  tests/views/monitor/operLog/index.test.ts \
  tests/views/monitor/operLog/oper-info-dialog.test.ts
```

## 运行态后续验证

```bash
node .agents/skills/infoq-vue-runtime-verification/scripts/start_admin_dev_stack.mjs
node .agents/skills/infoq-vue-runtime-verification/scripts/print_admin_login_inject_snippet.mjs
node .agents/skills/infoq-vue-runtime-verification/scripts/fetch_admin_routes_with_token.mjs
```

## 全量质量门禁

```bash
cd infoq-scaffold-frontend-vue
pnpm run test:unit
pnpm run test:unit:coverage
pnpm run lint:eslint
pnpm run build:prod
```
