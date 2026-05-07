# InfoQ 代码库索引使用说明

当你在深入阅读前需要快速了解仓库文件分布时，使用此技能。

相关生成索引：
- `backend-index.md`: `infoq-scaffold-backend`
- `frontend-react-index.md`: `infoq-scaffold-frontend-react`
- `frontend-vue-index.md`: `infoq-scaffold-frontend-vue`

推荐检索流程：
1. 先判断最可能的工作区。
2. 读取对应的生成索引文件。
3. 缩小到候选路径。
4. 使用 `rg "<class-or-symbol>" <workspace>` 后打开真实源码文件。

刷新规则：
- 当三个工作区任意一个发生 add/delete/rename/move/class-name change 时，执行 `node .agents/skills/infoq-codebase-index/scripts/sync_indexes.mjs`。
- 该脚本会重建生成索引，并重写相关 `AGENTS.md` 路由行，确保后续回合可自动触发本技能。
