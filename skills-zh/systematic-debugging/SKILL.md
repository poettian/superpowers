---
name: systematic-debugging
description: 遇到任何 bug、测试失败或意外行为时，在提出修复前使用
---

# 系统化调试

## 概述

随机修复浪费时间并制造新 bug。快速补丁会掩盖底层问题。

**核心原则：**尝试修复前始终找到根因。症状修复就是失败。

**违反这个流程的字面要求，就是违反调试的精神。**

## 铁律

```
没有先做根因调查，就没有修复
```

如果你没有完成阶段 1，就不能提出修复。

## 何时使用

用于任何技术问题：
- 测试失败
- 生产 bug
- 意外行为
- 性能问题
- 构建失败
- 集成问题

**尤其在以下情况使用：**
- 有时间压力（紧急情况让猜测更诱人）
- “Just one quick fix” 看起来很明显
- 你已经尝试了多个修复
- 之前的修复没起作用
- 你没有完全理解问题

**不要在以下情况跳过：**
- 问题看起来简单（简单 bug 也有根因）
- 你很赶时间（匆忙保证返工）
- 经理要它现在修好（系统化比乱撞更快）

## 四个阶段

进入下一阶段前，你必须完成每个阶段。

### 阶段 1：根因调查

**在尝试任何修复之前：**

1. **仔细阅读错误消息**
   - 不要跳过错误或 warning
   - 它们经常包含确切解决方案
   - 完整阅读 stack traces
   - 记录行号、文件路径、错误码

2. **稳定复现**
   - 你能可靠触发它吗？
   - 精确步骤是什么？
   - 每次都会发生吗？
   - 如果不可复现 → 收集更多数据，不要猜

3. **检查近期变更**
   - 什么变更可能导致这个？
   - Git diff、recent commits
   - 新依赖、config changes
   - 环境差异

4. **在多组件系统中收集证据**

   **当系统有多个组件时（CI → build → signing，API → service → database）：**

   **提出修复前，添加诊断 instrumentation：**
   ```
   对每个组件边界：
     - Log 进入组件的数据
     - Log 离开组件的数据
     - 验证 environment/config propagation
     - 检查每一层的 state

   运行一次，收集显示它在哪里破坏的证据
   然后分析证据以识别失败组件
   然后调查那个具体组件
   ```

   **示例（多层系统）：**
   ```bash
   # Layer 1: Workflow
   echo "=== Secrets available in workflow: ==="
   echo "IDENTITY: ${IDENTITY:+SET}${IDENTITY:-UNSET}"

   # Layer 2: Build script
   echo "=== Env vars in build script: ==="
   env | grep IDENTITY || echo "IDENTITY not in environment"

   # Layer 3: Signing script
   echo "=== Keychain state: ==="
   security list-keychains
   security find-identity -v

   # Layer 4: Actual signing
   codesign --sign "$IDENTITY" --verbose=4 "$APP"
   ```

   **这会揭示：**哪一层失败（secrets → workflow ✓，workflow → build ✗）

5. **追踪数据流**

   **当错误位于调用栈深处时：**

   完整的向后追踪技术见本目录中的 `root-cause-tracing.md`。

   **快速版本：**
   - 坏值从哪里来？
   - 谁用坏值调用了这里？
   - 继续向上追踪，直到找到源头
   - 在源头修复，不在症状处修复

### 阶段 2：模式分析

**修复前找到模式：**

1. **找到可工作的示例**
   - 在同一代码库中定位类似的可工作代码
   - 与坏掉部分相似的东西中，什么是工作的？

2. **与参考对比**
   - 如果实现 pattern，完整阅读 reference implementation
   - 不要略读 - 阅读每一行
   - 在应用前完全理解 pattern

3. **识别差异**
   - 可工作版本和坏掉版本之间有什么不同？
   - 列出每个差异，无论多小
   - 不要假设“that can't matter”

4. **理解依赖**
   - 这个需要哪些其他组件？
   - 哪些 settings、config、environment？
   - 它做了什么假设？

### 阶段 3：假设和测试

**科学方法：**

1. **形成单一假设**
   - 清楚说明：“I think X is the root cause because Y”
   - 写下来
   - 具体，不要含糊

2. **最小测试**
   - 做尽可能小的变更来测试假设
   - 一次一个变量
   - 不要一次修复多个东西

3. **继续前验证**
   - 有效？是 → 阶段 4
   - 无效？形成新假设
   - 不要在上面继续叠加更多修复

4. **当你不知道时**
   - 说“I don't understand X”
   - 不要假装知道
   - 请求帮助
   - 研究更多

### 阶段 4：实现

**修复根因，不是症状：**

1. **创建失败测试用例**
   - 尽可能简单的复现
   - 如果可能，使用自动化测试
   - 没有框架时使用一次性测试脚本
   - 修复前必须有
   - 使用 `superpowers:test-driven-development` 技能编写真正的失败测试

2. **实现单一修复**
   - 处理已识别的根因
   - 一次一个变更
   - 没有“while I'm here”改进
   - 不捆绑重构

3. **验证修复**
   - 测试现在通过了吗？
   - 没有破坏其他测试？
   - 问题真的解决了吗？

4. **如果修复不起作用**
   - 停止
   - 计数：你尝试了多少个修复？
   - 如果 < 3：回到阶段 1，带着新信息重新分析
   - **如果 ≥ 3：停止并质疑架构（见下面步骤 5）**
   - 不要在没有架构讨论的情况下尝试第 4 个修复

5. **如果 3 个以上修复失败：质疑架构**

   **表示架构问题的模式：**
   - 每个修复都在不同位置揭示新的共享状态/耦合/问题
   - 修复需要“massive refactoring”才能实现
   - 每个修复都在别处制造新症状

   **停止并质疑基本面：**
   - 这个 pattern 从根本上可靠吗？
   - 我们是否“sticking with it through sheer inertia”？
   - 我们应该重构架构，而不是继续修复症状吗？

   **尝试更多修复前，与你的人类伙伴讨论**

   这不是假设失败 - 这是错误架构。

## 红旗 - 停止并遵循流程

如果你发现自己在想：
- “Quick fix for now, investigate later”
- “Just try changing X and see if it works”
- “Add multiple changes, run tests”
- “Skip the test, I'll manually verify”
- “It's probably X, let me fix that”
- “I don't fully understand but this might work”
- “Pattern says X but I'll adapt it differently”
- “Here are the main problems: [lists fixes without investigation]”
- 在追踪数据流前提出解决方案
- **“One more fix attempt”（当已经尝试 2+ 次时）**
- **每个修复都在不同位置揭示新问题**

**所有这些都意味着：停止。回到阶段 1。**

**如果 3 个以上修复失败：**质疑架构（见阶段 4.5）

## 你的人类伙伴提示你做错了的信号

**留意这些重定向：**
- “Is that not happening?” - 你在未验证的情况下假设
- “Will it show us...?” - 你本该添加证据收集
- “Stop guessing” - 你在未理解的情况下提出修复
- “Ultrathink this” - 质疑基本面，而不只是症状
- “We're stuck?”（沮丧）- 你的方法不起作用

**看到这些时：**停止。回到阶段 1。

## 常见合理化

| 借口 | 现实 |
|--------|---------|
| “问题很简单，不需要流程” | 简单问题也有根因。流程对简单 bug 很快。 |
| “紧急，没时间走流程” | 系统化调试比 guess-and-check 乱撞更快。 |
| “先试这个，然后再调查” | 第一个修复会设定模式。从一开始就做对。 |
| “确认修复有效后我会写测试” | 未测试修复不会稳固。测试先行证明它。 |
| “一次多个修复节省时间” | 无法隔离什么起作用。会造成新 bug。 |
| “参考太长，我会适配 pattern” | 局部理解保证产生 bug。完整阅读。 |
| “我看到问题了，让我修” | 看到症状 ≠ 理解根因。 |
| “One more fix attempt”（2+ 次失败后） | 3+ 次失败 = 架构问题。质疑 pattern，不要再修。 |

## 快速参考

| 阶段 | 关键活动 | 成功标准 |
|-------|---------------|------------------|
| **1. Root Cause** | 阅读错误、复现、检查变更、收集证据 | 理解 WHAT 和 WHY |
| **2. Pattern** | 找可工作示例、对比 | 识别差异 |
| **3. Hypothesis** | 形成理论、最小测试 | 已确认或新假设 |
| **4. Implementation** | 创建测试、修复、验证 | Bug 解决，测试通过 |

## 当流程揭示“没有根因”

如果系统化调查显示问题确实是环境、时序依赖或外部因素：

1. 你已经完成流程
2. 记录你调查了什么
3. 实现适当处理（retry、timeout、error message）
4. 添加 monitoring/logging 以供未来调查

**但：**95% 的“没有根因”情况都是调查不完整。

## 支持技术

这些技术是 systematic debugging 的一部分，可在本目录中找到：

- **`root-cause-tracing.md`** - 沿调用栈向后追踪 bugs，找到原始触发点
- **`defense-in-depth.md`** - 找到根因后在多层添加验证
- **`condition-based-waiting.md`** - 用 condition polling 替代任意 timeouts

**相关技能：**
- **superpowers:test-driven-development** - 用于创建失败测试用例（阶段 4，步骤 1）
- **superpowers:verification-before-completion** - 声称成功前验证修复有效

## 真实世界影响

来自调试会话：
- 系统化方法：15-30 分钟修复
- 随机修复方法：2-3 小时乱撞
- 首次修复率：95% vs 40%
- 引入新 bug：接近零 vs 常见
