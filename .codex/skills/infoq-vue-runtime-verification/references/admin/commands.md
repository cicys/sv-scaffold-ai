# Admin 命令

## 启动 Backend + Vue Admin

```bash
node .codex/skills/infoq-vue-runtime-verification/scripts/start_admin_dev_stack.mjs
```

若不使用 skill 主入口，可改用工作区原生命令手动启动。启动 backend 前先确认 `java -version` 与 `mvn -version` 指向 JDK 17。

Backend：

```bash
cd infoq-scaffold-backend
mvn clean install -DskipTests
java -jar infoq-admin/target/infoq-admin.jar --spring.profiles.active=local --captcha.enable=false
```

Vue Admin：

```bash
cd infoq-scaffold-frontend-vue
pnpm run dev -- --host 127.0.0.1 --port 5173 --strictPort
```

## 仅停止本技能启动的进程

```bash
node .codex/skills/infoq-vue-runtime-verification/scripts/stop_admin_dev_stack.mjs
```

## 打印 Token 注入片段

```bash
node .codex/skills/infoq-vue-runtime-verification/scripts/print_admin_login_inject_snippet.mjs
```

## 从后端抓取真实路由

```bash
node .codex/skills/infoq-vue-runtime-verification/scripts/fetch_admin_routes_with_token.mjs
```

## 默认 Admin URL

- 登录页：`http://127.0.0.1:5173/login`
- 首页壳：`http://127.0.0.1:5173/index`
- 后端验证码探针：`http://127.0.0.1:8080/auth/code`

## 浏览器验证模式

1. 启动本地栈，或至少确保 backend `http://127.0.0.1:8080` 与 Vue admin `http://127.0.0.1:5173` 已可访问。
2. 若只需要查看真实后端返回的受保护路由列表，执行：

```bash
pnpm --dir .codex/skills/infoq-browser-automation/scripts run playwright-cli admin-route-probe --backend-url "http://127.0.0.1:8080" --list-routes
```

3. 对目标受保护路由执行 CLI-first 浏览器探测：

```bash
pnpm --dir .codex/skills/infoq-browser-automation/scripts run playwright-cli admin-route-probe --frontend-origin "http://127.0.0.1:5173" --route "/index"
```

4. 只有在需要临时交互探索或定位器发现时，才改用 Playwright MCP。
