---
name: executing-plans
description: 当你有一份书面实现计划，需要在单独会话中带着审查检查点执行时使用
---

# 执行计划

## 概述

加载计划，进行严格审查，执行所有任务，完成后汇报。

**开始时宣布：**“我正在使用 executing-plans 技能来实现这个计划。”

**注意：**告诉你的人类伙伴，Superpowers 在能访问 subagent 时效果会好得多。如果在支持 subagent 的平台上运行，例如 Claude Code 或 Codex，工作质量会显著更高。如果 subagent 可用，使用 superpowers:subagent-driven-development，而不是这个技能。

## 流程

### 步骤 1：加载并审查计划
1. 阅读计划文件
2. 严格审查 - 找出关于计划的任何问题或疑虑
3. 如果有疑虑：在开始前向你的人类伙伴提出
4. 如果没有疑虑：创建 TodoWrite 并继续

### 步骤 2：执行任务

对于每个任务：
1. 标记为 in_progress
2. 精确遵循每个步骤（计划包含小块步骤）
3. 按指定运行验证
4. 标记为 completed

### 步骤 3：完成开发

所有任务完成并验证后：
- 宣布：“我正在使用 finishing-a-development-branch 技能来完成这项工作。”
- **必需子技能：**使用 superpowers:finishing-a-development-branch
- 遵循该技能来验证测试、展示选项、执行选择

## 何时停止并请求帮助

**在以下情况立即停止执行：**
- 遇到阻塞（缺少依赖、测试失败、指令不清楚）
- 计划存在阻止开始的关键缺口
- 你不理解某条指令
- 验证反复失败

**请求澄清，而不是猜测。**

## 何时回到早前步骤

**在以下情况回到审查（步骤 1）：**
- 伙伴基于你的反馈更新了计划
- 基本方法需要重新思考

**不要硬闯阻塞** - 停下来询问。

## 记住
- 先严格审查计划
- 精确遵循计划步骤
- 不要跳过验证
- 在计划要求时引用技能
- 遇到阻塞就停止，不要猜测
- 没有用户明确同意，绝不要在 main/master 分支上开始实现

## 集成

**必需工作流技能：**
- **superpowers:using-git-worktrees** - 确保隔离工作区（创建一个或验证已有工作区）
- **superpowers:writing-plans** - 创建本技能执行的计划
- **superpowers:finishing-a-development-branch** - 所有任务完成后完成开发
