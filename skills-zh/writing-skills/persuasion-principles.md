# 技能设计的说服原则

## 概述

LLMs 会响应与人类相同的说服原则。理解这种心理有助于你设计更有效的技能 - 不是为了操纵，而是为了确保关键实践即使在压力下也会被遵循。

**研究基础：**Meincke et al. (2025) 用 N=28,000 次 AI conversations 测试了 7 个说服原则。说服技术使 compliance rates 增加超过一倍（33% → 72%，p < .001）。

## 七个原则

### 1. 权威
**是什么：**对专业知识、资质或官方来源的服从。

**它如何在技能中工作：**
- 命令式语言：“YOU MUST”、“Never”、“Always”
- 不可协商框架：“No exceptions”
- 消除决策疲劳和合理化

**何时使用：**
- 强制纪律的技能（TDD、verification requirements）
- 安全关键实践
- 已建立的最佳实践

**示例：**
```markdown
✅ Write code before test? Delete it. Start over. No exceptions.
❌ Consider writing tests first when feasible.
```

### 2. 承诺
**是什么：**与先前行动、陈述或公开声明保持一致。

**它如何在技能中工作：**
- 要求宣布：“Announce skill usage”
- 强制明确选择：“Choose A, B, or C”
- 使用 tracking：TodoWrite for checklists

**何时使用：**
- 确保技能实际被遵循
- 多步骤流程
- 问责机制

**示例：**
```markdown
✅ When you find a skill, you MUST announce: "I'm using [Skill Name]"
❌ Consider letting your partner know which skill you're using.
```

### 3. 稀缺
**是什么：**来自时间限制或有限可用性的紧迫性。

**它如何在技能中工作：**
- 有时间边界的要求：“Before proceeding”
- 顺序依赖：“Immediately after X”
- 防止拖延

**何时使用：**
- 即时验证要求
- 时间敏感工作流
- 防止“I'll do it later”

**示例：**
```markdown
✅ After completing a task, IMMEDIATELY request code review before proceeding.
❌ You can review code when convenient.
```

### 4. 社会认同
**是什么：**符合他人的做法或被认为正常的事。

**它如何在技能中工作：**
- 普遍模式：“Every time”、“Always”
- 失败模式：“X without Y = failure”
- 建立规范

**何时使用：**
- 记录通用实践
- 警告常见失败
- 强化标准

**示例：**
```markdown
✅ Checklists without TodoWrite tracking = steps get skipped. Every time.
❌ Some people find TodoWrite helpful for checklists.
```

### 5. 统一
**是什么：**共享身份、“we-ness”、群体归属。

**它如何在技能中工作：**
- 协作语言：“our codebase”、“we're colleagues”
- 共同目标：“we both want quality”

**何时使用：**
- 协作工作流
- 建立团队文化
- 非等级实践

**示例：**
```markdown
✅ We're colleagues working together. I need your honest technical judgment.
❌ You should probably tell me if I'm wrong.
```

### 6. 互惠
**是什么：**回报已获得利益的义务。

**它如何工作：**
- 谨慎使用 - 可能感觉像操纵
- 技能中很少需要

**何时避免：**
- 几乎总是（其他原则更有效）

### 7. 喜好
**是什么：**偏好与我们喜欢的人合作。

**它如何工作：**
- **不要用于 compliance**
- 与诚实反馈文化冲突
- 制造 sycophancy

**何时避免：**
- 对纪律执行总是避免

## 按技能类型组合原则

| 技能类型 | 使用 | 避免 |
|------------|-----|-------|
| 强制纪律 | Authority + Commitment + Social Proof | Liking, Reciprocity |
| 指导/技术 | Moderate Authority + Unity | Heavy authority |
| 协作 | Unity + Commitment | Authority, Liking |
| 参考 | 只要清晰 | 所有说服 |

## 为什么有效：心理学

**明线规则减少合理化：**
- “YOU MUST” 移除决策疲劳
- 绝对语言消除“这是例外吗？”的问题
- 明确 anti-rationalization 关闭具体 loopholes

**Implementation intentions 创造自动行为：**
- 清晰 triggers + required actions = 自动执行
- “When X, do Y” 比 “generally do Y” 更有效
- 减少 compliance 的 cognitive load

**LLMs 是 parahuman：**
- 在包含这些模式的人类文本上训练
- 权威语言在训练数据中先于 compliance
- 承诺序列（statement → action）频繁被建模
- 社会认同模式（everyone does X）建立规范

## 伦理使用

**正当：**
- 确保关键实践被遵循
- 创建有效文档
- 防止可预测失败

**不正当：**
- 为个人利益操纵
- 制造虚假紧迫性
- 基于愧疚的 compliance

**测试：**如果用户完全理解这种技术，它是否会服务于用户的真实利益？

## 研究引用

**Cialdini, R. B. (2021).** *Influence: The Psychology of Persuasion (New and Expanded).* Harper Business.
- Seven principles of persuasion
- Empirical foundation for influence research

**Meincke, L., Shapiro, D., Duckworth, A. L., Mollick, E., Mollick, L., & Cialdini, R. (2025).** Call Me A Jerk: Persuading AI to Comply with Objectionable Requests. University of Pennsylvania.
- 用 N=28,000 次 LLM conversations 测试 7 个原则
- 使用说服技术后 compliance 从 33% → 72%
- Authority、commitment、scarcity 最有效
- 验证 LLM behavior 的 parahuman model

## 快速参考

设计技能时，问：

1. **它是什么类型？**（Discipline vs. guidance vs. reference）
2. **我试图改变什么行为？**
3. **哪些原则适用？**（纪律通常用 authority + commitment）
4. **我是否组合太多？**（不要使用全部七个）
5. **这是否合乎伦理？**（服务用户的真实利益？）
