---
name: infoq-react-unit-test-patterns
description: 为本仓库 React 家族构建并扩展单元测试，覆盖 `infoq-scaffold-frontend-react` 管理端与 `infoq-scaffold-frontend-weapp-react` 小程序端。适用于 React 单测、覆盖率回补、回归验证、确定性缺陷复现与 test-first 修复；按 `admin`/`weapp` 参考分流，并将运行态后续交给 `infoq-react-runtime-verification`。
---

# InfoQ React 单测模式

本技能只负责一件事：React 家族单元测试工作。
覆盖两个客户端：

- `admin`: `infoq-scaffold-frontend-react`
- `weapp`: `infoq-scaffold-frontend-weapp-react`

## 客户端选择

1. `admin` 端参考适用于 React 19 + Ant Design + React Router + Zustand 页面与工具。
2. `weapp` 端参考适用于 Taro React 小程序页面、请求封装、store 与 API 契约。
3. 若任务是运行态验证而非单测，请切换到 `infoq-react-runtime-verification`。

## 工作流程

1. 识别客户端，只加载匹配的 `references/admin/*` 或 `references/weapp/*` 材料。
2. 新增 helper 或 mock 前，优先复用现有测试基线。
3. 先测用户可观察行为与边界场景，而非实现细节。
4. 先跑定向测试；若暴露源码缺陷，先修产品代码，再扩大测试集。
5. 若运行时行为发生变化，收尾时执行 `infoq-react-runtime-verification`。
6. 最终通过客户端对应质量门禁。

## 完成标准

### Admin

```bash
cd infoq-scaffold-frontend-react
pnpm run test
pnpm run test:coverage
pnpm run lint
pnpm run build:prod
```

### Weapp

```bash
cd infoq-scaffold-frontend-weapp-react
pnpm run test
pnpm run test:coverage
pnpm run lint
pnpm run build:weapp:dev
pnpm run build:weapp
```

当改动同时影响小程序运行路径时，执行 `pnpm run verify:local`。

## 护栏

- 除非流程确实分叉，否则不要再把 React admin 与 React weapp 单测拆成两个技能。
- 禁止通过弱化断言、放宽 mock、伪造成功路径来硬凑覆盖率。
- 禁止用运行态 smoke 替代缺失的单测覆盖。

## 参考

- `references/admin/commands.md`
- `references/admin/setup-baseline.md`
- `references/admin/priority-matrix.md`
- `references/admin/mock-patterns.md`
- `references/weapp/commands.md`
- `references/weapp/priority-matrix.md`
- `references/weapp/mock-patterns.md`
