---
name: infoq-element-plus-component-reference
description: 参考 Element Plus 官方文档进行组件选型并实现 Vue 3 UI，确保 API 用法与版本兼容性正确。当需求提到 Element Plus/El* 组件、构建或重构包含表单/表格/弹窗的 Vue 页面，或需要确认当前 Element Plus 版本是否支持某个组件与特性时使用。
---

# InfoQ Element Plus 组件参考

以 Element Plus 官方文档作为组件选型与 API 使用的真值来源。
先阅读 `references/component-overview-zh-cn.md`，编码前再确认组件级 API。

## 工作流程

1. 对 UI 需求进行分类。
2. 从官方总览索引中挑选候选组件。
3. 编码前核对组件 API。
4. 结合 `package.json` 或 lockfile 检查本地 Element Plus 版本兼容性。
5. 实现 Vue 3 代码时使用 `script setup`，并尽量减少自定义 CSS。
6. 验证加载态、空态、错误态、禁用态和破坏性操作态。

## 参考资源

- `references/component-overview-zh-cn.md`
- `references/component-selection-playbook.md`
