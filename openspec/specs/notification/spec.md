# 通知与实时提醒规范

## 目标

定义当前仓库的通知公告管理、公告创建后的实时广播，以及管理端的 SSE / WebSocket 提醒入口。

## 要求

### 要求：公告管理入口
通知公告必须继续通过统一后台接口维护。

#### 场景：查询或维护公告

- 当管理员操作通知公告时
- 则必须继续使用 `/system/notice/list`、`/system/notice/{noticeId}`、`POST /system/notice`、`PUT /system/notice`、`DELETE /system/notice/{noticeIds}`
- 并且权限标识必须继续使用 `system:notice:*`

### 要求：新增公告后广播提醒
成功创建公告后必须向实时通道广播一条简短提醒。

#### 场景：新增公告成功

- 当 `POST /system/notice` 插入成功时
- 则系统必须按 `[{公告类型中文名}] {公告标题}` 的格式向所有用户广播消息
- 并且当 `sse.enabled=false` 时，新增公告流程不得因广播链路而失败

### 要求：前端提醒通道开关
管理端的实时通道必须受环境开关和 token 状态控制。

#### 场景：初始化实时通道

- 当 React 或 Vue 管理端初始化实时提醒时
- 则只有在 `VITE_APP_SSE=true` 时才允许连接 `/resource/sse`
- 并且只有在 `VITE_APP_WEBSOCKET=true` 时才允许连接 `/resource/websocket`
- 并且缺少 token 时必须跳过连接而不是伪造成功

### 要求：提醒展示
实时消息必须落到统一的 notice store，并驱动布局层提醒展示。

#### 场景：收到实时消息

- 当管理端收到 SSE 或 WebSocket 消息时
- 则消息必须写入 notice store
- 并且布局层未读计数和通知面板必须基于 notice store 展示
