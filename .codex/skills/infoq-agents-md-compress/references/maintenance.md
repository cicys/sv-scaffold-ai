# 维护指南

## 何时需要重新压缩

- 新增/重命名模块、目录结构变化。
- 构建或测试命令变化。
- 引入新质量门禁（lint/test/release）。
- docs root、workspace `AGENTS.md`、skill root 或真值文件入口变化。
- AGENTS 行数明显膨胀，出现解释性段落或长 SOP 回流。

## 预警信号

- 出现多个 `##` 小节、长段落或完整 SOP。
- 索引行与代码实际路径不一致。
- 同一规则在多行重复。
- 动作型 workflow 重新堆回根 `AGENTS.md`。

## 维护流程

1. 备份当前 `AGENTS.md`。
2. 对照现有仓库结构和真值文件核验路径。
3. 将长 SOP 下沉到 `doc/`、`references/` 或更近 `AGENTS.md`。
4. 重新压缩为索引行，保证顺序为 `IMPORTANT -> scope -> retrievable roots -> commands/gates -> routing`。
5. 运行 `scripts/example.mjs` 校验。
6. 提交变更并在 PR 描述中说明影响范围。
