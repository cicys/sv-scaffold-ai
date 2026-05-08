---
name: infoq-ui-ux-three-phase-protocol
description: "在保持设计 intelligence 解耦的前提下，执行本仓库四阶段 UI 工作流：Phase 1 ASCII 布局提案、Phase 2 独立静态 Demo、Phase 3 在目标工作区正式实现、Phase 4 运行态验证。适用于重大 UI/UX 工作，以及 `LAYOUT APPROVED`、`DEMO APPROVED` 这类审批门禁流程。"
---

# InfoQ UI UX 四阶段协议

当 UI 任务需要明确审批门禁和稳定视觉基线时，使用此技能。
不要假设 Tailwind、Capacitor、Hono 或任何目标工作区并未实际使用的技术栈。

## 核心原则

- 保持协议精简：该技能只负责流程门禁与交付纪律。
- 保持设计 intelligence 解耦：高级风格/配色/字体推理放在：
  - `references/design-intelligence-overlay.md`
- 严格保持栈一致性：仅用目标工作区真实技术栈实现。

## 必需工作流（门禁）

### Phase 1: Layout Specification

在编写框架代码或业务逻辑之前：

1. 提供布局规范，至少包含：
   - 结构
   - 目标组件策略
   - 响应式策略
2. 提供桌面端与移动端 ASCII 线框图。
3. 可选：参考 `references/design-intelligence-overlay.md` 选择一个风格方向和一组语义 token。
4. 停止并等待精确口令 `LAYOUT APPROVED`。

### Phase 2: Static Demo

在 `LAYOUT APPROVED` 之后：

1. 在 `doc/ui-demos/<change-id>.html` 创建独立静态 Demo。
2. 使用原生 HTML 与轻量 CSS，必要时再使用 CDN 资源。
3. 视觉语言必须匹配目标工作区，禁止强行套用外部设计体系。
4. 执行本文件中的交付前质量清单。
5. 停止并等待精确口令 `DEMO APPROVED`。

### Phase 3: Formal Implementation

在 `DEMO APPROVED` 之后：

1. 在目标工作区真实技术栈内实现。
2. React admin 必须遵循 React + Ant Design。
3. Vue admin 必须遵循 Vue + Element Plus。
4. weapp React 必须遵循 Taro React 页面与组件约束。
5. weapp Vue 必须遵循 uni-app Vue 页面与组件约束。
6. 在接入复杂业务逻辑前先稳定 UI 壳层。

### Phase 4: Runtime Verification

1. 按已批准的布局和 Demo 基线验证实现后的 UI。
2. admin 浏览器流程使用 Playwright 或 `infoq-browser-automation`。
3. weapp 开启流程与冒烟检查使用对应 React/Vue 运行态验证技能。
4. 基于真实运行行为执行本文件交付前质量清单。
5. 将可见布局漂移、路由漂移、控制台错误视为验证失败。

## 交付前质量清单（Phase 2 + Phase 4）

1. 可访问性基线：
   - 文本对比度可读（目标 WCAG AA）
   - 可交互控件键盘焦点可见
   - 纯图标按钮具备可访问标签
2. 交互基线：
   - 主要点击/触达目标不应过小（目标至少 44x44）
   - 加载与错误反馈在操作上下文附近可见
3. 响应式基线：
   - 在常见宽度 375 / 768 / 1024 / 1440 验证
   - 主流程中无意外横向滚动
4. 视觉系统基线：
   - 使用语义 token（避免全局散落原始值）
   - 标题/正文/标签层级一致
5. 动效与稳定性基线：
   - 动效有明确意义并可尊重 reduced-motion 偏好
   - 初始加载与异步更新阶段无明显布局跳动
6. 运行时基线：
   - 已批准流程中无未处理控制台错误
   - 路由跳转符合已批准结构

## 反模式（禁止引入）

- 跳过 `LAYOUT APPROVED` 或 `DEMO APPROVED` 门禁。
- 将重大 UI 需求直接变成框架实现。
- 让静态 Demo 长期演化为影子实现。
- 在应使用图标体系的场景以 emoji 充当产品图标。
- 仅依赖颜色传达关键状态，缺少文本/图标支撑。
- 添加损害可读性或交互清晰度的装饰性动效。
- 以“视觉优化”为名更改技术栈约定。

## 配套 Intelligence 层（解耦）

当重大视觉方向不明确时，加载：

- `references/design-intelligence-overlay.md`

用于生成紧凑的风格建议包（风格方向、语义色、字体、反模式）。
不要盲目复制大段模板。保持协议技能聚焦审批流程和仓库栈一致性。

## 护栏

- 不要跳过审批门禁。
- 不要把重大 UI 请求直接跳转为正式实现。
- 不要让静态 Demo 成为永久影子实现。
- 保持 MVP 范围收敛；当范围扩张时先回推给用户确认。
