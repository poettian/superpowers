# Codex 工具映射

技能使用 Claude Code 工具名称。当你在技能中遇到这些名称时，使用你的平台等价物：

| 技能引用 | Codex 等价物 |
|-----------------|------------------|
| `Task` tool（派发 subagent） | `spawn_agent`（见 [Subagent dispatch requires multi-agent support](#subagent-dispatch-requires-multi-agent-support)） |
| 多个 `Task` 调用（并行） | 多个 `spawn_agent` 调用 |
| Task 返回结果 | `wait_agent` |
| Task 自动完成 | `close_agent` 释放 slot |
| `TodoWrite`（任务跟踪） | `update_plan` |
| `Skill` tool（调用技能） | 技能原生加载 — 直接遵循指令 |
| `Read`、`Write`、`Edit`（文件） | 使用你的原生文件工具 |
| `Bash`（运行命令） | 使用你的原生 shell 工具 |

## Subagent 派发需要多 agent 支持

添加到你的 Codex 配置（`~/.codex/config.toml`）：

```toml
[features]
multi_agent = true
```

这会为 `dispatching-parallel-agents` 和 `subagent-driven-development` 等技能启用 `spawn_agent`、`wait_agent` 和 `close_agent`。

Legacy note：`rust-v0.115.0` 之前的 Codex build 将 spawned-agent
waiting 暴露为 `wait`。当前 Codex 对 spawned agents 使用 `wait_agent`。
`wait` 名称现在属于 code-mode `exec/wait`，它通过 `cell_id` 恢复 yielded exec
cell；它不是 spawned-agent result tool。

## 环境检测

创建 worktrees 或完成分支的技能，在继续前应该使用只读 git 命令检测它们的
环境：

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
BRANCH=$(git branch --show-current)
```

- `GIT_DIR != GIT_COMMON` → 已经在 linked worktree 中（跳过创建）
- `BRANCH` empty → detached HEAD（无法从 sandbox branch/push/PR）

见 `using-git-worktrees` 步骤 0 和 `finishing-a-development-branch`
步骤 1，了解每个技能如何使用这些信号。

## Codex App 完成

当 sandbox 阻止 branch/push 操作时（外部管理 worktree 中的 detached HEAD），
agent 提交所有工作，并告知用户使用 App 的原生控件：

- **"Create branch"** — 命名分支，然后通过 App UI commit/push/PR
- **"Hand off to local"** — 将工作转移到用户的本地 checkout

agent 仍然可以运行测试、stage 文件，并输出建议的分支名称、提交消息和 PR 描述，供用户复制。
