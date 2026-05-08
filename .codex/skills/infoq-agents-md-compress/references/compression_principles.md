# 压缩原则

## 原理说明

- 被动上下文优于“等待 agent 决定是否触发 skill”的方案：根 `AGENTS.md` 每轮都可见，没有额外决策点。
- 压缩索引优于长篇叙述：在有限上下文里优先保留规则和检索入口，而不是展开全文。
- 设计目标不是“把所有知识塞进 `AGENTS.md`”，而是“让 agent 知道去哪里读真值文件”。
- 动作型、垂直 workflow 仍应沉淀为独立 skill；根 `AGENTS.md` 负责横向、通用、每轮都需要的上下文。

## 标准行语法

- 所有索引行以 `|` 开头。
- 顶部尽早放置 retrieval-led `|IMPORTANT:` 行。
- 常用模式：
  - `|Category:path:{item1,item2,item3}`
  - `|Category:value1|value2|value3`

## 符号语义

- `|`：索引行起始与多值分隔。
- `:`：类别与内容分隔。
- `{}`：同类多项集合。
- `→`：流程或分层关系（如 `Controller→Service→Mapper→Entity`）。

## 压缩边界

保留：
- 高优先级规则、真值文件入口、workspace/skill 路由、配置路径、命令、PR 门禁。

删除：
- 解释性段落、背景故事、重复示例、完整教程式内容、应沉淀为独立 skill 的动作型 workflow 细节。
