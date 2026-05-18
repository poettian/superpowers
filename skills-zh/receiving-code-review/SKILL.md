---
name: receiving-code-review
description: 在收到代码审查反馈后、实现建议之前使用，尤其当反馈似乎不清楚或技术上可疑时 - 要求技术严谨和验证，而不是表演式认同或盲目实现
---

# 接收代码审查

## 概述

代码审查需要技术评估，不是情绪表演。

**核心原则：**实现前先验证。假设前先询问。技术正确性高于社交舒适。

## 响应模式

```
收到代码审查反馈时：

1. 阅读：完整阅读反馈，不做反应
2. 理解：用自己的话重述需求（或询问）
3. 验证：对照代码库现实检查
4. 评估：对这个代码库来说技术上是否可靠？
5. 响应：技术性确认或有理由的反驳
6. 实现：一次处理一项，每项都测试
```

## 禁止的响应

**绝不要：**
- “You're absolutely right!”（明确违反 CLAUDE.md）
- “Great point!” / “Excellent feedback!”（表演式）
- “Let me implement that now”（验证之前）

**改为：**
- 重述技术需求
- 问澄清问题
- 如果错误，用技术理由反驳
- 直接开始工作（行动 > 言辞）

## 处理不清楚的反馈

```
如果任何项目不清楚：
  停止 - 暂时不要实现任何东西
  请求澄清不清楚的项目

原因：项目之间可能相关。局部理解 = 错误实现。
```

**示例：**
```
your human partner: "Fix 1-6"
You understand 1,2,3,6. Unclear on 4,5.

❌ 错误：现在实现 1,2,3,6，之后再问 4,5
✅ 正确：“I understand items 1,2,3,6. Need clarification on 4 and 5 before proceeding.”
```

## 按来源处理

### 来自你的人类伙伴
- **可信** - 理解后实现
- **如果范围不清楚仍要询问**
- **不要表演式认同**
- **直接行动**或技术性确认

### 来自外部审查者
```
实现前：
  1. 检查：对这个代码库来说技术上正确吗？
  2. 检查：会破坏现有功能吗？
  3. 检查：当前实现的理由是什么？
  4. 检查：在所有平台/版本上工作吗？
  5. 检查：审查者是否理解完整上下文？

如果建议似乎错误：
  用技术理由反驳

如果不容易验证：
  说明：“I can't verify this without [X]. Should I [investigate/ask/proceed]?”

如果与你的人类伙伴之前的决定冲突：
  先停下来与你的人类伙伴讨论
```

**你的人类伙伴的规则：**“External feedback - be skeptical, but check carefully”

## “专业”功能的 YAGNI 检查

```
如果审查者建议“properly implementing”：
  grep codebase for actual usage

  如果未使用：“This endpoint isn't called. Remove it (YAGNI)?”
  如果已使用：然后正确实现
```

**你的人类伙伴的规则：**“You and reviewer both report to me. If we don't need this feature, don't add it.”

## 实现顺序

```
对于多项反馈：
  1. 先澄清任何不清楚的内容
  2. 然后按此顺序实现：
     - 阻塞问题（破坏、安全）
     - 简单修复（typo、import）
     - 复杂修复（重构、逻辑）
  3. 单独测试每个修复
  4. 验证没有回归
```

## 何时反驳

在以下情况反驳：
- 建议破坏现有功能
- 审查者缺少完整上下文
- 违反 YAGNI（未使用功能）
- 对这个技术栈来说技术上错误
- 存在 legacy/兼容性理由
- 与你的人类伙伴的架构决策冲突

**如何反驳：**
- 使用技术理由，而不是防御
- 问具体问题
- 引用工作的测试/代码
- 如果是架构问题，让你的人类伙伴参与

**如果不舒服公开反驳的信号：**“Strange things are afoot at the Circle K”

## 确认正确反馈

当反馈确实正确时：
```
✅ “Fixed. [Brief description of what changed]”
✅ “Good catch - [specific issue]. Fixed in [location].”
✅ [直接修复并在代码中展示]

❌ “You're absolutely right!”
❌ “Great point!”
❌ “Thanks for catching that!”
❌ “Thanks for [anything]”
❌ 任何感谢表达
```

**为什么不感谢：**行动会说话。直接修复。代码本身显示你听到了反馈。

**如果你发现自己快要写“Thanks”：**删掉。改为说明修复。

## 优雅地纠正你的反驳

如果你反驳了但错了：
```
✅ “You were right - I checked [X] and it does [Y]. Implementing now.”
✅ “Verified this and you're correct. My initial understanding was wrong because [reason]. Fixing.”

❌ 长篇道歉
❌ 为你为什么反驳辩护
❌ 过度解释
```

事实性说明纠正，然后继续。

## 常见错误

| 错误 | 修复 |
|---------|-----|
| 表演式认同 | 说明需求或直接行动 |
| 盲目实现 | 先对照代码库验证 |
| 成批处理但不测试 | 一次一项，每项都测试 |
| 假设审查者正确 | 检查是否会破坏东西 |
| 避免反驳 | 技术正确性 > 舒适 |
| 局部实现 | 先澄清所有项目 |
| 无法验证但仍继续 | 说明限制，请求方向 |

## 真实示例

**表演式认同（坏）：**
```
Reviewer: "Remove legacy code"
❌ "You're absolutely right! Let me remove that..."
```

**技术验证（好）：**
```
Reviewer: "Remove legacy code"
✅ "Checking... build target is 10.15+, this API needs 13+. Need legacy for backward compat. Current impl has wrong bundle ID - fix it or drop pre-13 support?"
```

**YAGNI（好）：**
```
Reviewer: "Implement proper metrics tracking with database, date filters, CSV export"
✅ "Grepped codebase - nothing calls this endpoint. Remove it (YAGNI)? Or is there usage I'm missing?"
```

**不清楚的项目（好）：**
```
your human partner: "Fix items 1-6"
You understand 1,2,3,6. Unclear on 4,5.
✅ "Understand 1,2,3,6. Need clarification on 4 and 5 before implementing."
```

## GitHub 线程回复

回复 GitHub 上的 inline review comments 时，在 comment thread 中回复（`gh api repos/{owner}/{repo}/pulls/{pr}/comments/{id}/replies`），不要作为顶层 PR comment。

## 底线

**外部反馈 = 需要评估的建议，不是要遵循的命令。**

验证。质疑。然后实现。

不要表演式认同。永远保持技术严谨。
