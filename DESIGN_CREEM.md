# DESIGN_CREEM

基于 `chrome-devtools-mcp` 对 `https://www.creem.io/` 的运行时观察整理。

- 采样时间：2026-05-06
- 采样方式：`chrome-devtools-mcp` 页面快照、运行时 `evaluate_script`、截图、性能 trace
- 结论边界：本文档包含两部分内容
  - 站点当前已观察到的真实风格、CSS 倾向、动画特征
  - 适配到本项目时可执行的 light / dark 设计规范
- 特别说明：运行时切换 `prefers-color-scheme: dark` 后，首页首屏未出现显著视觉变化；样式表中也未观察到 `prefers-color-scheme` 规则。因此本文的 dark 方案是基于当前风格语言推导出的实现规范，不应误解为 creem.io 的原生暗色实现

## 1. 风格结论

Creem 的首页不是常规 SaaS 的冷静极简，而是明显的 `neo-brutalism + playful mascot + product-demo storytelling` 组合：

- 主色不是深蓝或灰，而是高饱和浅紫底色 `#B09CFB`
- 大标题使用夸张的展示字体，字面积极大，几乎占满首屏视觉中心
- 组件边框普遍是高对比粗描边，配合硬边投影，不走柔和玻璃卡片路线
- 交互件圆角统一，但不是软糯圆角，更接近“圆角硬卡片”
- 视觉气质靠吉祥物、波浪分割、大面积留白、贴纸式点缀维持轻松感
- 产品表达不是纯文案，而是大量“伪界面卡片”“功能演示片段”“对账单/控制台/AI 助手/支付卡片”堆叠

如果要在本项目复用这种语言，重点不在“照搬紫色”，而在下面五个原则：

1. 高对比轮廓
2. 大字面标题
3. 偏卡通的功能演示组件
4. 固定色块 + 点状强调色
5. 轻量动效，强静态造型

## 2. 运行时观察摘要

### 2.1 页面与结构

- 页面高度约 `17143px`
- 运行时可见元素数量约 `1827`
- 性能 insight 统计的总 DOM 元素为 `2168`
- DOM 深度为 `21`
- `body` 子节点最多，达到 `29`

这说明它虽然看起来很“插画化”，但实际并不是一个轻 DOM 页面。大量营销分段、演示卡片、图形装饰和徽章堆叠，已经把布局复杂度推高。

### 2.2 实测字体

- 标题展示字体：`Gasoek One`
- 正文字体：`Geist Sans`
- 代码区字体：系统 monospace

观察到的典型标题参数：

- Hero H1：`124.8px / 112.32px / -2.496px / uppercase`
- 主章节 H2：`60px / 60px`
- 次级章节 H3：`48px / 48px`
- 小卡片标题：`14px / 20px / 700`

这套比例非常激进。真正撑起品牌感的是展示字体，不是渐变，不是复杂动画。

### 2.3 实测颜色

运行时高频颜色如下：

- 浅紫主底：`#B09CFB` `rgb(176, 156, 251)`
- 墨黑主文字 / 描边：`#151617` `rgb(21, 22, 23)`
- 深色按钮底：`#1A1B1D` `rgb(26, 27, 29)`
- 奶白 / 暖白底：`#FFFFFF`、`#F5F2F0`、`#FAFAF9`
- 桃色强调：`#FFBE98` `rgb(255, 190, 152)`
- 绿色强调：`#4ECB71` `rgb(78, 203, 113)`

从运行时变量中还能观察到：

- `--primarypurple: #b09cfb`
- `--card: 220 6% 10%`
- `--border: 220 6% 20%`

### 2.4 实测圆角、边框、阴影

高频圆角：

- `12px`
- `16px`
- `9999px`

按钮和卡片常见边框：

- `2px solid #151617`
- 少量 `3px solid #151617`

高频投影不是柔和扩散阴影，而是偏“硬边位移阴影”：

- `2px 2px 0 0 #151617`
- `3px 3px 0 0 #151617`
- `4px 4px 0 0 #151617`
- `6px 6px 0 0 #151617`

这类阴影的特征是：

- 视觉性格强
- 对 hover 的反馈很直接
- 静态成本低于复杂大面积模糊阴影
- 一旦参与动画，重绘成本会上升，所以更适合静态存在

## 3. CSS 语言归纳

### 3.1 组件造型

Creem 的组件不是玻璃风，不是极简扁平，也不是苹果式半透明卡片。它更接近下面这组规则：

- 外轮廓明确，通常有描边
- 大多数点击件都有实体感偏移阴影
- CTA 使用白 / 黑 / 桃 / 绿等少数高识别色
- 信息标签使用 `pill` 或短卡片
- 导航条采用固定悬浮容器，白底半透明加 blur

观察到的典型按钮样式：

- `Log in`：奶白底、黑边、`2px 2px` 硬影
- `Get started`：桃色底、黑边、`3px 3px` 硬影
- `GET STARTED`：白底、黑边、`6px 6px` 硬影、`16px` 圆角
- `BOOK DEMO`：黑底、白字、黑边、`6px 6px` 硬影

### 3.2 布局组织

视觉上可以概括为三层：

1. 巨型品牌首屏
2. 演示型内容带
3. 深色收束型底部

具体表现：

- 首屏是大面积紫底 + 固定导航 + 巨型 H1 + 吉祥物半露出
- 中段通过浅色块 / 深色块 / 演示卡片不断切换节奏
- 使用波浪、锯齿、圆润边缘做 section 分隔，不完全依赖直线栅格
- 很多“功能说明”不是段落文本，而是直接用假 UI 模块说话

### 3.3 真实 CSS 资源

运行时样式表观察到：

- `/_next/static/css/7b63aafbcdf619c7.css`，约 `3280` 条规则
- `/_next/static/css/8f6bd77097d81239.css`，约 `99` 条规则

说明它不是一个完全靠少量 handcrafted CSS 维持的 landing page，而是明显混合了实用类体系，风格表达是建立在组件组合之上的。

### 3.4 关键 CSS 特征

样式表和运行时同时能确认的特征：

- 使用大量 `transform` 相关类
- 存在 `transform-gpu`
- 存在 `backdrop-filter`
- 存在 `filter: grayscale(...)`
- 存在少量 `drop-shadow(...)`
- 交互动效时间常见为 `150ms / 200ms / 300ms`
- easing 常见为 `cubic-bezier(0.4, 0, 0.2, 1)`

可以用下面的规范理解它：

```css
:root {
  --creem-ink: #151617;
  --creem-paper: #ffffff;
  --creem-paper-warm: #f5f2f0;
  --creem-lilac: #b09cfb;
  --creem-peach: #ffbe98;
  --creem-green: #4ecb71;

  --radius-sm: 12px;
  --radius-md: 16px;
  --radius-pill: 9999px;

  --shadow-brutal-2: 2px 2px 0 0 var(--creem-ink);
  --shadow-brutal-3: 3px 3px 0 0 var(--creem-ink);
  --shadow-brutal-4: 4px 4px 0 0 var(--creem-ink);
  --shadow-brutal-6: 6px 6px 0 0 var(--creem-ink);

  --border-strong: 2px solid var(--creem-ink);
  --motion-fast: 150ms;
  --motion-base: 200ms;
  --motion-slow: 300ms;
  --ease-standard: cubic-bezier(0.4, 0, 0.2, 1);
}
```

## 4. 动画与交互效果

### 4.1 运行时实际观察到的动效

首屏运行时实际处于 active 状态的动画名称只有：

- `pulse`

说明页面并不是持续用大面积复杂动效推视觉，而是以静态造型为主，只在局部状态点上使用无限动画。

运行时观察到的动效 / 过渡类型包括：

- 导航容器背景色过渡：`0.5s`
- 按钮、卡片 hover：`0.2s` 左右
- Logo / 图标 / 客户 logo：`0.3s`
- 箭头图标：`transform 0.15s`
- 装饰物使用 `translate / rotate / skew`
- 导航容器使用 `backdrop-filter: blur(24px)`
- 一些 badge 使用 `backdrop-filter: blur(4px)`
- 客户 logo 使用 `filter: grayscale(1)`
- 个别小贴纸使用 `filter: drop-shadow(...)`

### 4.2 样式表中定义到的关键帧

样式表中存在这些 keyframes：

- `fade-in`
- `marquee`
- `ping`
- `pulse`
- `scroll`
- `spin`
- `spotlight`
- `enter`
- `exit`
- `logo-marquee`
- `moveUp`
- `moveDown`
- `fadeIn`
- `aurora`
- `accordion-up`
- `accordion-down`

这说明 Creem 的动效体系具备几类能力：

- 首屏进入
- 徽章脉冲
- 循环滚动 / marquee
- spotlight / aurora 类装饰
- 抽屉 / 折叠开合

但要注意：`样式表定义存在` 不等于 `当前首屏就大量同时执行`。实际首屏观察到的活跃动画很克制。

### 4.3 推荐复制方式

如果要在本项目复用这种风格，建议只保留三类动效：

1. 小状态点 `pulse`
2. CTA / chip / icon 的 `transform + opacity` hover
3. section 首次进入的轻量 `fade-in`

推荐动效 token：

```css
:root {
  --motion-fast: 150ms;
  --motion-base: 200ms;
  --motion-slow: 300ms;
  --motion-loop: 2000ms;
  --ease-standard: cubic-bezier(0.4, 0, 0.2, 1);
}

@keyframes creem-pulse {
  0%, 100% { transform: scale(1); opacity: 1; }
  50% { transform: scale(0.92); opacity: 0.7; }
}

@keyframes creem-fade-up {
  from { opacity: 0; transform: translateY(12px); }
  to { opacity: 1; transform: translateY(0); }
}
```

禁忌：

- 不要对大面积 box-shadow 做持续动画
- 不要让 `backdrop-filter` 参与频繁变化
- 不要做全页持续漂浮动画
- 不要在大图形上叠加多个 blur/filter 层

## 5. Light 风格规范

这是最接近 creem.io 当前实现的方案。

### 5.1 Light 颜色令牌

```css
:root[data-theme='light'] {
  --bg-page: #b09cfb;
  --bg-surface: #ffffff;
  --bg-surface-warm: #f5f2f0;
  --bg-contrast: #1a1b1d;

  --text-strong: #151617;
  --text-muted: rgba(21, 22, 23, 0.7);
  --text-on-dark: #ffffff;

  --accent-primary: #b09cfb;
  --accent-peach: #ffbe98;
  --accent-green: #4ecb71;

  --border-strong: #151617;
  --shadow-brutal: 4px 4px 0 0 #151617;
  --shadow-brutal-lg: 6px 6px 0 0 #151617;
}
```

### 5.2 Light 组件规则

- 顶部导航：
  - `rgba(255,255,255,0.95)` 浮层
  - `2px` 深色描边
  - `4px 4px 0 0 #151617` 静态偏移阴影
  - `backdrop-filter: blur(16px ~ 24px)`
- Hero：
  - 大标题使用展示字体
  - 三行或两行堆叠
  - 字重不用极粗，依赖字型本身造型
  - 可以允许轻度负字距
- 主按钮：
  - 白底 / 桃底 / 深底三套足够
  - `16px` 圆角
  - `2px` 描边
  - `6px` 偏移硬影
- 标签 / feature chip：
  - 白底
  - `12px` 圆角
  - `2px` 描边
  - `4px` 偏移影
  - 左侧配高识别色 icon badge
- 卡片：
  - 卡片本体优先纯色，不要渐变玻璃
  - 黑色或紫色 section 中允许白卡片突出信息层级

### 5.3 Light 文本体系

- Display：`Gasoek One` 或同类厚重展示字体
- Body：`Geist Sans` 或干净的无衬线
- 标题主层级：
  - H1：`112px ~ 128px`
  - H2：`56px ~ 64px`
  - H3：`40px ~ 48px`
- 正文：
  - 16px 为基准
  - 辅助文本 14px
  - pill / eyebrow 12px

## 6. Dark 风格规范

这是基于 creem 的造型语言为本项目推导的暗色版本。

目标不是把浅色直接反相，而是保留这些核心特征：

- 黑白强对比轮廓
- 紫 / 桃 / 绿的小面积强调
- 仍然有“贴纸感”和“实体感”
- 暗背景下依旧可读、可扫视

### 6.1 Dark 颜色令牌

```css
:root[data-theme='dark'] {
  --bg-page: #17161d;
  --bg-surface: #23212b;
  --bg-surface-soft: #2b2735;
  --bg-contrast: #f5f2f0;

  --text-strong: #fafaf9;
  --text-muted: rgba(250, 250, 249, 0.72);
  --text-on-light: #151617;

  --accent-primary: #b9a7ff;
  --accent-peach: #ffc6a3;
  --accent-green: #67d68e;

  --border-strong: #f5f2f0;
  --shadow-brutal: 4px 4px 0 0 rgba(0, 0, 0, 0.45);
  --shadow-brutal-lg: 6px 6px 0 0 rgba(0, 0, 0, 0.5);
}
```

### 6.2 Dark 组件规则

- 顶部导航：
  - `rgba(26,27,29,0.88)` 半透明深底
  - 浅色描边
  - `blur(16px)` 即可，不要为了“更酷”把 blur 拉太高
- Hero：
  - 保留紫色大背景或使用深紫黑背景
  - 主标题改为浅色文字
  - 吉祥物和装饰建议保留暖白面部和桃色局部高光
- 主按钮：
  - 深底亮边按钮
  - 桃色 / 绿色按钮只作为一级强调，不要满屏使用
- 卡片：
  - 深色卡面 + 浅色边框
  - 某些关键数据卡可反相为奶白卡，制造节奏

### 6.3 Dark 主题切换原则

- 只切换 CSS 变量，不复制 DOM
- 不要做双主题双套图片资源，优先通过背景、边框和文字体系切换
- mascot 若必须切图，控制在关键 Hero 和 1 个重点 section 内

## 7. 性能约束：CPU / GPU 视角

这是本文最重要的工程约束部分。

### 7.1 观察到的真实性能信号

使用 `chrome-devtools-mcp` trace 观察到：

- LCP：`1722ms`
- LCP 中 `TTFB` 约 `205ms`
- LCP 中 `render delay` 约 `1517ms`
- CLS：`0.00`
- DOM 总元素：`2168`
- 一次大布局更新：`194ms`
- 一次样式重算：`44ms`
- Forced reflow：`29ms`
- 第三方脚本体积压力：
  - Google Tag Manager：`737.1kB`
  - Facebook：`376.2kB`
- 第三方主线程执行：
  - GTM：`42ms`
  - Facebook：`37ms`

这组数据说明：

1. 页面视觉风格本身不是问题核心，`大 DOM + 第三方脚本 + 首屏渲染延迟` 才是主要压力源
2. Creem 其实已经相对克制地使用运行时动画；真正昂贵的是结构体量和营销型页面的内容复杂度
3. 如果在本项目里要复刻风格，必须克制 DOM、图片、第三方脚本，而不是只盯着动画

### 7.2 CPU 约束

建议把下面这些作为实现红线：

- 首屏 DOM 控制在 `700` 节点以内
- 单页初始 DOM 尽量控制在 `1200 ~ 1400` 以内
- DOM 深度尽量不超过 `12`
- 不要为了视觉分层把每张卡片套三到五层无语义容器
- 避免在滚动和 hover 期间读写布局属性混用
- 用 `requestAnimationFrame` 组织读写顺序
- 避免在滚动监听中频繁读 `offsetWidth / clientHeight / getBoundingClientRect()`
- 无限动画同时运行的元素不超过 `3` 个，并且只允许小面积元素

### 7.3 GPU 约束

建议保留 GPU 友好的动效方式：

- 优先动画属性：
  - `transform`
  - `opacity`
- 谨慎使用：
  - `filter`
  - `backdrop-filter`
  - `drop-shadow`
- 避免动画：
  - `box-shadow`
  - `border-width`
  - `width / height / top / left`
  - `border-radius` 的大面积连续变化

具体建议：

- `backdrop-filter` 只保留给 1 个固定导航容器
- 局部 badge 若用 `blur(4px)`，总数量不要多
- 大型吉祥物和波浪分割形状尽量静态，不要持续 floating
- `transform-gpu` 只给真实移动的元素，不能全页面滥加
- `will-change` 只在交互前后短暂挂载，不能常驻

### 7.4 图片与脚本约束

本次观察到：

- 资源总数约 `71`
- 其中 `40` 个 script
- `14` 个 image
- 最大单图约 `265KB`

建议本项目实现时：

- Hero 主视觉尽量使用 SVG 或压缩后的 WebP / AVIF
- 单张首屏图片预算控制在 `200KB` 内
- 客户 logo 默认静态灰阶图，不做复杂滤镜动画
- 第三方统计统一延迟到 consent 后或 `idle` 后加载
- 不把社媒追踪脚本放进关键渲染路径

### 7.5 CSS 体积与首屏策略

Creem 当前 render-blocking CSS 只有两份，且总量不算夸张。这一点是值得保留的。

建议：

- 主题 token 放在首屏关键 CSS
- 大段长页面的次级效果样式延后加载
- 复杂 section 的非首屏动画类按需拆分
- dark 模式通过根变量切换，不额外引入第二份全量样式表

## 8. 建议的实现骨架

如果本项目要落一个“Creem 风格但更克制”的实现，可以直接按下面的骨架做：

### 8.1 页面骨架

1. 固定导航
2. 紫底 Hero
3. 2 到 3 个功能演示 section
4. 1 个深色对比 section
5. 1 个 CTA 收束 section

不要一上来把整站都做成超长营销页。先把首屏和两个关键功能段落做好。

### 8.2 组件骨架

```css
.creem-nav {
  position: fixed;
  inset: 16px auto auto 50%;
  transform: translateX(-50%);
  border: 2px solid var(--border-strong);
  border-radius: 20px;
  box-shadow: var(--shadow-brutal);
  backdrop-filter: blur(18px);
}

.creem-card {
  border: 2px solid var(--border-strong);
  border-radius: 12px;
  background: var(--bg-surface);
  box-shadow: var(--shadow-brutal);
}

.creem-button {
  border: 2px solid var(--border-strong);
  border-radius: 16px;
  transition: transform var(--motion-fast) var(--ease-standard),
              opacity var(--motion-fast) var(--ease-standard),
              background-color var(--motion-base) var(--ease-standard);
}

.creem-button:hover {
  transform: translate(-2px, -2px);
}

.creem-pill {
  border: 2px solid var(--border-strong);
  border-radius: 9999px;
  box-shadow: var(--shadow-brutal-3);
}
```

### 8.3 动效骨架

```css
.creem-hover-lift {
  transition: transform 150ms cubic-bezier(0.4, 0, 0.2, 1);
}

.creem-hover-lift:hover {
  transform: translateY(-2px);
}

.creem-pulse-dot {
  animation: creem-pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite;
}

@media (prefers-reduced-motion: reduce) {
  .creem-hover-lift,
  .creem-pulse-dot {
    animation: none !important;
    transition: none !important;
  }
}
```

## 9. 最终落地建议

如果目标是“像 Creem”，真正该保留的是：

- 展示型大标题
- 紫 / 桃 / 绿这组三元强调色
- 硬边描边和偏移阴影
- 吉祥物或贴纸式点缀
- 产品演示卡片化叙事

真正该克制的是：

- DOM 数量
- 第三方脚本
- blur/filter 数量
- 长页面 section 数量
- 无限动画元素数量

一句话总结：

> Creem 的风格强在静态造型和品牌识别，不强在高频动画。实现时应优先复制造型逻辑，再用很少量、很克制的 GPU 友好动效补足气氛。
