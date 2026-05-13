# pages

## 1. 模块定位

`src/pages` 是 React admin 的页面层，承载固定公开页、系统管理页、监控页和少量跳转/错误页。

## 2. 子模块清单

- `login.tsx`、`register.tsx`、`forgot-password.tsx`、`index.tsx`
- `system/*`
- `monitor/*`
- `redirect/*`
- `error/*`

## 3. 子模块职责摘要

| 页面分组 | 当前职责 |
| --- | --- |
| `login`、`register`、`forgot-password` | 登录前公开入口与自助认证页面 |
| `index` | 登录后的首页入口 |
| `system/*` | 用户、角色、菜单、部门、岗位、字典、配置、公告、客户端、OSS、个人中心 |
| `monitor/*` | 在线用户、登录日志、操作日志、缓存、数据源、服务、任务与任务日志 |
| `redirect/*`、`error/*` | 路由跳转和错误展示 |

## 4. 依赖方向

- 页面依赖 `api/*` 获取后端数据。
- 页面依赖 `store/*` 获取登录态、权限、标签页等状态。
- 动态管理页实际入口由 `router/BackendRouteView.tsx` 解析后挂载。

## 5. 典型调用链

```text
Route match
-> BackendRouteView.tsx or fixed route
-> pages/*
-> api/*
-> utils/request.ts
-> backend
```

## 6. 公共约束

- 页面目录结构要与后端菜单 `component` 字段映射保持一致。
- 错误页与登录页属于固定页面，不能依赖后端动态菜单才可访问。
- 页面内部若只是局部 UI 调整，通常不需要层层同步到工作区总览；若影响入口、职责或链路，则需要同步。

## 7. 已知边界

- 页面级局部组件（如弹窗、子表单）仍然散落在页面目录内部，本文件只做父层聚合。
- 这里只记录当前已有页面分组，不推断未来页面矩阵。

## 8. 下钻阅读路径

1. 公开入口：`login.tsx`、`register.tsx`、`forgot-password.tsx`
2. 首页：`index.tsx`
3. 业务页：`system/*`
4. 监控页：`monitor/*`
