# infoq-scaffold-frontend-weapp-vue 架构说明

本文档是对当前 weapp Vue 工作区代码结构的保守描述。

- 只写仓库里已经能直接确认的模块关系和装配行为。
- 不把页面级鉴权 composable 误写成全局 router guard。
- 如果未来页面注册方式、请求封装或会话边界变化，应把这里视为“当前实现说明”。

## 0. 下钻阅读入口

- 工作区总览：[`../README.md`](../README.md)
- `src/` 聚合入口：[`../src/README.md`](../src/README.md)
- 请求层：[`../src/api/README.md`](../src/api/README.md)
- 状态层：[`../src/store/README.md`](../src/store/README.md)
- 页面层：[`../src/pages/README.md`](../src/pages/README.md)

## 1. 模块分层

当前 weapp Vue 的主分层可以直接概括为：

```text
src/main.ts
-> src/pages.json
-> pages/*
-> api/*
-> api/request.ts
-> backend
```

辅助层还包括：

- `store/session.ts`：登录态、用户资料、权限缓存
- `composables/use-auth-guard.ts`：页面级鉴权与权限检查
- `components/*`：底部导航、列表卡片、分页条、状态标签等公共组件
- `utils/*`：导航、权限、环境、加密、头像、主题与错误辅助

## 2. 各模块当前职责

| 模块 | 当前职责 | 当前证据 |
| --- | --- | --- |
| `main.ts` | 创建 uni-app SSR 应用并注入 Pinia | `createSSRApp(App)`、`createPinia()` |
| `pages.json` | 注册全部页面路径与默认窗口样式 | `pages: [...]` |
| `api/request.ts` | 统一请求头、加密、重复提交、错误归一化与上传 | `request()`、`uploadFile()` |
| `store/session.ts` | 登录、拉取用户信息、登出、权限判断 | `signIn()`、`loadSession()`、`signOut()` |
| `composables/use-auth-guard.ts` | 判断是否已登录、是否有权限，并负责缺权限回跳 | `ensureAuthenticated()`、`ensurePermission()` |
| `pages/*` | 公开页、管理台页、系统管理页、监控页与个人中心 | `src/pages/**` |

## 3. 页面注册与访问模型

### 3.1 页面注册

当前页面不是通过路由器动态注入，而是直接写在 `src/pages.json`：

- 公开与基础页：`home`、`login`、`notices`、`notice-detail`、`notice-form`、`profile`、`profile-edit`
- 管理台入口：`admin`
- 系统管理：`system-users`、`system-roles`、`system-depts`、`system-posts`、`system-menus`、`system-dicts`
- 监控：`monitor-online`、`monitor-login-info`、`monitor-oper-log`、`monitor-cache`

### 3.2 页面级鉴权

当前没有 Web admin 那种中心化守卫；受保护页面通常会：

1. 先调用 `ensureAuthenticated()`
2. 再按需调用 `sessionStore.loadSession()`
3. 需要更细粒度权限时调用 `ensurePermission(permission, options)`

这意味着当前小程序端的访问控制被收束成“页面调用 composable”，但依然不是中心化 router middleware。

## 4. 请求与运行时边界

### 4.1 H5 与 weapp 分流

`api/request.ts` 会根据 `mobileEnv.taroEnv` 决定：

- base API 取 `baseApi` 还是 `miniBaseApi`
- 是否注入 `x-client-key=weapp`
- 是否注入 `x-device-type=weapp`

因此 H5 与小程序共用同一套请求封装，但运行时头与 base URL 可能不同。

### 4.2 统一请求出口

`api/request.ts` 负责：

- 拼装 `clientid`、`Authorization`
- GET 参数串行化
- 500ms 内重复提交拦截
- RSA/AES 请求加密与响应解密
- 401 清 token 与抛出 `AuthError`
- 域名白名单、超时、网络错误归一化

这使得 `api/*` 业务接口文件主要负责 URL、方法与类型，而不重复处理网络异常。

## 5. 状态边界

当前会话相关状态集中在单一 `store/session.ts`：

- `token`
- `user`
- `permissions`
- `initialized`

登录链路并不把权限单独拆到第二个 store；页面与 composable 直接从 session store 读取权限并做判断。

## 6. 公共约束

- 受保护页面必须显式处理“无 token / 无权限”路径，不能假设中心化守卫已经完成。
- 小程序环境的合法域名失败、超时和 `[object Object]` 文案，都应由 `api/request.ts` 显式归一化。
- `build-open:weapp*` 依赖真实 AppID 与 DevTools CLI；这类前置条件不应写进运行时代码。

## 7. 已知边界

- 当前没有为 `components`、`utils` 单独写更细的 README；这里只做父层职责摘要。
- 本文档只覆盖 `src/` 当前存在的页面和会话实现，不预判未来多 store 或中心化 guard 方案。
