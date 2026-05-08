# src

## 1. 模块定位

`src/` 是 weapp React 的主实现层，承载应用入口、页面、会话状态、请求封装、导航与运行时工具。

## 2. 子模块清单

- [`api`](./api/README.md)：请求封装、业务接口与环境桥接。
- [`store`](./store/README.md)：登录态、用户信息与权限缓存。
- [`pages`](./pages/README.md)：公开页、管理台页、系统管理页与监控页。
- `components`：底部导航与 Taro UI 组件封装。
- `utils`：导航、权限、环境、加密、主题、错误与头像辅助。
- `assets`、`styles`：静态资源与公共样式。

## 3. 子模块职责摘要

| 子模块 | 当前职责 |
| --- | --- |
| `api` | 统一请求出口与业务接口契约 |
| `store` | 维护会话真值与权限缓存 |
| `pages` | 承载实际页面与页面级鉴权调用 |
| `components/utils` | 承载跨页面 UI 与运行时辅助能力 |

## 4. 依赖方向

- `pages` 依赖 `api`、`store`、`components`、`utils`。
- `api` 统一依赖 `api/request.ts`。
- `store/session.ts` 依赖 `api/index.ts` 聚合导出的登录、用户和权限工具。

## 5. 典型调用链

```text
app.ts + app.config.ts
-> pages/*
-> store/session.ts
-> api/*
-> api/request.ts
-> backend
```

## 6. 公共约束

- 页面注册变化时，先更新 `pages/README.md` 和工作区总览。
- 会话与权限边界变化时，先更新 `store/README.md`。
- 请求、加密、域名校验或错误归一化变化时，先更新 `api/README.md`。

## 7. 已知边界

- 当前没有中心化路由守卫目录；页面访问控制散布在具体页面实现中。
- `components`、`utils` 当前没有单独 README；需要深入时直接看源码文件。

## 8. 下钻阅读路径

1. [`api/README.md`](./api/README.md)
2. [`store/README.md`](./store/README.md)
3. [`pages/README.md`](./pages/README.md)
