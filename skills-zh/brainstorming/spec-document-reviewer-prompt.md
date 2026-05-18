# 规格文档审查者提示模板

在派发规格文档审查者 subagent 时使用此模板。

**目的：**验证规格完整、一致，并且可以开始实现计划。

**派发时机：**规格文档写入 docs/superpowers/specs/ 后。

```
Task tool (general-purpose):
  description: "Review spec document"
  prompt: |
    你是规格文档审查者。验证这份规格完整且可以开始规划。

    **要审查的规格：**[SPEC_FILE_PATH]

    ## 要检查什么

    | 类别 | 要寻找什么 |
    |----------|------------------|
    | 完整性 | TODO、占位符、“TBD”、不完整章节 |
    | 一致性 | 内部矛盾、冲突需求 |
    | 清晰度 | 需求是否含糊到足以导致有人构建错误的东西 |
    | 范围 | 是否足够聚焦于单个计划 — 没有覆盖多个独立子系统 |
    | YAGNI | 未请求的功能、过度工程 |

    ## 校准

    **只标记会在实现规划期间造成真实问题的问题。**
    缺少章节、矛盾，或需求含糊到可以被两种方式理解 —
    这些才是问题。轻微措辞改进、风格偏好、
    以及“某些章节不如其他章节详细”不是问题。

    除非存在会导致计划有缺陷的严重缺口，否则批准。

    ## 输出格式

    ## Spec Review

    **Status:** Approved | Issues Found

    **Issues (if any):**
    - [Section X]: [specific issue] - [why it matters for planning]

    **Recommendations (advisory, do not block approval):**
    - [suggestions for improvement]
```

**审查者返回：**状态、问题（如有）、建议
