# 接口检查清单

仅当以下检查全部通过时，登录成功校验才算通过：

1. `GET /auth/code`
- HTTP 200
- JSON `code = 200`
- `data.captchaEnabled = false`

2. `POST /auth/login`
- 优先加密请求
- 失败时回退明文请求
- JSON `code = 200`
- response contains `data.access_token` or `data.accessToken`

3. `GET /system/user/getInfo`
- 已鉴权
- JSON `code = 200`
- response contains `data.user.userName`

4. `GET /system/menu/getRouters`
- 已鉴权
- JSON `code = 200`
