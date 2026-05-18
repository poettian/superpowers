---
name: using-git-worktrees
description: 开始需要与当前工作区隔离的功能工作，或执行实现计划前使用 - 确保存在隔离工作区，可通过原生工具或 git worktree fallback
---

# 使用 Git Worktrees

## 概述

确保工作发生在隔离工作区中。优先使用你平台的原生 worktree 工具。只有在没有原生工具可用时，才 fallback 到手动 git worktrees。

**核心原则：**先检测已有隔离。然后使用原生工具。然后 fallback 到 git。绝不要对抗 harness。

**开始时宣布：**“我正在使用 using-git-worktrees 技能来设置隔离工作区。”

## 步骤 0：检测已有隔离

**在创建任何东西之前，检查你是否已经在隔离工作区中。**

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
BRANCH=$(git branch --show-current)
```

**Submodule guard：**`GIT_DIR != GIT_COMMON` 在 git submodules 中也为真。在得出“已经在 worktree 中”之前，验证你不在 submodule 中：

```bash
# If this returns a path, you're in a submodule, not a worktree — treat as normal repo
git rev-parse --show-superproject-working-tree 2>/dev/null
```

**如果 `GIT_DIR != GIT_COMMON`（且不是 submodule）：**你已经在 linked worktree 中。跳到步骤 3（项目设置）。不要创建另一个 worktree。

带着分支状态报告：
- 在分支上：“Already in isolated workspace at `<path>` on branch `<name>`.”
- Detached HEAD：“Already in isolated workspace at `<path>` (detached HEAD, externally managed). Branch creation needed at finish time.”

**如果 `GIT_DIR == GIT_COMMON`（或在 submodule 中）：**你在普通 repo checkout 中。

用户是否已经在你的指令中表明他们的 worktree 偏好？如果没有，在创建 worktree 前请求同意：

> “Would you like me to set up an isolated worktree? It protects your current branch from changes.”

尊重任何已声明的偏好，不要询问。如果用户拒绝同意，就在原地工作并跳到步骤 3。

## 步骤 1：创建隔离工作区

**你有两种机制。按这个顺序尝试。**

### 1a. 原生 Worktree 工具（首选）

用户已请求隔离工作区（步骤 0 同意）。你是否已经有创建 worktree 的方式？它可能是名为 `EnterWorktree`、`WorktreeCreate` 的工具、`/worktree` 命令，或 `--worktree` flag。如果有，使用它并跳到步骤 3。

原生工具会自动处理目录放置、分支创建和清理。当你有原生工具时使用 `git worktree add`，会创建你的 harness 看不到或无法管理的 phantom state。

只有当没有可用的原生 worktree 工具时，才继续到步骤 1b。

### 1b. Git Worktree Fallback

**只有在步骤 1a 不适用时才使用这个** — 你没有可用的原生 worktree 工具。使用 git 手动创建 worktree。

#### 目录选择

遵循这个优先顺序。明确的用户偏好永远优先于观察到的文件系统状态。

1. **检查你的指令中是否有声明的 worktree 目录偏好。**如果用户已经指定一个，直接使用，不要询问。

2. **检查现有的项目本地 worktree 目录：**
   ```bash
   ls -d .worktrees 2>/dev/null     # Preferred (hidden)
   ls -d worktrees 2>/dev/null      # Alternative
   ```
   如果找到，使用它。如果两者都存在，`.worktrees` 优先。

3. **检查现有全局目录：**
   ```bash
   project=$(basename "$(git rev-parse --show-toplevel)")
   ls -d ~/.config/superpowers/worktrees/$project 2>/dev/null
   ```
   如果找到，使用它（与 legacy global path 向后兼容）。

4. **如果没有其他可用指引**，默认使用项目根目录下的 `.worktrees/`。

#### 安全验证（仅项目本地目录）

**创建 worktree 前必须验证目录被忽略：**

```bash
git check-ignore -q .worktrees 2>/dev/null || git check-ignore -q worktrees 2>/dev/null
```

**如果未被忽略：**添加到 .gitignore，提交该变更，然后继续。

**为什么关键：**防止意外将 worktree 内容提交到仓库。

全局目录（`~/.config/superpowers/worktrees/`）不需要验证。

#### 创建 Worktree

```bash
project=$(basename "$(git rev-parse --show-toplevel)")

# Determine path based on chosen location
# For project-local: path="$LOCATION/$BRANCH_NAME"
# For global: path="~/.config/superpowers/worktrees/$project/$BRANCH_NAME"

git worktree add "$path" -b "$BRANCH_NAME"
cd "$path"
```

**Sandbox fallback：**如果 `git worktree add` 因权限错误失败（sandbox 拒绝），告诉用户 sandbox 阻止了 worktree 创建，你会改在当前目录工作。然后在原地运行 setup 和 baseline tests。

## 步骤 3：项目设置

自动检测并运行适当设置：

```bash
# Node.js
if [ -f package.json ]; then npm install; fi

# Rust
if [ -f Cargo.toml ]; then cargo build; fi

# Python
if [ -f requirements.txt ]; then pip install -r requirements.txt; fi
if [ -f pyproject.toml ]; then poetry install; fi

# Go
if [ -f go.mod ]; then go mod download; fi
```

## 步骤 4：验证干净基线

运行测试以确保工作区起始状态干净：

```bash
# Use project-appropriate command
npm test / cargo test / pytest / go test ./...
```

**如果测试失败：**报告失败，询问是否继续或调查。

**如果测试通过：**报告就绪。

### 报告

```
Worktree ready at <full-path>
Tests passing (<N> tests, 0 failures)
Ready to implement <feature-name>
```

## 快速参考

| 情况 | 行动 |
|-----------|--------|
| 已经在 linked worktree 中 | 跳过创建（步骤 0） |
| 在 submodule 中 | 视为普通 repo（步骤 0 guard） |
| 原生 worktree 工具可用 | 使用它（步骤 1a） |
| 没有原生工具 | Git worktree fallback（步骤 1b） |
| `.worktrees/` 存在 | 使用它（验证被忽略） |
| `worktrees/` 存在 | 使用它（验证被忽略） |
| 两者都存在 | 使用 `.worktrees/` |
| 两者都不存在 | 检查指令文件，然后默认 `.worktrees/` |
| 全局路径存在 | 使用它（向后兼容） |
| 目录未被忽略 | 添加到 .gitignore + 提交 |
| 创建时权限错误 | Sandbox fallback，在原地工作 |
| 基线期间测试失败 | 报告失败 + 询问 |
| 没有 package.json/Cargo.toml | 跳过依赖安装 |

## 常见错误

### 对抗 harness

- **问题：**平台已经提供隔离时仍使用 `git worktree add`
- **修复：**步骤 0 检测已有隔离。步骤 1a 让位于原生工具。

### 跳过检测

- **问题：**在现有 worktree 内创建嵌套 worktree
- **修复：**创建任何东西前总是运行步骤 0

### 跳过 ignore 验证

- **问题：**Worktree 内容被跟踪，污染 git status
- **修复：**创建项目本地 worktree 前总是使用 `git check-ignore`

### 假设目录位置

- **问题：**造成不一致，违反项目约定
- **修复：**遵循优先级：现有 > 全局 legacy > 指令文件 > 默认

### 带着失败测试继续

- **问题：**无法区分新 bug 与预先存在的问题
- **修复：**报告失败，获得明确许可再继续

## 红旗

**绝不要：**
- 当步骤 0 检测到已有隔离时创建 worktree
- 当你有原生 worktree 工具（例如 `EnterWorktree`）时使用 `git worktree add`。这是第一大错误 — 如果你有它，就使用它。
- 跳过步骤 1a，直接跳到步骤 1b 的 git 命令
- 不验证它被忽略就创建 worktree（项目本地）
- 跳过基线测试验证
- 不询问就带着失败测试继续

**总是：**
- 先运行步骤 0 检测
- 优先使用原生工具，而不是 git fallback
- 遵循目录优先级：现有 > 全局 legacy > 指令文件 > 默认
- 为项目本地目录验证它被忽略
- 自动检测并运行项目设置
- 验证干净测试基线
