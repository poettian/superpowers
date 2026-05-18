# Defense-in-Depth 验证

## 概述

当你修复由无效数据导致的 bug 时，在一个地方添加验证会感觉足够。但这个单一检查可能被不同代码路径、重构或 mocks 绕过。

**核心原则：**在数据经过的每一层验证。让 bug 在结构上不可能发生。

## 为什么需要多层

单一验证：“We fixed the bug”
多层验证：“We made the bug impossible”

不同层捕捉不同情况：
- 入口验证捕捉大多数 bug
- 业务逻辑捕捉边界情况
- 环境 guard 防止特定上下文危险
- Debug logging 在其他层失败时提供帮助

## 四层

### 第 1 层：入口点验证
**目的：**在 API 边界拒绝明显无效输入

```typescript
function createProject(name: string, workingDirectory: string) {
  if (!workingDirectory || workingDirectory.trim() === '') {
    throw new Error('workingDirectory cannot be empty');
  }
  if (!existsSync(workingDirectory)) {
    throw new Error(`workingDirectory does not exist: ${workingDirectory}`);
  }
  if (!statSync(workingDirectory).isDirectory()) {
    throw new Error(`workingDirectory is not a directory: ${workingDirectory}`);
  }
  // ... proceed
}
```

### 第 2 层：业务逻辑验证
**目的：**确保数据对这个操作有意义

```typescript
function initializeWorkspace(projectDir: string, sessionId: string) {
  if (!projectDir) {
    throw new Error('projectDir required for workspace initialization');
  }
  // ... proceed
}
```

### 第 3 层：环境 Guards
**目的：**在特定上下文中防止危险操作

```typescript
async function gitInit(directory: string) {
  // In tests, refuse git init outside temp directories
  if (process.env.NODE_ENV === 'test') {
    const normalized = normalize(resolve(directory));
    const tmpDir = normalize(resolve(tmpdir()));

    if (!normalized.startsWith(tmpDir)) {
      throw new Error(
        `Refusing git init outside temp dir during tests: ${directory}`
      );
    }
  }
  // ... proceed
}
```

### 第 4 层：Debug Instrumentation
**目的：**捕捉取证上下文

```typescript
async function gitInit(directory: string) {
  const stack = new Error().stack;
  logger.debug('About to git init', {
    directory,
    cwd: process.cwd(),
    stack,
  });
  // ... proceed
}
```

## 应用该模式

当你发现 bug：

1. **追踪数据流** - 坏值从哪里来？在哪里使用？
2. **映射所有检查点** - 列出数据经过的每个点
3. **在每一层添加验证** - 入口、业务、环境、debug
4. **测试每一层** - 尝试绕过第 1 层，验证第 2 层捕捉它

## 会话示例

Bug：空 `projectDir` 导致在源代码中运行 `git init`

**数据流：**
1. Test setup → empty string
2. `Project.create(name, '')`
3. `WorkspaceManager.createWorkspace('')`
4. `git init` runs in `process.cwd()`

**添加的四层：**
- 第 1 层：`Project.create()` 验证非空/存在/可写
- 第 2 层：`WorkspaceManager` 验证 projectDir 非空
- 第 3 层：`WorktreeManager` 在测试中拒绝在 tmpdir 外 git init
- 第 4 层：git init 前 stack trace logging

**结果：**所有 1847 个测试通过，bug 不可能复现

## 关键洞见

四层全都必要。在测试期间，每一层都捕捉了其他层漏掉的 bug：
- 不同代码路径绕过入口验证
- Mocks 绕过业务逻辑检查
- 不同平台上的边界情况需要环境 guards
- Debug logging 识别结构性误用

**不要停在一个验证点。**在每一层添加检查。
