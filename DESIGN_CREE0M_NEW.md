# DESIGN_CREE0M_NEW

基于现有 `infoq-scaffold-frontend-vue` 后台前端项目与 `infoq-scaffold-frontend-weapp-vue` 小程序前端项目的实际页面、全局样式、主题配置和组件组织，对 `DESIGN_CREEM.md` 做一次项目化重整。

这份文档不再重复 creem.io 的站点观察，而是回答下面三个更实际的问题：

1. 现有 Vue admin 与 weapp Vue 已经具备了什么视觉基线
2. Creem 风格语言应该如何“翻译”到这两个项目，而不是生硬照搬
3. light / dark 两种风格在两个工作区里分别应该长成什么样

---

## 1. 文档目标

### 1.1 Functional scope

- 基于现有页面和样式结构，重整出一份面向两个前端工作区的视觉文档
- 输出 light / dark 两套风格规范
- 明确 admin 与 weapp 的共同基线、差异点与统一方向
- 保留对 CPU / GPU 渲染成本的约束

### 1.2 Non-goals

- 不直接修改前端代码
- 不提供逐页面 UI 实现稿
- 不要求将两个工作区改成完全相同的外观
- 不要求把 creem.io 的紫色 Neo-brutalism 逐像素照搬到后台表格页

### 1.3 Evidence base

以下结论直接基于仓库文件，不是抽象猜测：

#### Vue admin

- `infoq-scaffold-frontend-vue/src/main.ts`
- `infoq-scaffold-frontend-vue/src/settings.ts`
- `infoq-scaffold-frontend-vue/src/assets/styles/index.scss`
- `infoq-scaffold-frontend-vue/src/assets/styles/variables.module.scss`
- `infoq-scaffold-frontend-vue/src/assets/styles/sidebar.scss`
- `infoq-scaffold-frontend-vue/src/layout/index.vue`
- `infoq-scaffold-frontend-vue/src/layout/components/Navbar.vue`
- `infoq-scaffold-frontend-vue/src/layout/components/Settings/index.vue`
- `infoq-scaffold-frontend-vue/src/views/login.vue`
- `infoq-scaffold-frontend-vue/src/views/index.vue`
- `infoq-scaffold-frontend-vue/src/views/system/user/index.vue`
- `infoq-scaffold-frontend-vue/src/views/monitor/server/index.vue`

#### weapp Vue

- `infoq-scaffold-frontend-weapp-vue/src/manifest.json`
- `infoq-scaffold-frontend-weapp-vue/src/theme.json`
- `infoq-scaffold-frontend-weapp-vue/src/utils/theme.ts`
- `infoq-scaffold-frontend-weapp-vue/src/styles/common.scss`
- `infoq-scaffold-frontend-weapp-vue/src/styles/list.scss`
- `infoq-scaffold-frontend-weapp-vue/src/components/BottomNav.vue`
- `infoq-scaffold-frontend-weapp-vue/src/components/RecordCard.vue`
- `infoq-scaffold-frontend-weapp-vue/src/pages/login/index.vue`
- `infoq-scaffold-frontend-weapp-vue/src/pages/home/index.vue`
- `infoq-scaffold-frontend-weapp-vue/src/pages/admin/index.vue`
- `infoq-scaffold-frontend-weapp-vue/src/pages/profile/index.vue`
- `infoq-scaffold-frontend-weapp-vue/src/pages/system-users/index.vue`
- `infoq-scaffold-frontend-weapp-vue/src/pages/notice-form/index.vue`

---

## 2. 现状诊断

## 2.1 Vue admin 当前视觉状态

Vue admin 当前不是单一设计风格，而是三套视觉语言并存：

1. 经典后台管理骨架
2. 新版登录页
3. 新版首页 demo 风格

### 2.1.1 已有主题能力

从 `src/main.ts`、`src/layout/components/Settings/index.vue`、`src/assets/styles/variables.module.scss` 可以确认：

- 已接入 `element-plus/theme-chalk/dark/css-vars.css`
- 已使用 `html.dark` 作为暗色模式切换基线
- 已支持 `theme-dark` / `theme-light` 的侧边栏主题切换
- 已支持动态主色 `theme`
- 现有主题系统本质是：
  - Element Plus CSS vars
  - 自定义 sidebar vars
  - 页面局部自定义变量

这意味着：

- Vue admin 的 dark 不是空白能力，已经具备可扩展基础
- 如果要引入 Creem-inspired 风格，应该建立在现有 vars 系统上，而不是另造一套主题开关

### 2.1.2 页面视觉特征

#### 登录页

`src/views/login.vue` 已经明显不是传统后台登录页：

- 大背景图
- 浮层登录卡片
- dark 下有独立卡片变量
- 输入框、卡片、投影都偏现代 SaaS

但它仍然是克制的：

- 圆角不大
- 没有夸张装饰
- 动效非常少

#### 首页

`src/views/index.vue` 是当前最接近“品牌化首页”的页面：

- hero 卡片
- editorial 式标题与说明
- blur 装饰层
- feature cards
- light / dark 双态处理

但它与 Creem 仍有本质区别：

- 仍使用蓝色为 primary
- 组件轮廓依旧遵循 Element Plus 语义
- 没有粗描边、硬位移阴影、贴纸式点缀

#### 业务页

以 `src/views/system/user/index.vue`、`src/views/monitor/server/index.vue` 为代表：

- 大量 `el-card + el-form + el-table`
- 搜索面板、树筛选、数据表格、分页、操作按钮是主工作流
- 页面信息密度高
- 交互优先级是可扫视、可录入、可批量操作，而不是情绪化品牌表达

结论：

> Vue admin 适合引入“克制版 Creem”，不能把整个后台都做成营销站。

更具体地说：

- 登录页、首页、空状态、信息提示、功能入口卡片，可以承接更多品牌感
- 列表页、表单页、监控页，应保留后台操作型界面本质

---

## 2.2 weapp Vue 当前视觉状态

weapp Vue 的视觉风格明显比 admin 更新，整体更统一。

### 2.2.1 已有主题能力

从 `manifest.json`、`theme.json`、`utils/theme.ts` 可以确认：

- H5 和微信小程序都声明了 `darkmode: true`
- 已配置 `themeLocation: "theme.json"`
- 已有系统主题监听工具：
  - `getSystemThemeMode`
  - `subscribeSystemThemeMode`

但从页面与样式文件继续观察，会发现一个关键事实：

- 页面级 SCSS 仍主要按 light 写死
- `common.scss` 和 `list.scss` 主要使用 Sass 变量，不是运行时 CSS 变量
- 暗色能力目前更多停留在壳层：
  - 导航栏背景
  - 系统背景文本风格
  - 主题订阅工具已准备好

因此当前 weapp 的 dark 状态可以概括为：

> 壳层支持已经具备，页面组件级 dark 体系还没有真正落地。

### 2.2.2 页面视觉特征

#### 登录页

`src/pages/login/index.vue` + `index.scss`：

- 白底 + 蓝色径向渐变背景
- 大号品牌块与大标题
- 强按钮、高圆角
- 入场动画 `fadeInDown / fadeInUp / fadeIn`

这已经比 admin 的业务页更接近“品牌化入口页”。

#### 首页

`src/pages/home/index.vue` + `index.scss`：

- 顶部欢迎区
- 数据 swiper
- 公告条
- 快捷入口网格
- 底部固定导航

整体是现代移动管理端常见的“轻仪表盘”。

#### 管理台 / 个人中心

`src/pages/admin/index.vue`、`src/pages/profile/index.vue`：

- 管理台有渐变 banner
- 个人中心有强视觉头像区和 tag cloud
- 使用大量卡片、胶囊、圆角、半透明操作 chip

这些页面比 Vue admin 更适合吸收 Creem 的活泼表达。

#### 列表与表单页

`src/pages/system-users/index.vue`、`src/pages/notices/index.vue`、`src/pages/notice-form/index.vue`：

- 列表页是 sticky search + record card + FAB + bottom nav
- 表单页是大卡片 + 固定底部操作条
- `common.scss` / `list.scss` 形成了稳定的移动端设计底座

结论：

> weapp Vue 已经具备 Creem 风格转译的天然容器，但它需要先把 light-only 的 Sass 体系改成可切换 light/dark 的 token 体系。

---

## 2.3 两个工作区的共同点与差异

### 共同点

- 主功能色都以蓝色为核心
  - Vue admin 默认主色：`#409EFF`
  - weapp Vue 主色：`#1677ff`
- 都以卡片、面板、分组区块作为主要信息容器
- 都已经有 dark 相关基础设施
- 都更偏“管理工具”，不是纯营销站

### 差异点

#### Vue admin

- 重表格、重筛选、重批量操作
- Element Plus 是主要视觉约束
- dark 模式基础成熟
- 视觉密度高

#### weapp Vue

- 重卡片、重入口、重路径切换
- 固定底部导航、sticky 搜索、FAB 已成习惯
- 暗色能力还没真正进入页面组件层
- 视觉表达更适合品牌化扩展

---

## 3. Creem 风格对本项目的正确翻译方式

这一步最关键。

如果直接把 Creem 的紫底、粗描边、硬阴影、吉祥物、巨型标题无差别塞进两个项目，会有两个问题：

1. Vue admin 的密集表格页会被破坏可读性
2. weapp Vue 的现有蓝色语义体系会被无意义推翻

所以更合理的翻译原则是：

### 3.1 保留什么

- 更强的品牌识别区块
- 更有情绪的 hero / banner / 入口卡片
- 更明确的色彩层级
- 更轻快的视觉点缀
- 更统一的 light / dark 语义

### 3.2 不保留什么

- 通篇大面积紫底
- 全后台粗描边和硬位移阴影
- 对数据表、树、表单字段的大幅造型化
- 过多装饰动画

### 3.3 最终翻译策略

对于本仓库，Creem 风格不应成为“主业务 UI 基线”，而应成为：

- 品牌层
- 首页层
- 登录层
- 入口层
- 空状态 / 提示层

而操作层仍应保持：

- 清晰
- 稳定
- 高密度可扫视
- 低认知负担

一句话归纳：

> 在这个仓库里，Creem 是“品牌调味层”，不是“所有页面的结构母版”。

---

## 4. 新的统一风格结论

## 4.1 主功能色不改成 Creem 紫

基于现有代码，推荐保留蓝色为系统 primary：

- Vue admin：继续围绕 `theme` / `--el-color-primary`
- weapp Vue：继续围绕 `$primary-color: #1677ff`

原因很直接：

- 两个工作区都已经基于蓝色建立了状态与操作习惯
- admin 的按钮、标签、开关、focus ring、链接态都已围绕蓝色组织
- weapp 的按钮、FAB、icon、notice 条、nav active 态都已围绕蓝色组织

所以 Creem 的紫、桃、绿应该降级为：

- 品牌辅助色
- 首页装饰色
- 模块型强调色
- 标签与情绪点缀色

而不是替代 primary。

## 4.2 推荐的综合色彩角色

### 共享角色

- `System Primary`：蓝色，负责操作语义
- `Editorial Accent`：Creem Lilac，负责品牌感与 hero 点缀
- `Warm Accent`：Peach，负责 CTA、欢迎态、亮点卡
- `Success Accent`：Green，负责正向状态与监控/启用态
- `Ink`：高对比文本与深色轮廓

### 推荐色值

```css
:root {
  --brand-primary: #1677ff;
  --brand-primary-admin: #409eff;
  --brand-lilac: #b09cfb;
  --brand-peach: #ffbe98;
  --brand-green: #4ecb71;
  --brand-ink: #151617;
  --brand-paper: #ffffff;
  --brand-paper-warm: #f5f2f0;
}
```

---

## 5. Light 风格文档

## 5.1 Light 总体气质

light 模式下的目标不是“传统后台白底”，而是：

- 信息密度仍高
- 视觉观感更柔和、更现代
- 品牌层具备更强辨识度
- 操作层维持工具属性

### Light 关键词

- clean
- editorial
- soft-structured
- blue-primary
- lilac-accented

---

## 5.2 Light 共享设计令牌

```css
:root[data-theme='light'] {
  --bg-page: #f5f7f9;
  --bg-surface: #ffffff;
  --bg-surface-soft: #f8fafc;
  --bg-surface-warm: #f5f2f0;

  --text-strong: #1f2937;
  --text-default: #334155;
  --text-muted: #64748b;
  --text-subtle: #94a3b8;

  --line-soft: rgba(15, 23, 42, 0.08);
  --line-strong: rgba(15, 23, 42, 0.14);

  --primary: #1677ff;
  --primary-admin: #409eff;
  --accent-lilac: #b09cfb;
  --accent-peach: #ffbe98;
  --accent-green: #4ecb71;

  --radius-sm: 8px;
  --radius-md: 12px;
  --radius-lg: 16px;
  --radius-xl: 24px;

  --shadow-card: 0 8px 24px rgba(15, 23, 42, 0.06);
  --shadow-card-hover: 0 16px 40px rgba(15, 23, 42, 0.08);
  --shadow-soft-top: 0 -4px 20px rgba(15, 23, 42, 0.04);
}
```

---

## 5.3 Vue admin 的 Light 风格

### 5.3.1 适用范围

主要应用于：

- 登录页
- 首页
- 空状态
- 概览卡片
- 系统消息与提示层

不建议强行应用于：

- 树 + 表格页
- 大型监控表格页
- 高密度 CRUD 表单页的字段本体

### 5.3.2 Light 视觉规则

#### 登录页

基于现有 `views/login.vue`：

- 保留背景图 + 浮层登录卡
- 卡片可引入更明确的 lilac / peach 局部点缀
- 不引入粗描边
- 输入框保持 Element Plus 语义，不做 Creem 风格硬卡片输入框

建议：

- 标题和辅助文案更具品牌感
- 按钮可在 hover / focus 态引入 lilac glow 或 peach accent

#### 首页

基于现有 `views/index.vue`：

- 这是 admin 最适合承接 Creem 风格的页面
- 可保留 hero card
- 用 `accent-lilac` 取代当前纯蓝 blur 装饰
- feature cards 保持圆角卡片，不做硬边位移阴影

建议：

- hero 左上角 eyebrow 可用 lilac 或 peach
- 主 CTA 用 primary blue
- 次 CTA 用 warm neutral 或深色按钮
- 数据型模块卡片用白底，不要整块紫底压住信息

#### 列表页 / 表格页

基于 `views/system/user/index.vue`、`views/monitor/server/index.vue`：

- 仍然以 `el-card + el-table + toolbar` 为核心
- 只在以下部位增加新风格：
  - 搜索区标题 / 分组层级
  - 顶部操作区按钮层级
  - 空状态
  - 统计徽标

不建议：

- 所有表格卡片加大投影
- 所有按钮都用 brand accent
- 把树筛选和表单控件改成营销站样式

### 5.3.3 Vue admin Light 推荐细节

- 卡片圆角：`12px`
- 主工作区卡片阴影：轻阴影即可
- Navbar：白底或极浅暖白，底部微阴影
- Sidebar：
  - 保持 `theme-dark` / `theme-light` 双侧栏逻辑
  - `theme-light` 下可加入更轻的温润背景，而不是纯白生硬贴边
- 表格页：
  - header 背景延续当前 `--tableHeaderBg`
  - 只增强层次，不增加花哨装饰

---

## 5.4 weapp Vue 的 Light 风格

### 5.4.1 适用范围

weapp 的大多数页面都适合使用更完整的 Creem-inspired 轻品牌化视觉。

尤其适合：

- 登录页
- 首页
- 管理入口页
- 个人中心
- 列表卡片
- FAB 与底部导航

### 5.4.2 Light 视觉规则

#### 登录页

基于 `pages/login/index.scss`：

- 已有较强品牌感
- 可引入 lilac 作为第二层渐变或氛围色
- 主按钮仍保持蓝色
- `logo-box`、背景径向光斑、辅助文案可接入 Creem 的轻活泼感

建议：

- 不要把登录页全部改成紫底
- 只在 radial gradient 和品牌块中引入 lilac / peach

#### 首页

基于 `pages/home/index.vue`：

- `welcome-section`、`stats-swiper`、`notice-bar`、`quick-grid` 很适合做品牌升级
- swiper 卡片可以允许轻微 editorial accent
- 快捷入口图标容器可区分：
  - primary blue
  - lilac accent
  - green status

#### 管理台

基于 `pages/admin/index.vue`：

- banner 可升级为蓝紫混合渐变
- system 与 monitor 两个分组可用不同 accent
- 仍保持模块网格的清晰点击结构

#### 个人中心

基于 `pages/profile/index.vue`：

- 这是最适合承接 Creem 情绪表达的页面
- 可保留 gradient banner
- 可强化 tag cloud、头像背景、action chip 的 lilac / peach 层次
- 但信息区仍保持高可读白卡片

#### 列表与表单

基于 `system-users/index.vue`、`notice-form/index.vue`：

- 卡片列表可以保留现代圆角 + 状态色条
- sticky 搜索卡和 fixed action bar 已足够现代
- 不建议改成粗黑边、硬位移阴影

### 5.4.3 weapp Light 推荐细节

- 全局页背景：`#f5f7f9`
- 主卡片：白底 + 轻阴影
- banner：蓝主色 + lilac 次色
- 底部导航：白色半透明浮层
- FAB：保留蓝色主操作语义
- 卡片 action：以 blue / red / neutral 为主，不用 peach 取代危险语义

---

## 6. Dark 风格文档

## 6.1 Dark 总体气质

dark 模式下的目标不是简单反相，而是：

- 操作层更稳
- 品牌层仍有活力
- 数据密度页不刺眼
- 移动端在暗环境下更聚焦

### Dark 关键词

- deep
- controlled
- contrast-aware
- blue-primary
- lilac-glow

---

## 6.2 Dark 共享设计令牌

```css
:root[data-theme='dark'] {
  --bg-page: #0b1220;
  --bg-surface: #111827;
  --bg-surface-soft: #172033;
  --bg-surface-elevated: #1b2437;

  --text-strong: #f8fafc;
  --text-default: #dbe4f0;
  --text-muted: #94a3b8;
  --text-subtle: #64748b;

  --line-soft: rgba(255, 255, 255, 0.08);
  --line-strong: rgba(255, 255, 255, 0.14);

  --primary: #5aa2ff;
  --primary-admin: #5aa2ff;
  --accent-lilac: #b9a7ff;
  --accent-peach: #ffc6a3;
  --accent-green: #67d68e;

  --shadow-card: 0 16px 40px rgba(0, 0, 0, 0.35);
  --shadow-card-hover: 0 20px 50px rgba(0, 0, 0, 0.45);
}
```

---

## 6.3 Vue admin 的 Dark 风格

### 6.3.1 基础判断

Vue admin 当前 dark 已经能工作，所以 dark 文档应该是“扩展现有能力”，不是“推翻现有能力”。

### 6.3.2 Dark 视觉规则

#### 主题层

沿用当前体系：

- `html.dark`
- Element Plus dark css vars
- `settingsStore.dark`
- `sideTheme`

建议增强点：

- 在 `variables.module.scss` 中新增 editorial accent vars
- 保持 sidebar dark 为高对比导航区
- 主工作区 dark 采用深蓝黑，而不是纯黑

#### 登录页

现有 `views/login.vue` dark 已有：

- 半透明深卡
- 边框透明白
- blur 玻璃感

建议：

- 登录页 dark 可加入低强度 lilac ambient glow
- 不要使用亮紫大面积背景
- 保留输入框对比度与聚焦边框

#### 首页

现有首页已做 `html.dark .hero-card`

建议：

- hero 背景由纯深灰升级为深蓝黑 + lilac glow
- 右上 blur 装饰可用 `rgba(176, 156, 251, 0.12)` 一类值
- feature cards 和 chart 区仍保持深卡片，不要品牌化过度

#### 业务页

业务页 dark 原则：

- 表格仍然是第一优先
- 侧边栏和主内容区对比要明显
- 筛选区和内容区层级通过深浅面区分，不通过高彩背景区分

不建议：

- 在表格页中加入大量彩色大色块
- 在每个 `el-card` 上追加 glow 或 blur

### 6.3.3 Vue admin Dark 推荐实现点

- 继续以 `--el-color-primary` 驱动交互色
- 新增：
  - `--editorial-accent-lilac`
  - `--editorial-accent-peach`
  - `--editorial-accent-green`
- 仅首页、登录页、空状态、公告入口等使用 accent

---

## 6.4 weapp Vue 的 Dark 风格

### 6.4.1 当前问题

weapp 当前虽然 `manifest.json` 与 `theme.json` 已声明 darkmode，但页面 SCSS 仍以 light hardcode 为主。

因此 dark 方案的关键不是“选什么颜色”，而是先解决：

- 运行时主题如何进入页面
- Sass compile-time 颜色如何迁移到 runtime token

### 6.4.2 Dark 视觉规则

#### 页面壳层

建议：

- 保留 `theme.json` 对导航栏的 light/dark 配置
- 页面根容器统一挂 `theme-light` / `theme-dark`
- 通过 `getSystemThemeMode` + `subscribeSystemThemeMode` 驱动页面主题态

#### 主题实现方向

不要继续只用 Sass 固定变量。

推荐迁移为：

```css
page,
.theme-light {
  --app-bg: #f5f7f9;
  --app-surface: #ffffff;
  --app-text: #1f2937;
  --app-muted: #64748b;
  --app-primary: #1677ff;
  --app-lilac: #b09cfb;
  --app-peach: #ffbe98;
  --app-green: #4ecb71;
}

.theme-dark {
  --app-bg: #0b1220;
  --app-surface: #111827;
  --app-text: #f8fafc;
  --app-muted: #94a3b8;
  --app-primary: #5aa2ff;
  --app-lilac: #b9a7ff;
  --app-peach: #ffc6a3;
  --app-green: #67d68e;
}
```

然后逐步替换：

- `common.scss`
- `list.scss`
- `pages/*/index.scss`

#### 登录页

dark 登录页建议：

- 深蓝黑背景
- 保留 radial glow
- 主按钮保持蓝色
- lilac 作为背景氛围色，不抢 primary

#### 首页 / 管理台 / 个人中心

这些页面适合更完整的 dark 品牌化：

- banner / hero 用深色渐变
- 强调卡用浅亮文字
- tag / chip / notice / accent line 保留品牌点缀色

#### 列表 / 表单页

dark 下重点是可读性：

- sticky search card 深色化
- record card 深卡 + 细浅边
- FAB 继续蓝色，不改成 lilac
- fixed action section 背景深色半透明，但 blur 要受控

---

## 7. 平台化组件映射

## 7.1 Vue admin 组件映射

### 适合使用“Creem translated”风格的组件

- 登录卡片
- 首页 hero
- feature card
- 消息提示卡
- 空状态
- 快捷入口按钮

### 应该保持“工具化”的组件

- `el-table`
- `el-form`
- `el-tree`
- `el-pagination`
- 监控数据表

### 管理端视觉基线

- 用品牌层包装操作层
- 不让品牌层吞掉操作效率

---

## 7.2 weapp Vue 组件映射

### 适合增强品牌表达的组件

- `BottomNav`
- `FabButton`
- 首页 `stats-card`
- `notice-bar`
- `admin-banner`
- `profile-banner`
- `tag-cloud`
- `RecordCard` header 区

### 应该保持稳定语义的组件

- 搜索表单项
- 固定操作条
- 输入框 / 文本域
- 状态标签
- 删除 / 危险操作按钮

### 小程序视觉基线

- 品牌感可以更强
- 但核心动作仍以清晰可点、可扫视为第一优先

---

## 8. 性能与渲染约束

## 8.1 Vue admin

Vue admin 的主要压力不是 hero，而是：

- 表格
- 树
- 筛选项
- 固定头部
- 页面切换

因此建议：

- 不在数据页大量增加 blur
- 不在 `el-card` hover 上叠加重型阴影动画
- 不对 sidebar、table、toolbar 做高频 transform 动效
- 主题切换继续依赖 CSS vars，而不是重复渲染页面

### Vue admin CPU 约束

- 表格页不要增加无语义包装层
- 搜索区、树筛选区、卡片头部不做复杂动画
- 仅首页和登录页允许额外装饰层

### Vue admin GPU 约束

- `backdrop-filter` 只用于登录卡或极少数浮层
- `filter: blur(...)` 只允许首页局部装饰
- hover 动效优先 `opacity / transform`

---

## 8.2 weapp Vue

weapp 当前页面里已经有几个固定视觉效果：

- 底部导航 blur
- sticky 搜索 blur
- profile modal blur
- 渐变 banner
- FAB 阴影

这意味着小程序端更需要节制层叠效果。

### weapp CPU 约束

- 列表页不要叠太多卡片内嵌结构
- 搜索区保持单层 sticky 容器
- 表单页固定操作条结构尽量稳定
- dark 切换优先变量切换，不重建页面

### weapp GPU 约束

- 同一屏内尽量只保留一个强 blur 主体
- `BottomNav` 与 `search-section` 同屏时，不要再加大面积浮层 glow
- FAB 保持静态渐变，不做持续漂浮动画
- 大渐变背景不要做无限动画

### 小程序暗色特别约束

- `backdrop-filter` 在低端机和小程序运行时更敏感
- dark 下优先纯深色面 + 轻描边
- blur 作为点缀，不作为层级唯一手段

---

## 9. 推荐的统一实施优先级

如果后续要真正实现，建议按下面顺序推进，而不是全量重做。

### Phase 1

- 先统一 token 语言
- admin：
  - 扩展 `variables.module.scss`
  - 首页 / 登录页先接入
- weapp：
  - 将 `common.scss` / `list.scss` 从 Sass 固定色迁移到可切换 token

### Phase 2

- 完成 light / dark 页面壳层
- admin：
  - 首页、登录页、空状态
- weapp：
  - 登录页、首页、管理台、个人中心

### Phase 3

- 逐步进入列表页 / 表单页
- 仅增强层次，不重做交互语义

---

## 10. 最终结论

这两个项目虽然都属于 Vue 家族，但视觉落点不同：

- `infoq-scaffold-frontend-vue` 应该是“后台工具优先，品牌表达克制注入”
- `infoq-scaffold-frontend-weapp-vue` 应该是“移动卡片优先，品牌表达适度放大”

因此新的 light / dark 视觉文档应遵循下面的最终原则：

1. 主功能色继续保留蓝色，不改成 Creem 紫
2. Creem 的紫 / 桃 / 绿作为 editorial accent，而不是系统 primary
3. admin 把品牌感集中在登录、首页、提示层，不侵入高密度 CRUD 页
4. weapp 用更完整的卡片与 banner 体系承接品牌感，但仍以可读性为先
5. dark 模式里：
   - admin 依托现有 Element Plus dark vars 扩展
   - weapp 先把 light-only Sass 体系迁移成 runtime token
6. 性能上：
   - admin 避免对表格和树做重装饰
   - weapp 避免多层 blur 和大面积持续动画

一句话总结：

> `DESIGN_CREEM.md` 适合描述 Creem 风格本身；而本文件更适合指导这两个现有项目如何“有节制地吸收 Creem 的品牌语言”，并最终形成可落地的 light / dark 双风格体系。
