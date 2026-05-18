---
name: writing-plans
description: 当你已有多步骤任务的规格或需求，在接触代码前使用
---

# 编写计划

## 概述

编写全面的实现计划，假设工程师对我们的代码库没有上下文，而且品味可疑。记录他们需要知道的一切：每个任务要触碰哪些文件、代码、测试、可能需要检查的文档、如何测试。把完整计划拆成小块任务给他们。DRY。YAGNI。TDD。频繁提交。

假设他们是熟练开发者，但几乎不了解我们的工具集或问题领域。假设他们并不十分了解良好的测试设计。

**开始时宣布：**“我正在使用 writing-plans 技能来创建实现计划。”

**上下文：**如果在隔离 worktree 中工作，它应该已经在执行时通过 `superpowers:using-git-worktrees` 技能创建。

**计划保存到：**`docs/superpowers/plans/YYYY-MM-DD-<feature-name>.md`
- （用户对计划位置的偏好覆盖此默认值）

## 范围检查

如果规格覆盖多个独立子系统，它应该已经在 brainstorming 期间被拆分为子项目规格。如果没有，建议将其拆成多个计划 — 每个子系统一个。每个计划都应该独立产出可工作、可测试的软件。

## 文件结构

定义任务前，梳理将创建或修改哪些文件，以及每个文件负责什么。这是锁定拆分决策的位置。

- 设计具有清晰边界和定义良好接口的单元。每个文件都应该有一个清晰职责。
- 你最适合推理能一次装进上下文的代码，并且当文件聚焦时，你的编辑更可靠。偏好更小、聚焦的文件，而不是过大且做太多事的文件。
- 会一起变化的文件应该放在一起。按职责拆分，而不是按技术层拆分。
- 在现有代码库中，遵循已建立的模式。如果代码库使用大文件，不要单方面重构 - 但如果你正在修改的文件已经变得笨重，把拆分写进计划是合理的。

这个结构会影响任务拆分。每个任务都应该产生自包含的变更，并且独立来看也合理。

## 小块任务粒度

**每个步骤是一个动作（2-5 分钟）：**
- “Write the failing test” - 步骤
- “Run it to make sure it fails” - 步骤
- “Implement the minimal code to make the test pass” - 步骤
- “Run the tests and make sure they pass” - 步骤
- “Commit” - 步骤

## 计划文档头部

**每个计划都必须以这个头部开始：**

```markdown
# [Feature Name] Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** [One sentence describing what this builds]

**Architecture:** [2-3 sentences about approach]

**Tech Stack:** [Key technologies/libraries]

---
```

## 任务结构

````markdown
### Task N: [Component Name]

**Files:**
- Create: `exact/path/to/file.py`
- Modify: `exact/path/to/existing.py:123-145`
- Test: `tests/exact/path/to/test.py`

- [ ] **Step 1: Write the failing test**

```python
def test_specific_behavior():
    result = function(input)
    assert result == expected
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/path/test.py::test_name -v`
Expected: FAIL with "function not defined"

- [ ] **Step 3: Write minimal implementation**

```python
def function(input):
    return expected
```

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest tests/path/test.py::test_name -v`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add tests/path/test.py src/path/file.py
git commit -m "feat: add specific feature"
```
````

## 不要使用占位符

每个步骤都必须包含工程师需要的实际内容。这些是**计划失败** — 绝不要写：
- “TBD”、“TODO”、“implement later”、“fill in details”
- “Add appropriate error handling” / “add validation” / “handle edge cases”
- “Write tests for the above”（没有实际测试代码）
- “Similar to Task N”（重复代码 — 工程师可能会乱序阅读任务）
- 描述要做什么但没有展示如何做的步骤（代码步骤需要代码块）
- 引用任何任务中未定义的类型、函数或方法

## 记住
- 始终使用精确文件路径
- 每个步骤都有完整代码 — 如果某步骤修改代码，展示代码
- 精确命令和预期输出
- DRY、YAGNI、TDD、频繁提交

## 自我审查

写完整个计划后，用新鲜视角查看规格，并对照它检查计划。这是你自己运行的检查清单 — 不是 subagent 派发。

**1. 规格覆盖：**快速浏览规格中的每个章节/需求。你能指向实现它的任务吗？列出任何缺口。

**2. 占位符扫描：**搜索计划中的红旗 — “不要使用占位符”章节中的任何模式。修复它们。

**3. 类型一致性：**你在后续任务中使用的类型、方法签名和属性名，是否与前面定义的一致？Task 3 中叫 `clearLayers()` 的函数，在 Task 7 中叫 `clearFullLayers()`，这是 bug。

如果发现问题，内联修复。不需要重新审查 — 直接修复并继续。如果发现某个规格需求没有任务，就添加任务。

## 执行交接

保存计划后，提供执行选择：

**“Plan complete and saved to `docs/superpowers/plans/<filename>.md`. Two execution options:**

**1. Subagent-Driven (recommended)** - I dispatch a fresh subagent per task, review between tasks, fast iteration

**2. Inline Execution** - Execute tasks in this session using executing-plans, batch execution with checkpoints

**Which approach?”**

**如果选择 Subagent-Driven：**
- **必需子技能：**使用 superpowers:subagent-driven-development
- 每个任务使用新的 subagent + 两阶段审查

**如果选择 Inline Execution：**
- **必需子技能：**使用 superpowers:executing-plans
- 带检查点的批量执行
