# 代码质量审查者提示模板

在派发代码质量审查者 subagent 时使用此模板。

**目的：**验证实现构建良好（干净、经过测试、可维护）

**只在规格合规审查通过后派发。**

```
Task tool (general-purpose):
  Use template at requesting-code-review/code-reviewer.md

  DESCRIPTION: [task summary, from implementer's report]
  PLAN_OR_REQUIREMENTS: Task N from [plan-file]
  BASE_SHA: [commit before task]
  HEAD_SHA: [current commit]
```

**除了标准代码质量关注点之外，审查者还应该检查：**
- 每个文件是否有一个清晰职责和定义良好的接口？
- 单元是否被拆分到可以独立理解和测试？
- 实现是否遵循计划中的文件结构？
- 这个实现是否创建了已经很大的新文件，或显著增大了现有文件？（不要标记预先存在的文件大小 — 关注这次变更贡献了什么。）

**代码审查者返回：**优点、问题（Critical/Important/Minor）、评估
