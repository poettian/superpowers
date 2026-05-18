---
name: requesting-code-review
description: 在完成任务、实现主要功能，或合并前验证工作符合需求时使用
---

# 请求代码审查

派发代码审查者 subagent，在问题级联之前捕捉它们。审查者获得为评估精确构造的上下文 — 绝不是你的会话历史。这让审查者专注于工作产物，而不是你的思考过程，并为你保留继续工作的上下文。

**核心原则：**尽早审查，经常审查。

## 何时请求审查

**强制：**
- subagent-driven development 中每个任务之后
- 完成主要功能之后
- 合并到 main 之前

**可选但有价值：**
- 卡住时（新鲜视角）
- 重构前（基线检查）
- 修复复杂 bug 后

## 如何请求

**1. 获取 git SHA：**
```bash
BASE_SHA=$(git rev-parse HEAD~1)  # or origin/main
HEAD_SHA=$(git rev-parse HEAD)
```

**2. 派发代码审查者 subagent：**

使用 `general-purpose` 类型的 Task tool，填写 `code-reviewer.md` 中的模板

**占位符：**
- `{DESCRIPTION}` - 你构建内容的简要摘要
- `{PLAN_OR_REQUIREMENTS}` - 它应该做什么
- `{BASE_SHA}` - 起始提交
- `{HEAD_SHA}` - 结束提交

**3. 根据反馈行动：**
- 立即修复 Critical 问题
- 继续前修复 Important 问题
- 记录 Minor 问题以备之后处理
- 如果审查者错了，带着理由反驳

## 示例

```
[刚完成 Task 2：Add verification function]

You: Let me request code review before proceeding.

BASE_SHA=$(git log --oneline | grep "Task 1" | head -1 | awk '{print $1}')
HEAD_SHA=$(git rev-parse HEAD)

[Dispatch code reviewer subagent]
  DESCRIPTION: Added verifyIndex() and repairIndex() with 4 issue types
  PLAN_OR_REQUIREMENTS: Task 2 from docs/superpowers/plans/deployment-plan.md
  BASE_SHA: a7981ec
  HEAD_SHA: 3df7661

[Subagent returns]:
  Strengths: Clean architecture, real tests
  Issues:
    Important: Missing progress indicators
    Minor: Magic number (100) for reporting interval
  Assessment: Ready to proceed

You: [Fix progress indicators]
[Continue to Task 3]
```

## 与工作流集成

**Subagent-Driven Development：**
- 每个任务后审查
- 在问题累积前捕捉它们
- 修复后再进入下一个任务

**Executing Plans：**
- 每个任务后或自然检查点审查
- 获取反馈、应用、继续

**Ad-Hoc Development：**
- 合并前审查
- 卡住时审查

## 红旗

**绝不要：**
- 因为“它很简单”而跳过审查
- 忽略 Critical 问题
- 带着未修复的 Important 问题继续
- 与有效技术反馈争辩

**如果审查者错了：**
- 用技术理由反驳
- 展示证明它有效的代码/测试
- 请求澄清

见模板：requesting-code-review/code-reviewer.md
