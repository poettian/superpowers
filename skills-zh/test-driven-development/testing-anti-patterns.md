# 测试反模式

**在以下情况加载此参考：**编写或修改测试、添加 mocks，或想向生产代码添加 test-only 方法时。

## 概述

测试必须验证真实行为，而不是 mock 行为。Mocks 是隔离的手段，不是被测试的东西。

**核心原则：**测试代码做什么，而不是 mocks 做什么。

**严格遵循 TDD 可防止这些反模式。**

## 铁律

```
1. 绝不要测试 mock 行为
2. 绝不要向生产类添加 test-only 方法
3. 绝不要在不理解依赖的情况下 mock
```

## 反模式 1：测试 Mock 行为

**违规：**
```typescript
// ❌ BAD: Testing that the mock exists
test('renders sidebar', () => {
  render(<Page />);
  expect(screen.getByTestId('sidebar-mock')).toBeInTheDocument();
});
```

**为什么这是错的：**
- 你在验证 mock 有效，而不是组件有效
- 当 mock 存在时测试通过，不存在时失败
- 没有告诉你任何关于真实行为的信息

**你的人类伙伴的纠正：**“Are we testing the behavior of a mock?”

**修复：**
```typescript
// ✅ GOOD: Test real component or don't mock it
test('renders sidebar', () => {
  render(<Page />);  // Don't mock sidebar
  expect(screen.getByRole('navigation')).toBeInTheDocument();
});

// OR if sidebar must be mocked for isolation:
// Don't assert on the mock - test Page's behavior with sidebar present
```

### 门函数

```
在断言任何 mock 元素之前：
  问：“Am I testing real component behavior or just mock existence?”

  如果在测试 mock 存在：
    停止 - 删除断言或取消 mock 该组件

  改为测试真实行为
```

## 反模式 2：生产代码中的 Test-Only 方法

**违规：**
```typescript
// ❌ BAD: destroy() only used in tests
class Session {
  async destroy() {  // Looks like production API!
    await this._workspaceManager?.destroyWorkspace(this.id);
    // ... cleanup
  }
}

// In tests
afterEach(() => session.destroy());
```

**为什么这是错的：**
- 生产类被 test-only 代码污染
- 如果在生产中意外调用，很危险
- 违反 YAGNI 和关注点分离
- 混淆对象生命周期和实体生命周期

**修复：**
```typescript
// ✅ GOOD: Test utilities handle test cleanup
// Session has no destroy() - it's stateless in production

// In test-utils/
export async function cleanupSession(session: Session) {
  const workspace = session.getWorkspaceInfo();
  if (workspace) {
    await workspaceManager.destroyWorkspace(workspace.id);
  }
}

// In tests
afterEach(() => cleanupSession(session));
```

### 门函数

```
在向生产类添加任何方法之前：
  问：“Is this only used by tests?”

  如果是：
    停止 - 不要添加
    改放进 test utilities

  问：“Does this class own this resource's lifecycle?”

  如果否：
    停止 - 这个方法属于错误的类
```

## 反模式 3：不理解就 Mock

**违规：**
```typescript
// ❌ BAD: Mock breaks test logic
test('detects duplicate server', () => {
  // Mock prevents config write that test depends on!
  vi.mock('ToolCatalog', () => ({
    discoverAndCacheTools: vi.fn().mockResolvedValue(undefined)
  }));

  await addServer(config);
  await addServer(config);  // Should throw - but won't!
});
```

**为什么这是错的：**
- 被 mock 的方法有测试依赖的副作用（写 config）
- 为了“安全”过度 mock 会破坏实际行为
- 测试因错误原因通过，或神秘失败

**修复：**
```typescript
// ✅ GOOD: Mock at correct level
test('detects duplicate server', () => {
  // Mock the slow part, preserve behavior test needs
  vi.mock('MCPServerManager'); // Just mock slow server startup

  await addServer(config);  // Config written
  await addServer(config);  // Duplicate detected ✓
});
```

### 门函数

```
在 mock 任何方法之前：
  停止 - 先不要 mock

  1. 问：“真实方法有什么副作用？”
  2. 问：“这个测试是否依赖这些副作用中的任何一个？”
  3. 问：“我是否完全理解这个测试需要什么？”

  如果依赖副作用：
    在更低层级 mock（实际慢/外部操作）
    或使用保留必要行为的 test doubles
    不要 mock 测试所依赖的高层方法

  如果不确定测试依赖什么：
    先用真实实现运行测试
    观察实际需要发生什么
    然后在正确层级添加最小 mock

  红旗：
    - “I'll mock this to be safe”
    - “This might be slow, better mock it”
    - 不理解依赖链就 mock
```

## 反模式 4：不完整 Mocks

**违规：**
```typescript
// ❌ BAD: Partial mock - only fields you think you need
const mockResponse = {
  status: 'success',
  data: { userId: '123', name: 'Alice' }
  // Missing: metadata that downstream code uses
};

// Later: breaks when code accesses response.metadata.requestId
```

**为什么这是错的：**
- **局部 mocks 隐藏结构假设** - 你只 mock 了你知道的字段
- **下游代码可能依赖你没有包含的字段** - 静默失败
- **测试通过但集成失败** - Mock 不完整，真实 API 完整
- **虚假信心** - 测试无法证明真实行为

**铁律：**Mock 现实中存在的完整数据结构，而不是只 mock 你的直接测试使用的字段。

**修复：**
```typescript
// ✅ GOOD: Mirror real API completeness
const mockResponse = {
  status: 'success',
  data: { userId: '123', name: 'Alice' },
  metadata: { requestId: 'req-789', timestamp: 1234567890 }
  // All fields real API returns
};
```

### 门函数

```
在创建 mock responses 之前：
  检查：“真实 API response 包含哪些字段？”

  行动：
    1. 从 docs/examples 检查实际 API response
    2. 包含系统下游可能消费的所有字段
    3. 验证 mock 与真实 response schema 完全匹配

  关键：
    如果你在创建 mock，就必须理解整个结构
    当代码依赖被省略字段时，局部 mocks 会静默失败

  如果不确定：包含所有已文档化字段
```

## 反模式 5：把集成测试当事后补充

**违规：**
```
✅ Implementation complete
❌ No tests written
"Ready for testing"
```

**为什么这是错的：**
- 测试是实现的一部分，不是可选后续
- TDD 本会捕捉这一点
- 没有测试就不能声称完成

**修复：**
```
TDD cycle:
1. Write failing test
2. Implement to pass
3. Refactor
4. THEN claim complete
```

## 当 Mocks 变得太复杂

**警告信号：**
- Mock setup 比测试逻辑更长
- 为了让测试通过而 mock 一切
- Mocks 缺少真实组件拥有的方法
- Mock 变化时测试破坏

**你的人类伙伴的问题：**“Do we need to be using a mock here?”

**考虑：**使用真实组件的集成测试通常比复杂 mocks 更简单

## TDD 防止这些反模式

**为什么 TDD 有帮助：**
1. **先写测试** → 强制你思考你实际在测试什么
2. **看它失败** → 确认测试的是真实行为，而不是 mocks
3. **最小实现** → 不会混入 test-only 方法
4. **真实依赖** → 你会在 mock 前看到测试实际需要什么

**如果你在测试 mock 行为，你就违反了 TDD** - 你没有先看着测试针对真实代码失败，就添加了 mocks。

## 快速参考

| 反模式 | 修复 |
|--------------|-----|
| 对 mock 元素断言 | 测试真实组件或取消 mock |
| 生产代码中的 test-only 方法 | 移到 test utilities |
| 不理解就 mock | 先理解依赖，最小 mock |
| 不完整 mocks | 完整镜像真实 API |
| 测试作为事后补充 | TDD - 测试先行 |
| 过度复杂 mocks | 考虑集成测试 |

## 红旗

- 断言检查 `*-mock` test IDs
- 只在测试文件中调用的方法
- Mock setup 占测试的 >50%
- 移除 mock 时测试失败
- 无法解释为什么需要 mock
- “为了安全”而 mock

## 底线

**Mocks 是隔离工具，不是要测试的东西。**

如果 TDD 显示你在测试 mock 行为，那就走错了。

修复：测试真实行为，或质疑你到底为什么在 mock。
