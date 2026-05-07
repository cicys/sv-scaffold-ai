---
name: infoq-vue-runtime-verification
description: 执行本项目 Vue 家族的仓库专用运行态验证，覆盖 `infoq-scaffold-frontend-vue` 管理端与 `infoq-scaffold-frontend-weapp-vue` 小程序流程。适用于 Vue 登录校验、路由校验、本地栈启动/重启、截图、控制台诊断与小程序 smoke/e2e；通用站点浏览器任务优先使用 `infoq-browser-automation`。
---

# InfoQ Vue 运行态验证

本技能只负责一件事：本仓库 Vue 家族的运行态验证。

覆盖两个客户端：

- `admin`: `infoq-scaffold-frontend-vue`
- `weapp`: `infoq-scaffold-frontend-weapp-vue`

## 客户端选择

1. 涉及浏览器登录、路由守卫、页面截图、控制台诊断、本地 backend + Vue admin 启动时，使用 `admin` 路径。
2. 涉及微信开发者工具打开流程、小程序登录、路由遍历、API 契约覆盖或 e2e 冒烟时，使用 `weapp` 路径。
3. 若是非仓库特定启动流程的通用网站自动化，改用 `infoq-browser-automation`。

## Admin 工作流

1. 若当前环境支持 `bash`，可使用 `scripts/start_admin_dev_stack.sh` 启动或重启 backend + Vue admin 栈。
2. 若当前环境不适合执行 `bash`，手动启动 backend 与 Vue admin；启动前先确认 `java -version` 与 `mvn -version` 指向 JDK 17。
3. 通过 `scripts/print_admin_login_inject_snippet.sh` 或 `scripts/fetch_admin_routes_with_token.sh` 获取辅助信息时，不要猜测真实路由。
4. 默认使用 `infoq-browser-automation` 的跨平台 CLI 对 `http://127.0.0.1:5173` 执行受保护路由探测、截图与 console 检查：

```bash
pnpm --dir .agents/skills/infoq-browser-automation/scripts run playwright-cli -- admin-route-probe --frontend-origin "http://127.0.0.1:5173" --route "/index"
```

5. 只有在临时交互探索时才改用 Playwright MCP。
6. 使用 `scripts/stop_admin_dev_stack.sh` 时，只停止本技能启动的进程。

## Weapp 工作流

1. 在任何 `build-open:weapp` 命令前，把 `infoq-scaffold-frontend-weapp-vue/.env.development` 中的 `TARO_APP_ID` 替换成你自己的小程序 AppID。空值和 `touristappid` 会被启动脚本拒绝。
2. 当任务是“自动化启动小程序”或“打开微信开发者工具联调”时，使用：
   - `pnpm --dir infoq-scaffold-frontend-weapp-vue build-open:weapp:dev`
3. 进行可复现的 smoke/e2e 验证时，使用 `scripts/run_weapp_smoke.sh`，并根据范围选择 `--suite smoke|core|full`。
4. 若 smoke 流程依赖后端登录，确保 backend `http://127.0.0.1:8080` 可达且关闭验证码。
5. 将 smoke 日志里的 `[object Object]` 视为产品缺陷，而不是可容忍测试现象。

## 护栏

- 不要在 `.agents/skills` 下为 Vue 运行态工作重新引入共享底座 helper skill。
- 当后端路由 API 可查询时，禁止猜测 admin 路由。
- 本地验证时不要把小程序 AppID 硬编码进源码，保留在 `.env.*` 或 shell 环境变量里。
- 浏览器或开发者工具启动失败时，禁止标记运行态验证通过。
- 当前环境若无法执行 `bash`，应手动启动 backend / Vue admin 后继续使用跨平台 `playwright-cli`；不要因为包装脚本不可用而跳过运行态验证。

## 参考

- `references/admin/commands.md`
- `references/weapp/commands.md`
- `references/weapp/endpoints.md`
