# 创建日志：Systematic Debugging 技能

提取、结构化和强化关键技能的参考示例。

## 来源材料

从 `~/.claude/CLAUDE.md` 提取 debugging framework：
- 4 阶段系统流程（Investigation → Pattern Analysis → Hypothesis → Implementation）
- 核心命令：始终找到根因，绝不修复症状
- 旨在抵抗时间压力和合理化的规则

## 提取决策

**包含什么：**
- 完整 4 阶段框架及所有规则
- 反捷径（“NEVER fix symptom”、“STOP and re-analyze”）
- 抗压力语言（“even if faster”、“even if I seem in a hurry”）
- 每个阶段的具体步骤

**排除什么：**
- 项目特定上下文
- 同一规则的重复变体
- 叙事解释（压缩为原则）

## 遵循 skill-creation/SKILL.md 的结构

1. **丰富的 when_to_use** - 包含症状和反模式
2. **类型：technique** - 带步骤的具体流程
3. **关键词** - “root cause”、“symptom”、“workaround”、“debugging”、“investigation”
4. **流程图** - “fix failed” → re-analyze vs add more fixes 的决策点
5. **逐阶段拆解** - 可扫描的检查清单格式
6. **反模式章节** - 不该做什么（对这个技能很关键）

## 强化元素

框架设计用于抵抗压力下的合理化：

### 语言选择
- “ALWAYS” / “NEVER”（不是“should” / “try to”）
- “even if faster” / “even if I seem in a hurry”
- “STOP and re-analyze”（明确暂停）
- “Don't skip past”（捕捉实际行为）

### 结构防御
- **阶段 1 必需** - 不能跳到实现
- **单一假设规则** - 强制思考，防止 shotgun fixes
- **明确失败模式** - “IF your first fix doesn't work” 带强制动作
- **反模式章节** - 准确展示捷径看起来是什么样

### 冗余
- 根因命令出现在 overview + when_to_use + Phase 1 + implementation rules
- “NEVER fix symptom” 在不同上下文出现 4 次
- 每个阶段都有明确“don't skip”指导

## 测试方法

按照 skills/meta/testing-skills-with-subagents 创建 4 个验证测试：

### 测试 1：学术上下文（无压力）
- 简单 bug，没有时间压力
- **结果：**完全合规，完整调查

### 测试 2：时间压力 + 明显快速修复
- 用户“in a hurry”，症状修复看起来容易
- **结果：**抵抗捷径，遵循完整流程，找到真实根因

### 测试 3：复杂系统 + 不确定性
- 多层失败，不清楚是否能找到根因
- **结果：**系统调查，追踪所有层，找到源头

### 测试 4：第一次修复失败
- 假设不起作用，诱惑是添加更多修复
- **结果：**停止，重新分析，形成新假设（没有 shotgun）

**所有测试通过。**未发现合理化。

## 迭代

### 初始版本
- 完整 4 阶段框架
- 反模式章节
- “fix failed” 决策流程图

### 增强 1：TDD 参考
- 添加到 skills/testing/test-driven-development 的链接
- 说明 TDD 的“simplest code” ≠ debugging 的“root cause”
- 防止方法论之间的混淆

## 最终结果

强化后的技能：
- ✅ 清晰要求根因调查
- ✅ 抵抗时间压力合理化
- ✅ 为每个阶段提供具体步骤
- ✅ 明确展示反模式
- ✅ 在多个压力场景下测试
- ✅ 澄清与 TDD 的关系
- ✅ 可供使用

## 关键洞见

**最重要的强化：**反模式章节展示那些当下感觉合理的确切捷径。当 Claude 想“I'll just add this one quick fix”时，看到那个确切模式被列为错误，会产生认知摩擦。

## 使用示例

遇到 bug 时：
1. 加载技能：skills/debugging/systematic-debugging
2. 阅读 overview（10 秒）- 被提醒命令
3. 遵循 Phase 1 检查清单 - 被迫调查
4. 如果想跳过 - 看到反模式，停止
5. 完成所有阶段 - 找到根因

**时间投入：**5-10 分钟
**节省时间：**数小时的 symptom-whack-a-mole

---

*创建：2025-10-03*
*目的：技能提取和强化的参考示例*
