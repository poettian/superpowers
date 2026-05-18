#!/usr/bin/env bash
# 停止 brainstorm server 并清理
# 用法：stop-server.sh <session_dir>
#
# 杀掉 server process。只有当 session directory 位于 /tmp 下时才删除它
# （ephemeral）。持久目录（.superpowers/）会保留，
# 这样 mockups 之后仍可审查。

SESSION_DIR="$1"

if [[ -z "$SESSION_DIR" ]]; then
  echo '{"error": "Usage: stop-server.sh <session_dir>"}'
  exit 1
fi

STATE_DIR="${SESSION_DIR}/state"
PID_FILE="${STATE_DIR}/server.pid"

if [[ -f "$PID_FILE" ]]; then
  pid=$(cat "$PID_FILE")

  # 尝试 graceful stop，如果仍 alive 则 fallback 到 force
  kill "$pid" 2>/dev/null || true

  # 等待 graceful shutdown（最多约 2s）
  for i in {1..20}; do
    if ! kill -0 "$pid" 2>/dev/null; then
      break
    fi
    sleep 0.1
  done

  # 如果仍在运行，升级到 SIGKILL
  if kill -0 "$pid" 2>/dev/null; then
    kill -9 "$pid" 2>/dev/null || true

    # 给 SIGKILL 一点时间生效
    sleep 0.1
  fi

  if kill -0 "$pid" 2>/dev/null; then
    echo '{"status": "failed", "error": "process still running"}'
    exit 1
  fi

  rm -f "$PID_FILE" "${STATE_DIR}/server.log"

  # 只删除 ephemeral /tmp directories
  if [[ "$SESSION_DIR" == /tmp/* ]]; then
    rm -rf "$SESSION_DIR"
  fi

  echo '{"status": "stopped"}'
else
  echo '{"status": "not_running"}'
fi
