# infoq-plugin-security

## 1. 模块职责

提供 backend 的请求鉴权入口，负责全路径登录校验、客户端 ID 一致性校验，以及健康检查等免鉴权路径的统一排除。

## 2. 关键入口

- [`SecurityConfig`](./src/main/java/cc/infoq/common/security/config/SecurityConfig.java)
- [`AllUrlHandler`](./src/main/java/cc/infoq/common/security/handler/AllUrlHandler.java)
- [`SecurityProperties`](./src/main/java/cc/infoq/common/security/config/properties/SecurityProperties.java)
- [`SseProperties`](./src/main/java/cc/infoq/common/security/config/properties/SseProperties.java)

## 3. 核心类 / 文件

- 自动装配入口：[`AutoConfiguration.imports`](./src/main/resources/META-INF/spring/org.springframework.boot.autoconfigure.AutoConfiguration.imports)

## 4. 上游依赖

- 所有进入 backend 的受保护 HTTP 请求都会经过这个模块。
- SSE 路径是否排除鉴权，也由这里决定。

## 5. 下游依赖

- 编译期依赖 `infoq-plugin-satoken`

## 6. 关键配置

- `security.*`
- `sse.*`

## 7. 关键数据流

1. `SecurityConfig` 注册 Sa-Token 拦截器。
2. 拦截器通过 `AllUrlHandler` 取得需要保护的路径。
3. 请求进入后先检查是否登录，再校验 header / param 里的 `clientId` 是否与 token extra 一致。
4. `/monitor/health` 与 SSE 路径在这里显式排除，避免健康检查和长连接入口被 Sa-Token 拦截。

## 8. 扩展点

- `SecurityProperties` 排除路径
- `AllUrlHandler` 的 URL 汇总规则

## 9. 日志 / 监控切入点

- 登录态异常与 clientId 不一致都要从这里切入。
- 当前实现里它是鉴权主入口之一。

## 10. 已知边界

- 不负责 token 生成和存储细节，那部分在 `infoq-plugin-satoken`。
- 不负责业务权限数据本身，那部分仍在 `infoq-system`。
