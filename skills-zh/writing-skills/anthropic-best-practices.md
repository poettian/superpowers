# Skill authoring best practices

> 学习如何编写 Claude 能发现并成功使用的有效 Skills。

好的 Skills 简洁、结构良好，并经过真实使用测试。本指南提供实用的 authoring decisions，帮助你编写 Claude 能发现并有效使用的 Skills。

关于 Skills 如何工作的概念背景，见 [Skills overview](/en/docs/agents-and-tools/agent-skills/overview)。

## 核心原则

### 简洁是关键

[context window](https://platform.claude.com/docs/en/build-with-claude/context-windows) 是公共资源。你的 Skill 与 Claude 需要知道的所有其他内容共享 context window，包括：

* System prompt
* Conversation history
* 其他 Skills 的 metadata
* 你的实际请求

不是 Skill 中的每个 token 都有即时成本。启动时，只会预加载所有 Skills 的 metadata（name 和 description）。Claude 只在 Skill 变得相关时读取 SKILL.md，并只在需要时读取额外文件。不过，SKILL.md 中保持简洁仍很重要：一旦 Claude 加载它，每个 token 都会与 conversation history 和其他 context 竞争。

**默认假设**：Claude 已经非常聪明

只添加 Claude 尚未具备的上下文。质疑每一条信息：

* “Claude 真的需要这个解释吗？”
* “我能假设 Claude 知道这个吗？”
* “这段话值得它的 token 成本吗？”

**好例子：简洁**（约 50 tokens）：

````markdown  theme={null}
## Extract PDF text

Use pdfplumber for text extraction:

```python
import pdfplumber

with pdfplumber.open("file.pdf") as pdf:
    text = pdf.pages[0].extract_text()
```
````

**坏例子：太冗长**（约 150 tokens）：

```markdown  theme={null}
## Extract PDF text

PDF (Portable Document Format) files are a common file format that contains
text, images, and other content. To extract text from a PDF, you'll need to
use a library. There are many libraries available for PDF processing, but we
recommend pdfplumber because it's easy to use and handles most cases well.
First, you'll need to install it using pip. Then you can use the code below...
```

简洁版本假设 Claude 知道 PDF 是什么，以及 libraries 如何工作。

### 设置适当自由度

让具体程度匹配任务的脆弱性和可变性。

**高自由度**（text-based instructions）：

在以下情况使用：

* 多种方法都有效
* 决策依赖上下文
* Heuristics 指导方法

示例：

```markdown  theme={null}
## Code review process

1. Analyze the code structure and organization
2. Check for potential bugs or edge cases
3. Suggest improvements for readability and maintainability
4. Verify adherence to project conventions
```

**中等自由度**（带参数的 pseudocode 或 scripts）：

在以下情况使用：

* 存在首选模式
* 一些变化可以接受
* Configuration 会影响行为

示例：

````markdown  theme={null}
## Generate report

Use this template and customize as needed:

```python
def generate_report(data, format="markdown", include_charts=True):
    # Process data
    # Generate output in specified format
    # Optionally include visualizations
```
````

**低自由度**（具体 scripts，很少或没有参数）：

在以下情况使用：

* 操作脆弱且容易出错
* 一致性至关重要
* 必须遵循特定顺序

示例：

````markdown  theme={null}
## Database migration

Run exactly this script:

```bash
python scripts/migrate.py --verify --backup
```

Do not modify the command or add additional flags.
````

**类比**：把 Claude 想象成探索路径的机器人：

* **两侧都是悬崖的窄桥**：只有一条安全路径。提供具体 guardrails 和精确指令（低自由度）。示例：必须按精确顺序运行的 database migrations。
* **没有危险的开阔场地**：很多路径都能成功。给出大方向并信任 Claude 找到最佳路线（高自由度）。示例：上下文决定最佳方法的 code reviews。

### 用你计划使用的所有模型测试

Skills 是对模型的补充，因此效果取决于底层模型。用你计划配合使用的所有模型测试你的 Skill。

**按模型的测试考虑：**

* **Claude Haiku**（快速、经济）：Skill 是否提供足够指导？
* **Claude Sonnet**（平衡）：Skill 是否清晰高效？
* **Claude Opus**（强推理）：Skill 是否避免过度解释？

对 Opus 完美有效的内容，可能需要为 Haiku 增加更多细节。如果你计划让 Skill 跨多个模型使用，目标是编写对所有模型都有效的指令。

## Skill 结构

<Note>
  **YAML Frontmatter**：SKILL.md frontmatter 需要两个字段：

  * `name` - Skill 的人类可读名称（最多 64 字符）
  * `description` - 描述 Skill 做什么以及何时使用的一行说明（最多 1024 字符）

  完整 Skill 结构细节见 [Skills overview](/en/docs/agents-and-tools/agent-skills/overview#skill-structure)。
</Note>

### 命名约定

使用一致命名模式，让 Skills 更容易被引用和讨论。我们建议 Skill 名称使用 **gerund form**（verb + -ing），因为这能清楚描述 Skill 提供的活动或能力。

**好命名示例（gerund form）：**

* “Processing PDFs”
* “Analyzing spreadsheets”
* “Managing databases”
* “Testing code”
* “Writing documentation”

**可接受替代：**

* Noun phrases：“PDF Processing”、“Spreadsheet Analysis”
* Action-oriented：“Process PDFs”、“Analyze Spreadsheets”

**避免：**

* 含糊名称：“Helper”、“Utils”、“Tools”
* 过度泛化：“Documents”、“Data”、“Files”
* 在你的 skill collection 中使用不一致模式

一致命名让以下事情更容易：

* 在文档和对话中引用 Skills
* 一眼理解 Skill 做什么
* 组织和搜索多个 Skills
* 维护专业、统一的 skill library

### 编写有效 descriptions

`description` 字段支持 Skill discovery，应该同时包含 Skill 做什么以及何时使用。

<Warning>
  **始终使用第三人称**。Description 会注入 system prompt，不一致的视角可能造成 discovery problems。

  * **Good:** “Processes Excel files and generates reports”
  * **Avoid:** “I can help you process Excel files”
  * **Avoid:** “You can use this to process Excel files”
</Warning>

**具体并包含 key terms**。同时包含 Skill 做什么，以及使用它的具体 triggers/contexts。

每个 Skill 恰好有一个 description 字段。Description 对 skill selection 至关重要：Claude 用它从可能 100+ 个可用 Skills 中选择正确 Skill。你的 description 必须提供足够细节，让 Claude 知道何时选择此 Skill，而 SKILL.md 的其余部分提供实现细节。

有效示例：

**PDF Processing skill：**

```yaml  theme={null}
description: Extract text and tables from PDF files, fill forms, merge documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction.
```

**Excel Analysis skill：**

```yaml  theme={null}
description: Analyze Excel spreadsheets, create pivot tables, generate charts. Use when analyzing Excel files, spreadsheets, tabular data, or .xlsx files.
```

**Git Commit Helper skill：**

```yaml  theme={null}
description: Generate descriptive commit messages by analyzing git diffs. Use when the user asks for help writing commit messages or reviewing staged changes.
```

避免这种含糊 description：

```yaml  theme={null}
description: Helps with documents
```

```yaml  theme={null}
description: Processes data
```

```yaml  theme={null}
description: Does stuff with files
```

### Progressive disclosure patterns

SKILL.md 作为 overview，按需指向详细材料，就像 onboarding guide 的目录。Progressive disclosure 如何工作的解释见 overview 中的 [How Skills work](/en/docs/agents-and-tools/agent-skills/overview#how-skills-work)。

**实践指南：**

* 为获得最佳性能，将 SKILL.md body 保持在 500 行以内
* 接近此限制时，将内容拆到单独文件
* 使用下方模式有效组织 instructions、code 和 resources

#### 视觉概览：从简单到复杂

基础 Skill 只有一个包含 metadata 和 instructions 的 SKILL.md 文件：

<img src="https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-simple-file.png?fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=87782ff239b297d9a9e8e1b72ed72db9" alt="Simple SKILL.md file showing YAML frontmatter and markdown body" data-og-width="2048" width="2048" data-og-height="1153" height="1153" data-path="images/agent-skills-simple-file.png" data-optimize="true" data-opv="3" srcset="https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-simple-file.png?w=280&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=c61cc33b6f5855809907f7fda94cd80e 280w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-simple-file.png?w=560&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=90d2c0c1c76b36e8d485f49e0810dbfd 560w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-simple-file.png?w=840&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=ad17d231ac7b0bea7e5b4d58fb4aeabb 840w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-simple-file.png?w=1100&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=f5d0a7a3c668435bb0aee9a3a8f8c329 1100w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-simple-file.png?w=1650&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=0e927c1af9de5799cfe557d12249f6e6 1650w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-simple-file.png?w=2500&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=46bbb1a51dd4c8202a470ac8c80a893d 2500w" />

随着 Skill 增长，你可以 bundle Claude 只在需要时加载的额外内容：

<img src="https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-bundling-content.png?fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=a5e0aa41e3d53985a7e3e43668a33ea3" alt="Bundling additional reference files like reference.md and forms.md." data-og-width="2048" width="2048" data-og-height="1327" height="1327" data-path="images/agent-skills-bundling-content.png" data-optimize="true" data-opv="3" srcset="https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-bundling-content.png?w=280&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=f8a0e73783e99b4a643d79eac86b70a2 280w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-bundling-content.png?w=560&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=dc510a2a9d3f14359416b706f067904a 560w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-bundling-content.png?w=840&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=82cd6286c966303f7dd914c28170e385 840w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-bundling-content.png?w=1100&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=56f3be36c77e4fe4b523df209a6824c6 1100w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-bundling-content.png?w=1650&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=d22b5161b2075656417d56f41a74f3dd 1650w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-bundling-content.png?w=2500&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=3dd4bdd6850ffcc96c6c45fcb0acd6eb 2500w" />

完整 Skill directory structure 可能如下：

```
pdf/
├── SKILL.md              # Main instructions (loaded when triggered)
├── FORMS.md              # Form-filling guide (loaded as needed)
├── reference.md          # API reference (loaded as needed)
├── examples.md           # Usage examples (loaded as needed)
└── scripts/
    ├── analyze_form.py   # Utility script (executed, not loaded)
    ├── fill_form.py      # Form filling script
    └── validate.py       # Validation script
```

#### 模式 1：带 references 的 high-level guide

````markdown  theme={null}
---
name: PDF Processing
description: Extracts text and tables from PDF files, fills forms, and merges documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction.
---

# PDF Processing

## Quick start

Extract text with pdfplumber:
```python
import pdfplumber
with pdfplumber.open("file.pdf") as pdf:
    text = pdf.pages[0].extract_text()
```

## Advanced features

**Form filling**: See [FORMS.md](FORMS.md) for complete guide
**API reference**: See [REFERENCE.md](REFERENCE.md) for all methods
**Examples**: See [EXAMPLES.md](EXAMPLES.md) for common patterns
````

Claude 只在需要时加载 FORMS.md、REFERENCE.md 或 EXAMPLES.md。

#### 模式 2：Domain-specific organization

对于包含多个 domains 的 Skills，按 domain 组织内容以避免加载无关 context。当用户询问 sales metrics 时，Claude 只需要阅读 sales-related schemas，而不是 finance 或 marketing data。这保持 token usage 低且 context 聚焦。

```
bigquery-skill/
├── SKILL.md (overview and navigation)
└── reference/
    ├── finance.md (revenue, billing metrics)
    ├── sales.md (opportunities, pipeline)
    ├── product.md (API usage, features)
    └── marketing.md (campaigns, attribution)
```

````markdown SKILL.md theme={null}
# BigQuery Data Analysis

## Available datasets

**Finance**: Revenue, ARR, billing → See [reference/finance.md](reference/finance.md)
**Sales**: Opportunities, pipeline, accounts → See [reference/sales.md](reference/sales.md)
**Product**: API usage, features, adoption → See [reference/product.md](reference/product.md)
**Marketing**: Campaigns, attribution, email → See [reference/marketing.md](reference/marketing.md)

## Quick search

Find specific metrics using grep:

```bash
grep -i "revenue" reference/finance.md
grep -i "pipeline" reference/sales.md
grep -i "api usage" reference/product.md
```
````

#### 模式 3：Conditional details

展示基础内容，链接到高级内容：

```markdown  theme={null}
# DOCX Processing

## Creating documents

Use docx-js for new documents. See [DOCX-JS.md](DOCX-JS.md).

## Editing documents

For simple edits, modify the XML directly.

**For tracked changes**: See [REDLINING.md](REDLINING.md)
**For OOXML details**: See [OOXML.md](OOXML.md)
```

Claude 只在用户需要这些功能时读取 REDLINING.md 或 OOXML.md。

### 避免深层嵌套 references

当文件从其他 referenced files 中被引用时，Claude 可能会部分读取文件。遇到 nested references 时，Claude 可能会用 `head -100` 等命令预览内容，而不是读取完整文件，导致信息不完整。

**让 references 距 SKILL.md 只深一层**。所有 reference files 都应该直接从 SKILL.md 链接，以确保 Claude 在需要时读取完整文件。

**坏例子：太深**：

```markdown  theme={null}
# SKILL.md
See [advanced.md](advanced.md)...

# advanced.md
See [details.md](details.md)...

# details.md
Here's the actual information...
```

**好例子：一层深**：

```markdown  theme={null}
# SKILL.md

**Basic usage**: [instructions in SKILL.md]
**Advanced features**: See [advanced.md](advanced.md)
**API reference**: See [reference.md](reference.md)
**Examples**: See [examples.md](examples.md)
```

### 为较长 reference files 添加目录

对于超过 100 行的 reference files，在顶部包含 table of contents。这确保 Claude 即使用 partial reads 预览，也能看到可用信息的完整范围。

**示例**：

```markdown  theme={null}
# API Reference

## Contents
- Authentication and setup
- Core methods (create, read, update, delete)
- Advanced features (batch operations, webhooks)
- Error handling patterns
- Code examples

## Authentication and setup
...

## Core methods
...
```

Claude 随后可以读取完整文件或跳到特定章节。

关于这种 filesystem-based architecture 如何支持 progressive disclosure 的细节，见下方 Advanced 章节中的 [Runtime environment](#runtime-environment)。

## Workflows and feedback loops

### 为复杂任务使用 workflows

将复杂操作拆成清晰的顺序步骤。对于特别复杂的 workflows，提供 Claude 可以复制到响应中并在进展中勾选的 checklist。

**示例 1：Research synthesis workflow**（用于没有代码的 Skills）：

````markdown  theme={null}
## Research synthesis workflow

Copy this checklist and track your progress:

```
Research Progress:
- [ ] Step 1: Read all source documents
- [ ] Step 2: Identify key themes
- [ ] Step 3: Cross-reference claims
- [ ] Step 4: Create structured summary
- [ ] Step 5: Verify citations
```

**Step 1: Read all source documents**

Review each document in the `sources/` directory. Note the main arguments and supporting evidence.

**Step 2: Identify key themes**

Look for patterns across sources. What themes appear repeatedly? Where do sources agree or disagree?

**Step 3: Cross-reference claims**

For each major claim, verify it appears in the source material. Note which source supports each point.

**Step 4: Create structured summary**

Organize findings by theme. Include:
- Main claim
- Supporting evidence from sources
- Conflicting viewpoints (if any)

**Step 5: Verify citations**

Check that every claim references the correct source document. If citations are incomplete, return to Step 3.
````

这个示例展示 workflows 如何应用于不需要代码的分析任务。Checklist pattern 适用于任何复杂、多步骤流程。

**示例 2：PDF form filling workflow**（用于带代码的 Skills）：

````markdown  theme={null}
## PDF form filling workflow

Copy this checklist and check off items as you complete them:

```
Task Progress:
- [ ] Step 1: Analyze the form (run analyze_form.py)
- [ ] Step 2: Create field mapping (edit fields.json)
- [ ] Step 3: Validate mapping (run validate_fields.py)
- [ ] Step 4: Fill the form (run fill_form.py)
- [ ] Step 5: Verify output (run verify_output.py)
```

**Step 1: Analyze the form**

Run: `python scripts/analyze_form.py input.pdf`

This extracts form fields and their locations, saving to `fields.json`.

**Step 2: Create field mapping**

Edit `fields.json` to add values for each field.

**Step 3: Validate mapping**

Run: `python scripts/validate_fields.py fields.json`

Fix any validation errors before continuing.

**Step 4: Fill the form**

Run: `python scripts/fill_form.py input.pdf fields.json output.pdf`

**Step 5: Verify output**

Run: `python scripts/verify_output.py output.pdf`

If verification fails, return to Step 2.
````

清晰步骤防止 Claude 跳过关键 validation。Checklist 帮助 Claude 和你跟踪多步骤 workflows 的进展。

### 实现 feedback loops

**常见模式**：运行 validator → 修复 errors → 重复

这个模式显著提高输出质量。

**示例 1：Style guide compliance**（用于没有代码的 Skills）：

```markdown  theme={null}
## Content review process

1. Draft your content following the guidelines in STYLE_GUIDE.md
2. Review against the checklist:
   - Check terminology consistency
   - Verify examples follow the standard format
   - Confirm all required sections are present
3. If issues found:
   - Note each issue with specific section reference
   - Revise the content
   - Review the checklist again
4. Only proceed when all requirements are met
5. Finalize and save the document
```

这展示了使用 reference documents 而不是 scripts 的 validation loop pattern。“validator” 是 STYLE\_GUIDE.md，Claude 通过阅读和比较来执行检查。

**示例 2：Document editing process**（用于带代码的 Skills）：

```markdown  theme={null}
## Document editing process

1. Make your edits to `word/document.xml`
2. **Validate immediately**: `python ooxml/scripts/validate.py unpacked_dir/`
3. If validation fails:
   - Review the error message carefully
   - Fix the issues in the XML
   - Run validation again
4. **Only proceed when validation passes**
5. Rebuild: `python ooxml/scripts/pack.py unpacked_dir/ output.docx`
6. Test the output document
```

Validation loop 及早捕捉 errors。

## 内容指南

### 避免 time-sensitive information

不要包含会过时的信息：

**坏例子：Time-sensitive**（会变错）：

```markdown  theme={null}
If you're doing this before August 2025, use the old API.
After August 2025, use the new API.
```

**好例子**（使用 “old patterns” 章节）：

```markdown  theme={null}
## Current method

Use the v2 API endpoint: `api.example.com/v2/messages`

## Old patterns

<details>
<summary>Legacy v1 API (deprecated 2025-08)</summary>

The v1 API used: `api.example.com/v1/messages`

This endpoint is no longer supported.
</details>
```

Old patterns 章节提供历史上下文，而不污染主内容。

### 使用一致术语

选择一个术语并在整个 Skill 中使用：

**好 - 一致**：

* 始终 “API endpoint”
* 始终 “field”
* 始终 “extract”

**坏 - 不一致**：

* 混用 “API endpoint”、“URL”、“API route”、“path”
* 混用 “field”、“box”、“element”、“control”
* 混用 “extract”、“pull”、“get”、“retrieve”

一致性帮助 Claude 理解并遵循指令。

## 常见模式

### Template pattern

为输出格式提供 templates。让严格程度匹配你的需求。

**用于严格要求**（例如 API responses 或 data formats）：

````markdown  theme={null}
## Report structure

ALWAYS use this exact template structure:

```markdown
# [Analysis Title]

## Executive summary
[One-paragraph overview of key findings]

## Key findings
- Finding 1 with supporting data
- Finding 2 with supporting data
- Finding 3 with supporting data

## Recommendations
1. Specific actionable recommendation
2. Specific actionable recommendation
```
````

**用于灵活指导**（当 adaptation 有用时）：

````markdown  theme={null}
## Report structure

Here is a sensible default format, but use your best judgment based on the analysis:

```markdown
# [Analysis Title]

## Executive summary
[Overview]

## Key findings
[Adapt sections based on what you discover]

## Recommendations
[Tailor to the specific context]
```

Adjust sections as needed for the specific analysis type.
````

### Examples pattern

对于输出质量依赖示例的 Skills，像常规 prompting 一样提供 input/output pairs：

````markdown  theme={null}
## Commit message format

Generate commit messages following these examples:

**Example 1:**
Input: Added user authentication with JWT tokens
Output:
```
feat(auth): implement JWT-based authentication

Add login endpoint and token validation middleware
```

**Example 2:**
Input: Fixed bug where dates displayed incorrectly in reports
Output:
```
fix(reports): correct date formatting in timezone conversion

Use UTC timestamps consistently across report generation
```

**Example 3:**
Input: Updated dependencies and refactored error handling
Output:
```
chore: update dependencies and refactor error handling

- Upgrade lodash to 4.17.21
- Standardize error response format across endpoints
```

Follow this style: type(scope): brief description, then detailed explanation.
````

相比单独描述，示例能更清晰地帮助 Claude 理解期望 style 和 detail level。

### Conditional workflow pattern

引导 Claude 通过决策点：

```markdown  theme={null}
## Document modification workflow

1. Determine the modification type:

   **Creating new content?** → Follow "Creation workflow" below
   **Editing existing content?** → Follow "Editing workflow" below

2. Creation workflow:
   - Use docx-js library
   - Build document from scratch
   - Export to .docx format

3. Editing workflow:
   - Unpack existing document
   - Modify XML directly
   - Validate after each change
   - Repack when complete
```

<Tip>
  如果 workflows 变得很大或步骤很多，考虑将它们推入单独文件，并告诉 Claude 根据当前任务读取适当文件。
</Tip>

## Evaluation and iteration

### 先构建 evaluations

**在编写大量文档之前创建 evaluations。**这确保你的 Skill 解决真实问题，而不是记录想象出来的问题。

**Evaluation-driven development：**

1. **识别 gaps**：在没有 Skill 的情况下让 Claude 处理代表性任务。记录具体失败或缺失上下文
2. **创建 evaluations**：构建三个测试这些 gaps 的场景
3. **建立 baseline**：衡量没有 Skill 时 Claude 的表现
4. **编写最小指令**：创建刚好足以处理 gaps 并通过 evaluations 的内容
5. **迭代**：执行 evaluations，与 baseline 比较，并 refine

这种方法确保你解决的是实际问题，而不是预判可能永远不会出现的需求。

**Evaluation structure**：

```json  theme={null}
{
  "skills": ["pdf-processing"],
  "query": "Extract all text from this PDF file and save it to output.txt",
  "files": ["test-files/document.pdf"],
  "expected_behavior": [
    "Successfully reads the PDF file using an appropriate PDF processing library or command-line tool",
    "Extracts text content from all pages in the document without missing any pages",
    "Saves the extracted text to a file named output.txt in a clear, readable format"
  ]
}
```

<Note>
  这个示例展示了带简单 testing rubric 的 data-driven evaluation。我们目前不提供内置方式运行这些 evaluations。用户可以创建自己的 evaluation system。Evaluations 是衡量 Skill 效果的事实来源。
</Note>

### 与 Claude 迭代开发 Skills

最有效的 Skill development process 涉及 Claude 本身。与一个 Claude 实例（“Claude A”）一起创建供其他实例（“Claude B”）使用的 Skill。Claude A 帮你设计和 refine instructions，而 Claude B 在真实任务中测试它们。这有效是因为 Claude models 同时理解如何编写有效 agent instructions，以及 agents 需要什么信息。

**创建新 Skill：**

1. **不带 Skill 完成任务**：使用正常 prompting 与 Claude A 解决问题。在工作中，你会自然提供上下文、解释偏好、分享 procedural knowledge。注意你反复提供了什么信息。

2. **识别可复用模式**：完成任务后，识别你提供的哪些上下文对类似未来任务有用。

   **示例**：如果你完成了一次 BigQuery analysis，你可能提供了 table names、field definitions、filtering rules（例如 “always exclude test accounts”）和 common query patterns。

3. **让 Claude A 创建 Skill**：“Create a Skill that captures this BigQuery analysis pattern we just used. Include the table schemas, naming conventions, and the rule about filtering test accounts.”

   <Tip>
     Claude models 原生理解 Skill format 和 structure。你不需要特殊 system prompts 或 “writing skills” skill 来让 Claude 帮助创建 Skills。直接请求 Claude 创建 Skill，它会生成结构正确、带适当 frontmatter 和 body content 的 SKILL.md。
   </Tip>

4. **审查简洁性**：检查 Claude A 是否添加了不必要解释。问：“Remove the explanation about what win rate means - Claude already knows that.”

5. **改进 information architecture**：让 Claude A 更有效地组织内容。例如：“Organize this so the table schema is in a separate reference file. We might add more tables later.”

6. **在类似任务上测试**：用 Claude B（新实例，已加载 Skill）在相关用例上使用该 Skill。观察 Claude B 是否找到正确信息、正确应用规则，并成功处理任务。

7. **根据观察迭代**：如果 Claude B 挣扎或遗漏某些东西，带具体情况回到 Claude A：“When Claude used this Skill, it forgot to filter by date for Q4. Should we add a section about date filtering patterns?”

**迭代现有 Skills：**

改进 Skills 时，同样的分层模式继续适用。你在以下两者之间交替：

* **与 Claude A 工作**（帮助 refine Skill 的专家）
* **用 Claude B 测试**（使用 Skill 执行真实工作的 agent）
* **观察 Claude B 的行为**并将洞见带回 Claude A

1. **在真实 workflows 中使用 Skill**：给 Claude B（已加载 Skill）实际任务，而不是测试场景

2. **观察 Claude B 的行为**：记录它在哪里挣扎、成功或做出意外选择

   **示例观察**：“When I asked Claude B for a regional sales report, it wrote the query but forgot to filter out test accounts, even though the Skill mentions this rule.”

3. **回到 Claude A 改进**：分享当前 SKILL.md 并描述你的观察。问：“I noticed Claude B forgot to filter test accounts when I asked for a regional report. The Skill mentions filtering, but maybe it's not prominent enough?”

4. **审查 Claude A 的建议**：Claude A 可能建议重组以让规则更显眼，使用更强语言如 “MUST filter” 而不是 “always filter”，或重构 workflow section。

5. **应用并测试变更**：用 Claude A 的 refinements 更新 Skill，然后用类似请求再次测试 Claude B

6. **基于使用重复**：遇到新场景时继续这个 observe-refine-test cycle。每次迭代都根据真实 agent 行为改进 Skill，而不是根据假设。

**收集团队反馈：**

1. 与 teammates 分享 Skills 并观察他们的使用
2. 询问：Skill 是否在预期时激活？指令是否清楚？缺少什么？
3. 纳入反馈，处理你自己使用模式中的 blind spots

**为什么这种方法有效**：Claude A 理解 agent needs，你提供 domain expertise，Claude B 通过真实使用揭示 gaps，迭代 refinement 基于观察到的行为而非假设改进 Skills。

### 观察 Claude 如何导航 Skills

迭代 Skills 时，注意 Claude 在实践中实际如何使用它们。留意：

* **意外探索路径**：Claude 是否以你未预料的顺序读取文件？这可能表示你的结构不如你想象中直观
* **错过连接**：Claude 是否未跟随到重要文件的 references？你的 links 可能需要更明确或更显眼
* **过度依赖某些章节**：如果 Claude 反复读取同一文件，考虑该内容是否应该放在主 SKILL.md 中
* **被忽略的内容**：如果 Claude 从未访问 bundled file，它可能不必要或在主指令中提示不足

基于这些观察迭代，而不是基于假设。Skill metadata 中的 `name` 和 `description` 尤其关键。Claude 在决定是否响应当前任务触发 Skill 时会使用它们。确保它们清楚描述 Skill 做什么以及何时应该使用。

## 要避免的反模式

### 避免 Windows-style paths

始终在文件路径中使用 forward slashes，即使在 Windows 上：

* ✓ **Good**：`scripts/helper.py`、`reference/guide.md`
* ✗ **Avoid**：`scripts\helper.py`、`reference\guide.md`

Unix-style paths 可跨所有平台工作，而 Windows-style paths 会在 Unix 系统上造成错误。

### 避免提供过多选项

除非必要，不要呈现多种方法：

````markdown  theme={null}
**Bad example: Too many choices** (confusing):
"You can use pypdf, or pdfplumber, or PyMuPDF, or pdf2image, or..."

**Good example: Provide a default** (with escape hatch):
"Use pdfplumber for text extraction:
```python
import pdfplumber
```

For scanned PDFs requiring OCR, use pdf2image with pytesseract instead."
````

## Advanced：带 executable code 的 Skills

以下章节聚焦包含 executable scripts 的 Skills。如果你的 Skill 只使用 markdown instructions，跳到 [Checklist for effective Skills](#checklist-for-effective-skills)。

### 解决，不要推给 Claude

为 Skills 编写 scripts 时，处理 error conditions，而不是推给 Claude。

**好例子：明确处理 errors**：

```python  theme={null}
def process_file(path):
    """Process a file, creating it if it doesn't exist."""
    try:
        with open(path) as f:
            return f.read()
    except FileNotFoundError:
        # Create file with default content instead of failing
        print(f"File {path} not found, creating default")
        with open(path, 'w') as f:
            f.write('')
        return ''
    except PermissionError:
        # Provide alternative instead of failing
        print(f"Cannot access {path}, using default")
        return ''
```

**坏例子：推给 Claude**：

```python  theme={null}
def process_file(path):
    # Just fail and let Claude figure it out
    return open(path).read()
```

Configuration parameters 也应该被说明理由并文档化，以避免 “voodoo constants”（Ousterhout's law）。如果你不知道正确值，Claude 要如何确定它？

**好例子：Self-documenting**：

```python  theme={null}
# HTTP requests typically complete within 30 seconds
# Longer timeout accounts for slow connections
REQUEST_TIMEOUT = 30

# Three retries balances reliability vs speed
# Most intermittent failures resolve by the second retry
MAX_RETRIES = 3
```

**坏例子：Magic numbers**：

```python  theme={null}
TIMEOUT = 47  # Why 47?
RETRIES = 5   # Why 5?
```

### 提供 utility scripts

即使 Claude 可以写 script，预制 scripts 也有优势：

**Utility scripts 的收益**：

* 比生成代码更可靠
* 节省 tokens（无需在 context 中包含代码）
* 节省时间（不需要代码生成）
* 确保跨使用的一致性

<img src="https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-executable-scripts.png?fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=4bbc45f2c2e0bee9f2f0d5da669bad00" alt="Bundling executable scripts alongside instruction files" data-og-width="2048" width="2048" data-og-height="1154" height="1154" data-path="images/agent-skills-executable-scripts.png" data-optimize="true" data-opv="3" srcset="https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-executable-scripts.png?w=280&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=9a04e6535a8467bfeea492e517de389f 280w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-executable-scripts.png?w=560&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=e49333ad90141af17c0d7651cca7216b 560w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-executable-scripts.png?w=840&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=954265a5df52223d6572b6214168c428 840w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-executable-scripts.png?w=1100&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=2ff7a2d8f2a83ee8af132b29f10150fd 1100w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-executable-scripts.png?w=1650&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=48ab96245e04077f4d15e9170e081cfb 1650w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-executable-scripts.png?w=2500&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=0301a6c8b3ee879497cc5b5483177c90 2500w" />

上图显示 executable scripts 如何与 instruction files 一起工作。Instruction file（forms.md）引用 script，Claude 可以执行它，而无需将其内容加载进 context。

**重要区别**：在你的指令中清楚说明 Claude 应该：

* **执行 script**（最常见）：“Run `analyze_form.py` to extract fields”
* **作为 reference 阅读它**（用于复杂逻辑）：“See `analyze_form.py` for the field extraction algorithm”

对于大多数 utility scripts，执行是首选，因为它更可靠高效。关于 script execution 如何工作的细节，见下方 [Runtime environment](#runtime-environment) 章节。

**示例**：

````markdown  theme={null}
## Utility scripts

**analyze_form.py**: Extract all form fields from PDF

```bash
python scripts/analyze_form.py input.pdf > fields.json
```

Output format:
```json
{
  "field_name": {"type": "text", "x": 100, "y": 200},
  "signature": {"type": "sig", "x": 150, "y": 500}
}
```

**validate_boxes.py**: Check for overlapping bounding boxes

```bash
python scripts/validate_boxes.py fields.json
# Returns: "OK" or lists conflicts
```

**fill_form.py**: Apply field values to PDF

```bash
python scripts/fill_form.py input.pdf fields.json output.pdf
```
````

### 使用 visual analysis

当 inputs 可以渲染为 images 时，让 Claude 分析它们：

````markdown  theme={null}
## Form layout analysis

1. Convert PDF to images:
   ```bash
   python scripts/pdf_to_images.py form.pdf
   ```

2. Analyze each page image to identify form fields
3. Claude can see field locations and types visually
````

<Note>
  在这个示例中，你需要编写 `pdf_to_images.py` script。
</Note>

Claude 的 vision capabilities 有助于理解 layouts 和 structures。

### 创建可验证的中间输出

当 Claude 执行复杂、开放式任务时，可能会犯错。“plan-validate-execute” pattern 通过让 Claude 先以结构化格式创建 plan，然后在执行前用 script 验证该 plan，从而及早捕捉 errors。

**示例**：想象让 Claude 根据 spreadsheet 更新 PDF 中 50 个 form fields。没有 validation 时，Claude 可能引用不存在的 fields、创建冲突值、遗漏 required fields，或错误应用 updates。

**解决方案**：使用上面展示的 workflow pattern（PDF form filling），但添加一个在应用 changes 前验证的中间 `changes.json` 文件。Workflow 变为：analyze → **create plan file** → **validate plan** → execute → verify。

**为什么这个 pattern 有效：**

* **及早捕捉 errors**：Validation 在 changes 应用前发现问题
* **Machine-verifiable**：Scripts 提供客观验证
* **Reversible planning**：Claude 可以在不触碰 originals 的情况下迭代 plan
* **清晰 debugging**：Error messages 指向具体问题

**何时使用**：Batch operations、destructive changes、complex validation rules、high-stakes operations。

**实现提示**：让 validation scripts 输出 verbose 且具体的 error messages，例如 “Field 'signature\_date' not found. Available fields: customer\_name, order\_total, signature\_date\_signed”，以帮助 Claude 修复问题。

### Package dependencies

Skills 在 code execution environment 中运行，带有 platform-specific limitations：

* **claude.ai**：可以从 npm 和 PyPI 安装 packages，并从 GitHub repositories 拉取
* **Anthropic API**：没有 network access，也没有 runtime package installation

在你的 SKILL.md 中列出 required packages，并验证它们在 [code execution tool documentation](/en/docs/agents-and-tools/tool-use/code-execution-tool) 中可用。

### Runtime environment

Skills 运行在具有 filesystem access、bash commands 和 code execution capabilities 的 code execution environment 中。关于该架构的概念解释，见 overview 中的 [The Skills architecture](/en/docs/agents-and-tools/agent-skills/overview#the-skills-architecture)。

**这如何影响 authoring：**

**Claude 如何访问 Skills：**

1. **Metadata pre-loaded**：启动时，所有 Skills YAML frontmatter 中的 name 和 description 被加载进 system prompt
2. **Files read on-demand**：需要时，Claude 使用 bash Read tools 从 filesystem 访问 SKILL.md 和其他文件
3. **Scripts executed efficiently**：Utility scripts 可以通过 bash 执行，而无需将完整内容加载进 context。只有 script output 消耗 tokens
4. **No context penalty for large files**：Reference files、data 或 documentation 在实际读取前不消耗 context tokens

* **File paths matter**：Claude 像 filesystem 一样导航你的 skill directory。使用 forward slashes（`reference/guide.md`），不要用 backslashes
* **Name files descriptively**：使用表示内容的名称：`form_validation_rules.md`，而不是 `doc2.md`
* **Organize for discovery**：按 domain 或 feature 组织目录
  * Good：`reference/finance.md`、`reference/sales.md`
  * Bad：`docs/file1.md`、`docs/file2.md`
* **Bundle comprehensive resources**：包含完整 API docs、大量 examples、大 datasets；访问前没有 context penalty
* **Prefer scripts for deterministic operations**：编写 `validate_form.py`，而不是要求 Claude 生成 validation code
* **Make execution intent clear**：
  * “Run `analyze_form.py` to extract fields”（execute）
  * “See `analyze_form.py` for the extraction algorithm”（read as reference）
* **Test file access patterns**：用真实请求验证 Claude 能导航你的目录结构

**示例：**

```
bigquery-skill/
├── SKILL.md (overview, points to reference files)
└── reference/
    ├── finance.md (revenue metrics)
    ├── sales.md (pipeline data)
    └── product.md (usage analytics)
```

当用户询问 revenue，Claude 读取 SKILL.md，看到对 `reference/finance.md` 的引用，并调用 bash 只读取该文件。sales.md 和 product.md 文件留在 filesystem 上，在需要前消耗零 context tokens。这个 filesystem-based model 支持 progressive disclosure。Claude 可以导航并选择性加载每个任务确切需要的内容。

完整技术架构细节见 Skills overview 中的 [How Skills work](/en/docs/agents-and-tools/agent-skills/overview#how-skills-work)。

### MCP tool references

如果你的 Skill 使用 MCP（Model Context Protocol）tools，始终使用 fully qualified tool names 以避免 “tool not found” errors。

**格式**：`ServerName:tool_name`

**示例**：

```markdown  theme={null}
Use the BigQuery:bigquery_schema tool to retrieve table schemas.
Use the GitHub:create_issue tool to create issues.
```

其中：

* `BigQuery` 和 `GitHub` 是 MCP server names
* `bigquery_schema` 和 `create_issue` 是这些 servers 中的 tool names

如果没有 server prefix，Claude 可能无法定位 tool，尤其在有多个 MCP servers 可用时。

### 避免假设 tools 已安装

不要假设 packages 可用：

````markdown  theme={null}
**Bad example: Assumes installation**:
"Use the pdf library to process the file."

**Good example: Explicit about dependencies**:
"Install required package: `pip install pypdf`

Then use it:
```python
from pypdf import PdfReader
reader = PdfReader("file.pdf")
```"
````

## 技术注记

### YAML frontmatter requirements

SKILL.md frontmatter 需要 `name`（最多 64 字符）和 `description`（最多 1024 字符）字段。完整结构细节见 [Skills overview](/en/docs/agents-and-tools/agent-skills/overview#skill-structure)。

### Token budgets

为获得最佳性能，将 SKILL.md body 保持在 500 行以内。如果你的内容超过此范围，使用前面描述的 progressive disclosure patterns 将其拆到单独文件。架构细节见 [Skills overview](/en/docs/agents-and-tools/agent-skills/overview#how-skills-work)。

## 有效 Skills 检查清单

分享 Skill 前，验证：

### 核心质量

* [ ] Description 具体且包含 key terms
* [ ] Description 同时包含 Skill 做什么和何时使用
* [ ] SKILL.md body 少于 500 行
* [ ] 额外细节位于单独文件中（如需要）
* [ ] 没有 time-sensitive information（或位于 “old patterns” 章节）
* [ ] 全文术语一致
* [ ] 示例具体，不抽象
* [ ] File references 只有一层深
* [ ] 适当使用 progressive disclosure
* [ ] Workflows 有清晰步骤

### Code and scripts

* [ ] Scripts 解决问题，而不是推给 Claude
* [ ] Error handling 明确且有帮助
* [ ] 没有 “voodoo constants”（所有值都有理由）
* [ ] Required packages 在指令中列出并验证可用
* [ ] Scripts 有清晰文档
* [ ] 没有 Windows-style paths（全部 forward slashes）
* [ ] 关键操作有 validation/verification steps
* [ ] Quality-critical tasks 包含 feedback loops

### Testing

* [ ] 创建至少三个 evaluations
* [ ] 用 Haiku、Sonnet 和 Opus 测试
* [ ] 用真实使用场景测试
* [ ] 纳入团队反馈（如适用）

## 下一步

<CardGroup cols={2}>
  <Card title="Get started with Agent Skills" icon="rocket" href="/en/docs/agents-and-tools/agent-skills/quickstart">
    创建你的第一个 Skill
  </Card>

  <Card title="Use Skills in Claude Code" icon="terminal" href="/en/docs/claude-code/skills">
    在 Claude Code 中创建和管理 Skills
  </Card>

  <Card title="Use Skills with the API" icon="code" href="/en/api/skills-guide">
    以编程方式上传和使用 Skills
  </Card>
</CardGroup>
