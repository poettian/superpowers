# Copilot CLI 工具映射

技能使用 Claude Code 工具名称。当你在技能中遇到这些名称时，使用你的平台等价物：

| 技能引用 | Copilot CLI 等价物 |
|-----------------|----------------------|
| `Read`（文件读取） | `view` |
| `Write`（文件创建） | `create` |
| `Edit`（文件编辑） | `edit` |
| `Bash`（运行命令） | `bash` |
| `Grep`（搜索文件内容） | `grep` |
| `Glob`（按名称搜索文件） | `glob` |
| `Skill` tool（调用技能） | `skill` |
| `WebFetch` | `web_fetch` |
| `Task` tool（派发 subagent） | 带有 `agent_type: "general-purpose"` 或 `"explore"` 的 `task` |
| 多个 `Task` 调用（并行） | 多个 `task` 调用 |
| Task 状态/输出 | `read_agent`、`list_agents` |
| `TodoWrite`（任务跟踪） | 带内置 `todos` 表的 `sql` |
| `WebSearch` | 无等价物 — 使用带搜索引擎 URL 的 `web_fetch` |
| `EnterPlanMode` / `ExitPlanMode` | 无等价物 — 留在主会话中 |

## 异步 shell 会话

Copilot CLI 支持持久异步 shell 会话，这在 Claude Code 中没有直接等价物：

| 工具 | 目的 |
|------|---------|
| 带 `async: true` 的 `bash` | 在后台启动长时间运行的命令 |
| `write_bash` | 向正在运行的异步会话发送输入 |
| `read_bash` | 从异步会话读取输出 |
| `stop_bash` | 终止异步会话 |
| `list_bash` | 列出所有活动 shell 会话 |

## 其他 Copilot CLI 工具

| 工具 | 目的 |
|------|---------|
| `store_memory` | 为未来会话持久化关于代码库的事实 |
| `report_intent` | 用当前意图更新 UI 状态行 |
| `sql` | 查询会话的 SQLite 数据库（todos、metadata） |
| `fetch_copilot_cli_documentation` | 查找 Copilot CLI 文档 |
| GitHub MCP tools (`github-mcp-server-*`) | 原生 GitHub API 访问（issues、PRs、code search） |
