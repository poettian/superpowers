# Visual Companion 指南

基于浏览器的视觉 brainstorming 伴侣，用于展示 mockups、diagrams 和 options。

## 何时使用

按每个问题决定，而不是按每个会话决定。测试标准：**用户看到它是否比阅读它更容易理解？**

**当内容本身是视觉的，使用浏览器：**

- **UI mockups** — wireframes、layouts、navigation structures、component designs
- **Architecture diagrams** — system components、data flow、relationship maps
- **Side-by-side visual comparisons** — 比较两个 layouts、两个 color schemes、两个 design directions
- **Design polish** — 当问题关于 look and feel、spacing、visual hierarchy
- **Spatial relationships** — state machines、flowcharts、entity relationships rendered as diagrams

**当内容是文本或表格时，使用终端：**

- **Requirements and scope questions** — “what does X mean?”、“which features are in scope?”
- **Conceptual A/B/C choices** — 在用文字描述的方法之间选择
- **Tradeoff lists** — pros/cons、comparison tables
- **Technical decisions** — API design、data modeling、architectural approach selection
- **Clarifying questions** — 任何答案是文字而不是视觉偏好的问题

关于 UI 主题的问题不自动等于视觉问题。“What kind of wizard do you want?” 是概念性的 — 使用终端。“Which of these wizard layouts feels right?” 是视觉的 — 使用浏览器。

## 它如何工作

服务器监听一个目录中的 HTML 文件，并将最新文件提供给浏览器。你将 HTML 内容写入 `screen_dir`，用户在浏览器中看到它，并可以点击选择选项。选择会记录到 `state_dir/events`，你在下一轮读取。

**内容片段 vs 完整文档：**如果你的 HTML 文件以 `<!DOCTYPE` 或 `<html` 开头，服务器会原样提供它（只注入 helper script）。否则，服务器会自动用 frame template 包裹你的内容 — 添加 header、CSS theme、selection indicator 和所有交互基础设施。**默认编写内容片段。**只有当你需要完全控制页面时，才编写完整文档。

## 开始会话

```bash
# Start server with persistence (mockups saved to project)
scripts/start-server.sh --project-dir /path/to/project

# Returns: {"type":"server-started","port":52341,"url":"http://localhost:52341",
#           "screen_dir":"/path/to/project/.superpowers/brainstorm/12345-1706000000/content",
#           "state_dir":"/path/to/project/.superpowers/brainstorm/12345-1706000000/state"}
```

从响应中保存 `screen_dir` 和 `state_dir`。告诉用户打开 URL。

**寻找连接信息：**服务器会将启动 JSON 写入 `$STATE_DIR/server-info`。如果你在后台启动服务器并没有捕捉 stdout，读取该文件以获取 URL 和 port。使用 `--project-dir` 时，检查 `<project>/.superpowers/brainstorm/` 中的 session 目录。

**注意：**将项目根目录作为 `--project-dir` 传入，这样 mockups 会持久化在 `.superpowers/brainstorm/` 中，并在服务器重启后保留。否则，文件会进入 `/tmp` 并被清理。如果 `.superpowers/` 还没有在 `.gitignore` 中，提醒用户添加它。

**按平台启动服务器：**

**Claude Code（macOS / Linux）：**
```bash
# Default mode works — the script backgrounds the server itself
scripts/start-server.sh --project-dir /path/to/project
```

**Claude Code（Windows）：**
```bash
# Windows auto-detects and uses foreground mode, which blocks the tool call.
# Use run_in_background: true on the Bash tool call so the server survives
# across conversation turns.
scripts/start-server.sh --project-dir /path/to/project
```
通过 Bash 工具调用时，设置 `run_in_background: true`。然后在下一轮读取 `$STATE_DIR/server-info` 获取 URL 和 port。

**Codex：**
```bash
# Codex reaps background processes. The script auto-detects CODEX_CI and
# switches to foreground mode. Run it normally — no extra flags needed.
scripts/start-server.sh --project-dir /path/to/project
```

**Gemini CLI：**
```bash
# Use --foreground and set is_background: true on your shell tool call
# so the process survives across turns
scripts/start-server.sh --project-dir /path/to/project --foreground
```

**其他环境：**服务器必须在对话轮次之间保持后台运行。如果你的环境会收割 detached processes，使用 `--foreground` 并用你平台的后台执行机制启动命令。

如果 URL 无法从浏览器访问（远程/容器化设置中常见），绑定非 loopback host：

```bash
scripts/start-server.sh \
  --project-dir /path/to/project \
  --host 0.0.0.0 \
  --url-host localhost
```

使用 `--url-host` 控制返回 URL JSON 中打印的 hostname。

## 循环

1. **检查服务器仍存活**，然后将 **HTML 写入** `screen_dir` 中的新文件：
   - 每次写入前，检查 `$STATE_DIR/server-info` 是否存在。如果不存在（或 `$STATE_DIR/server-stopped` 存在），服务器已关闭 — 继续前用 `start-server.sh` 重启。服务器会在 30 分钟无活动后自动退出。
   - 使用语义文件名：`platform.html`、`visual-style.html`、`layout.html`
   - **绝不要复用文件名** — 每个 screen 都使用新文件
   - 使用 Write 工具 — **绝不要使用 cat/heredoc**（会向终端倾倒噪音）
   - 服务器自动提供最新文件

2. **告诉用户会看到什么，并结束你的回合：**
   - 提醒他们 URL（每一步都提醒，不只是第一次）
   - 简要文字总结屏幕内容（例如，“Showing 3 layout options for the homepage”）
   - 请他们在终端回复：“Take a look and let me know what you think. Click to select an option if you'd like.”

3. **在你的下一轮** — 用户在终端回复后：
   - 如果 `$STATE_DIR/events` 存在，读取它 — 其中包含用户浏览器交互（clicks、selections）的 JSON lines
   - 与用户终端文本合并，获得完整图景
   - 终端消息是主要反馈；`state_dir/events` 提供结构化交互数据

4. **迭代或推进** — 如果反馈改变当前 screen，写新文件（例如 `layout-v2.html`）。只有当前步骤被验证后，才进入下一个问题。

5. **回到终端时卸载** — 当下一步不需要浏览器时（例如澄清问题、tradeoff discussion），推送 waiting screen 来清除过期内容：

   ```html
   <!-- filename: waiting.html (or waiting-2.html, etc.) -->
   <div style="display:flex;align-items:center;justify-content:center;min-height:60vh">
     <p class="subtitle">Continuing in terminal...</p>
   </div>
   ```

   这会防止用户在对话已经推进后仍盯着已解决的选择。当下一个视觉问题出现时，照常推送新的内容文件。

6. 重复直到完成。

## 编写内容片段

只写入页面内部的内容。服务器会自动用 frame template 包裹它（header、theme CSS、selection indicator 和所有交互基础设施）。

**最小示例：**

```html
<h2>Which layout works better?</h2>
<p class="subtitle">Consider readability and visual hierarchy</p>

<div class="options">
  <div class="option" data-choice="a" onclick="toggleSelect(this)">
    <div class="letter">A</div>
    <div class="content">
      <h3>Single Column</h3>
      <p>Clean, focused reading experience</p>
    </div>
  </div>
  <div class="option" data-choice="b" onclick="toggleSelect(this)">
    <div class="letter">B</div>
    <div class="content">
      <h3>Two Column</h3>
      <p>Sidebar navigation with main content</p>
    </div>
  </div>
</div>
```

就是这样。不需要 `<html>`，不需要 CSS，不需要 `<script>` tags。服务器会提供所有这些。

## 可用 CSS Classes

Frame template 为你的内容提供这些 CSS classes：

### Options（A/B/C choices）

```html
<div class="options">
  <div class="option" data-choice="a" onclick="toggleSelect(this)">
    <div class="letter">A</div>
    <div class="content">
      <h3>Title</h3>
      <p>Description</p>
    </div>
  </div>
</div>
```

**Multi-select：**向 container 添加 `data-multiselect`，让用户可以选择多个选项。每次点击都会切换该 item。Indicator bar 显示数量。

```html
<div class="options" data-multiselect>
  <!-- same option markup — users can select/deselect multiple -->
</div>
```

### Cards（visual designs）

```html
<div class="cards">
  <div class="card" data-choice="design1" onclick="toggleSelect(this)">
    <div class="card-image"><!-- mockup content --></div>
    <div class="card-body">
      <h3>Name</h3>
      <p>Description</p>
    </div>
  </div>
</div>
```

### Mockup container

```html
<div class="mockup">
  <div class="mockup-header">Preview: Dashboard Layout</div>
  <div class="mockup-body"><!-- your mockup HTML --></div>
</div>
```

### Split view（side-by-side）

```html
<div class="split">
  <div class="mockup"><!-- left --></div>
  <div class="mockup"><!-- right --></div>
</div>
```

### Pros/Cons

```html
<div class="pros-cons">
  <div class="pros"><h4>Pros</h4><ul><li>Benefit</li></ul></div>
  <div class="cons"><h4>Cons</h4><ul><li>Drawback</li></ul></div>
</div>
```

### Mock elements（wireframe building blocks）

```html
<div class="mock-nav">Logo | Home | About | Contact</div>
<div style="display: flex;">
  <div class="mock-sidebar">Navigation</div>
  <div class="mock-content">Main content area</div>
</div>
<button class="mock-button">Action Button</button>
<input class="mock-input" placeholder="Input field">
<div class="placeholder">Placeholder area</div>
```

### Typography and sections

- `h2` — page title
- `h3` — section heading
- `.subtitle` — title 下方的 secondary text
- `.section` — 带 bottom margin 的 content block
- `.label` — small uppercase label text

## Browser Events 格式

当用户在浏览器中点击 options 时，他们的交互会记录到 `$STATE_DIR/events`（每行一个 JSON object）。当你推送新 screen 时，该文件会自动清除。

```jsonl
{"type":"click","choice":"a","text":"Option A - Simple Layout","timestamp":1706000101}
{"type":"click","choice":"c","text":"Option C - Complex Grid","timestamp":1706000108}
{"type":"click","choice":"b","text":"Option B - Hybrid","timestamp":1706000115}
```

完整 event stream 展示用户的探索路径 — 他们可能会在定下来之前点击多个选项。最后一个 `choice` event 通常是最终选择，但点击模式可以揭示值得追问的犹豫或偏好。

如果 `$STATE_DIR/events` 不存在，说明用户没有与浏览器交互 — 只使用他们的终端文本。

## 设计提示

- **根据问题缩放 fidelity** — layout 用 wireframes，polish 问题用 polish
- **每页解释问题** — 写“Which layout feels more professional?”，而不是只写“Pick one”
- **推进前先迭代** — 如果反馈改变当前 screen，写新版本
- **每个 screen 最多 2-4 个选项**
- **在重要时使用真实内容** — 对 photography portfolio，使用实际 images（Unsplash）。Placeholder content 会遮蔽设计问题。
- **保持 mockups 简单** — 专注 layout 和 structure，而不是 pixel-perfect design

## 文件命名

- 使用语义名称：`platform.html`、`visual-style.html`、`layout.html`
- 绝不要复用文件名 — 每个 screen 必须是新文件
- 对于迭代：追加版本后缀，如 `layout-v2.html`、`layout-v3.html`
- 服务器按 modification time 提供最新文件

## 清理

```bash
scripts/stop-server.sh $SESSION_DIR
```

如果 session 使用 `--project-dir`，mockup files 会持久保留在 `.superpowers/brainstorm/` 中供之后参考。只有 `/tmp` sessions 会在 stop 时被删除。

## 参考

- Frame template（CSS reference）：`scripts/frame-template.html`
- Helper script（client-side）：`scripts/helper.js`
