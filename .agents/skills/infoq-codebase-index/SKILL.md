---
name: infoq-codebase-index
description: 维护并查询 infoq-scaffold-backend、infoq-scaffold-frontend-react、infoq-scaffold-frontend-vue 的同步文件索引。当用户询问类/组件/页面/API 文件/mapper/service/路由位置，请求全仓文件索引，或这三个工作区发生文件/类的新增、删除、重命名、移动时使用；在结束此类改动前运行同步脚本，确保 skill 引用与 AGENTS 路由保持最新。
---

# InfoQ 代码库索引

此技能用于两类场景：

1. 在 `infoq-scaffold-backend`、`infoq-scaffold-frontend-react`、`infoq-scaffold-frontend-vue` 之间进行跨工作区代码定位。
2. 在上述工作区发生文件/类新增、删除、重命名、移动或大规模结构变更后刷新索引。

## 工作流程

1. 仅阅读相关的生成索引文件：
   - 后端：`references/backend-index.md`
   - React 前端：`references/frontend-react-index.md`
   - Vue 前端：`references/frontend-vue-index.md`
2. 先从索引缩小候选范围，再用仓库搜索（`rg`）和源码阅读确认真值。
3. 若本轮改动涉及任一目标工作区的文件或类名变更，执行：

```bash
node .agents/skills/infoq-codebase-index/scripts/sync_indexes.mjs
```

该命令会刷新 skill 引用，并规范化相关 `AGENTS.md` 路由规则。

## 引用加载原则

- 当工作区不明确或需要刷新策略时，先读 `references/usage.md`。
- 除非任务明确跨工作区，否则不要一次加载全部三个索引文件。
- 生成索引来源于各子仓库 `git ls-files`，仅覆盖仓库受管文件。若本轮新建了文件，请先刷新索引。
