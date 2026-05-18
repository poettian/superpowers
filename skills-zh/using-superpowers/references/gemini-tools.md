# Gemini CLI 工具映射

技能使用 Claude Code 工具名称。当你在技能中遇到这些名称时，使用你的平台等价物：

| 技能引用 | Gemini CLI 等价物 |
|-----------------|----------------------|
| `Read`（文件读取） | `read_file` |
| `Write`（文件创建） | `write_file` |
| `Edit`（文件编辑） | `replace` |
| `Bash`（运行命令） | `run_shell_command` |
| `Grep`（搜索文件内容） | `grep_search` |
| `Glob`（按名称搜索文件） | `glob` |
| `TodoWrite`（任务跟踪） | `write_todos` |
| `Skill` tool（调用技能） | `activate_skill` |
| `WebSearch` | `google_web_search` |
| `WebFetch` | `web_fetch` |
| `Task` tool（派发 subagent） | `@agent-name`（见 [Subagent support](#subagent-support)） |

## Subagent 支持

Gemini CLI 通过 `@` 语法原生支持 subagents。使用内置 `@generalist` agent 来派发任何任务 — 它能访问所有工具，并遵循你提供的提示。

当某个技能说要派发命名 agent type 时，使用 `@generalist` 并带上来自该技能提示模板的完整提示：

| 技能指令 | Gemini CLI 等价物 |
|-------------------|----------------------|
| `Task tool (superpowers:implementer)` | 带填好 `implementer-prompt.md` 模板的 `@generalist` |
| `Task tool (superpowers:spec-reviewer)` | 带填好 `spec-reviewer-prompt.md` 模板的 `@generalist` |
| `Task tool (superpowers:code-reviewer)` | `@code-reviewer`（bundled agent）或带填好 review prompt 的 `@generalist` |
| `Task tool (superpowers:code-quality-reviewer)` | 带填好 `code-quality-reviewer-prompt.md` 模板的 `@generalist` |
| 带 inline prompt 的 `Task tool (general-purpose)` | 带你的 inline prompt 的 `@generalist` |

### 填充提示

技能提供带占位符的提示模板，例如 `{WHAT_WAS_IMPLEMENTED}` 或 `[FULL TEXT of task]`。填充所有占位符，并将完整提示作为消息传给 `@generalist`。提示模板本身包含 agent 的角色、审查标准和预期输出格式 — `@generalist` 会遵循它。

### 并行派发

Gemini CLI 支持并行 subagent 派发。当技能要求你并行派发多个独立 subagent 任务时，在同一个提示中请求所有这些 `@generalist` 或命名 subagent 任务。保持依赖任务顺序执行，但不要仅为了保留更简单的历史而串行化独立 subagent 任务。

## 其他 Gemini CLI 工具

这些工具在 Gemini CLI 中可用，但在 Claude Code 中没有等价物：

| 工具 | 目的 |
|------|---------|
| `list_directory` | 列出文件和子目录 |
| `save_memory` | 将事实持久化到 GEMINI.md 以供未来会话使用 |
| `ask_user` | 请求用户结构化输入 |
| `tracker_create_task` | 丰富任务管理（create、update、list、visualize） |
| `enter_plan_mode` / `exit_plan_mode` | 在进行变更前切换到只读 research mode |
