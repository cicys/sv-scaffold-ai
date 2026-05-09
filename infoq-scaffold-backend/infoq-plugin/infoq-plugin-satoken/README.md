# infoq-plugin-satoken

## 1. 模块职责

提供 Sa-Token 的配置、Redis 持久化实现、权限服务实现和登录辅助工具。

## 2. 关键入口

- [`SaTokenConfig`](./src/main/java/cc/infoq/common/satoken/config/SaTokenConfig.java)
- [`PlusSaTokenDao`](./src/main/java/cc/infoq/common/satoken/core/dao/PlusSaTokenDao.java)
- [`SaPermissionImpl`](./src/main/java/cc/infoq/common/satoken/core/service/SaPermissionImpl.java)
- [`LoginHelper`](./src/main/java/cc/infoq/common/satoken/utils/LoginHelper.java)

## 3. 核心类 / 文件

- 自动装配入口：[`AutoConfiguration.imports`](./src/main/resources/META-INF/spring/org.springframework.boot.autoconfigure.AutoConfiguration.imports)
- 资源文件：[`common-satoken.yml`](./src/main/resources/common-satoken.yml)

## 4. 上游依赖

- `infoq-system` 的登录、登出、在线用户和权限查询链路依赖这个模块。
- `infoq-plugin-security` 在路由拦截时直接调用 Sa-Token 校验。

## 5. 下游依赖

- 编译期依赖 `infoq-core-common`、`infoq-plugin-redis`

## 6. 关键配置

- Sa-Token 相关配置
- `common-satoken.yml`

## 7. 关键数据流

1. 启动时装配 Sa-Token 配置和 DAO。
2. 登录成功后 `LoginHelper` 协助写入 token 与扩展信息。
3. 后续请求由安全层读取 token 并继续做权限与 clientId 一致性校验。

## 8. 扩展点

- `SaPermissionImpl`
- `LoginHelper`
- 自定义 Sa-Token DAO 与权限判断策略

## 9. 日志 / 监控切入点

- 该模块本身没有独立监控控制器。
- token、权限、在线用户异常时，应与 `security`、`redis` 一起联动排查。

## 10. 已知边界

- 它负责 Sa-Token 基础设施，不直接定义业务权限页面或菜单接口。

