// 基于条件的等待工具的完整实现
// 来源：Lace test infrastructure improvements (2025-10-03)
// 上下文：通过替换任意 timeouts 修复了 15 个 flaky tests

import type { ThreadManager } from '~/threads/thread-manager';
import type { LaceEvent, LaceEventType } from '~/threads/types';

/**
 * 等待特定 event type 出现在 thread 中
 *
 * @param threadManager - 要查询的 thread manager
 * @param threadId - 要检查 events 的 thread
 * @param eventType - 要等待的 event 类型
 * @param timeoutMs - 最大等待时间（默认 5000ms）
 * @returns Promise resolving to the first matching event
 *
 * Example:
 *   await waitForEvent(threadManager, agentThreadId, 'TOOL_RESULT');
 */
export function waitForEvent(
  threadManager: ThreadManager,
  threadId: string,
  eventType: LaceEventType,
  timeoutMs = 5000
): Promise<LaceEvent> {
  return new Promise((resolve, reject) => {
    const startTime = Date.now();

    const check = () => {
      const events = threadManager.getEvents(threadId);
      const event = events.find((e) => e.type === eventType);

      if (event) {
        resolve(event);
      } else if (Date.now() - startTime > timeoutMs) {
        reject(new Error(`Timeout waiting for ${eventType} event after ${timeoutMs}ms`));
      } else {
        setTimeout(check, 10); // 每 10ms poll 一次以提高效率
      }
    };

    check();
  });
}

/**
 * 等待给定类型的特定数量 events
 *
 * @param threadManager - 要查询的 thread manager
 * @param threadId - 要检查 events 的 thread
 * @param eventType - 要等待的 event 类型
 * @param count - 要等待的 events 数量
 * @param timeoutMs - 最大等待时间（默认 5000ms）
 * @returns Promise resolving to all matching events once count is reached
 *
 * Example:
 *   // 等待 2 个 AGENT_MESSAGE events（initial response + continuation）
 *   await waitForEventCount(threadManager, agentThreadId, 'AGENT_MESSAGE', 2);
 */
export function waitForEventCount(
  threadManager: ThreadManager,
  threadId: string,
  eventType: LaceEventType,
  count: number,
  timeoutMs = 5000
): Promise<LaceEvent[]> {
  return new Promise((resolve, reject) => {
    const startTime = Date.now();

    const check = () => {
      const events = threadManager.getEvents(threadId);
      const matchingEvents = events.filter((e) => e.type === eventType);

      if (matchingEvents.length >= count) {
        resolve(matchingEvents);
      } else if (Date.now() - startTime > timeoutMs) {
        reject(
          new Error(
            `Timeout waiting for ${count} ${eventType} events after ${timeoutMs}ms (got ${matchingEvents.length})`
          )
        );
      } else {
        setTimeout(check, 10);
      }
    };

    check();
  });
}

/**
 * 等待匹配自定义 predicate 的 event
 * 当你需要检查 event data，而不只是 type 时很有用
 *
 * @param threadManager - 要查询的 thread manager
 * @param threadId - 要检查 events 的 thread
 * @param predicate - 当 event 匹配时返回 true 的函数
 * @param description - 用于错误消息的人类可读描述
 * @param timeoutMs - 最大等待时间（默认 5000ms）
 * @returns Promise resolving to the first matching event
 *
 * Example:
 *   // 等待带有特定 ID 的 TOOL_RESULT
 *   await waitForEventMatch(
 *     threadManager,
 *     agentThreadId,
 *     (e) => e.type === 'TOOL_RESULT' && e.data.id === 'call_123',
 *     'TOOL_RESULT with id=call_123'
 *   );
 */
export function waitForEventMatch(
  threadManager: ThreadManager,
  threadId: string,
  predicate: (event: LaceEvent) => boolean,
  description: string,
  timeoutMs = 5000
): Promise<LaceEvent> {
  return new Promise((resolve, reject) => {
    const startTime = Date.now();

    const check = () => {
      const events = threadManager.getEvents(threadId);
      const event = events.find(predicate);

      if (event) {
        resolve(event);
      } else if (Date.now() - startTime > timeoutMs) {
        reject(new Error(`Timeout waiting for ${description} after ${timeoutMs}ms`));
      } else {
        setTimeout(check, 10);
      }
    };

    check();
  });
}

// 来自实际调试会话的使用示例：
//
// BEFORE (flaky):
// ---------------
// const messagePromise = agent.sendMessage('Execute tools');
// await new Promise(r => setTimeout(r, 300)); // 希望 tools 在 300ms 内启动
// agent.abort();
// await messagePromise;
// await new Promise(r => setTimeout(r, 50));  // 希望 results 在 50ms 内到达
// expect(toolResults.length).toBe(2);         // 随机失败
//
// AFTER (reliable):
// ----------------
// const messagePromise = agent.sendMessage('Execute tools');
// await waitForEventCount(threadManager, threadId, 'TOOL_CALL', 2); // 等待 tools 启动
// agent.abort();
// await messagePromise;
// await waitForEventCount(threadManager, threadId, 'TOOL_RESULT', 2); // 等待 results
// expect(toolResults.length).toBe(2); // 始终成功
//
// 结果：60% pass rate → 100%，执行速度快 40%
