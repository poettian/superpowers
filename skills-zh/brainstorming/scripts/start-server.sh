#!/usr/bin/env bash
# 启动 brainstorm server 并输出连接信息
# 用法：start-server.sh [--project-dir <path>] [--host <bind-host>] [--url-host <display-host>] [--foreground] [--background]
#
# 在随机 high port 上启动服务器，输出带 URL 的 JSON。
# 每个 session 都有自己的目录以避免冲突。
#
# 选项：
#   --project-dir <path>  将 session 文件存储在 <path>/.superpowers/brainstorm/
#                         而不是 /tmp。服务器停止后文件仍保留。
#   --host <bind-host>    要绑定的 host/interface（默认：127.0.0.1）。
#                         在远程/容器化环境中使用 0.0.0.0。
#   --url-host <host>     返回 URL JSON 中显示的 hostname。
#   --foreground          在当前终端运行服务器（不放到后台）。
#   --background          强制后台模式（覆盖 Codex auto-foreground）。

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# 解析参数
PROJECT_DIR=""
FOREGROUND="false"
FORCE_BACKGROUND="false"
BIND_HOST="127.0.0.1"
URL_HOST=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --project-dir)
      PROJECT_DIR="$2"
      shift 2
      ;;
    --host)
      BIND_HOST="$2"
      shift 2
      ;;
    --url-host)
      URL_HOST="$2"
      shift 2
      ;;
    --foreground|--no-daemon)
      FOREGROUND="true"
      shift
      ;;
    --background|--daemon)
      FORCE_BACKGROUND="true"
      shift
      ;;
    *)
      echo "{\"error\": \"Unknown argument: $1\"}"
      exit 1
      ;;
  esac
done

if [[ -z "$URL_HOST" ]]; then
  if [[ "$BIND_HOST" == "127.0.0.1" || "$BIND_HOST" == "localhost" ]]; then
    URL_HOST="localhost"
  else
    URL_HOST="$BIND_HOST"
  fi
fi

# 一些环境会收割 detached/background processes。检测到时自动 foreground。
if [[ -n "${CODEX_CI:-}" && "$FOREGROUND" != "true" && "$FORCE_BACKGROUND" != "true" ]]; then
  FOREGROUND="true"
fi

# Windows/Git Bash 会收割 nohup background processes。检测到时自动 foreground。
if [[ "$FOREGROUND" != "true" && "$FORCE_BACKGROUND" != "true" ]]; then
  case "${OSTYPE:-}" in
    msys*|cygwin*|mingw*) FOREGROUND="true" ;;
  esac
  if [[ -n "${MSYSTEM:-}" ]]; then
    FOREGROUND="true"
  fi
fi

# 生成唯一 session directory
SESSION_ID="$$-$(date +%s)"

if [[ -n "$PROJECT_DIR" ]]; then
  SESSION_DIR="${PROJECT_DIR}/.superpowers/brainstorm/${SESSION_ID}"
else
  SESSION_DIR="/tmp/brainstorm-${SESSION_ID}"
fi

STATE_DIR="${SESSION_DIR}/state"
PID_FILE="${STATE_DIR}/server.pid"
LOG_FILE="${STATE_DIR}/server.log"

# 创建带 content 和 state peers 的新 session directory
mkdir -p "${SESSION_DIR}/content" "$STATE_DIR"

# 杀掉任何现有 server
if [[ -f "$PID_FILE" ]]; then
  old_pid=$(cat "$PID_FILE")
  kill "$old_pid" 2>/dev/null
  rm -f "$PID_FILE"
fi

cd "$SCRIPT_DIR"

# 解析 harness PID（本脚本的 grandparent）。
# $PPID 是 harness 为运行我们而 spawn 的 ephemeral shell — 它会在本脚本退出时死亡。
# harness 本身是 $PPID 的 parent。
OWNER_PID="$(ps -o ppid= -p "$PPID" 2>/dev/null | tr -d ' ')"
if [[ -z "$OWNER_PID" || "$OWNER_PID" == "1" ]]; then
  OWNER_PID="$PPID"
fi

# Foreground mode 用于会收割 detached/background processes 的环境。
if [[ "$FOREGROUND" == "true" ]]; then
  echo "$$" > "$PID_FILE"
  env BRAINSTORM_DIR="$SESSION_DIR" BRAINSTORM_HOST="$BIND_HOST" BRAINSTORM_URL_HOST="$URL_HOST" BRAINSTORM_OWNER_PID="$OWNER_PID" node server.cjs
  exit $?
fi

# 启动 server，将输出捕捉到 log file
# 使用 nohup 以在 shell exit 后存活；disown 从 job table 移除
nohup env BRAINSTORM_DIR="$SESSION_DIR" BRAINSTORM_HOST="$BIND_HOST" BRAINSTORM_URL_HOST="$URL_HOST" BRAINSTORM_OWNER_PID="$OWNER_PID" node server.cjs > "$LOG_FILE" 2>&1 &
SERVER_PID=$!
disown "$SERVER_PID" 2>/dev/null
echo "$SERVER_PID" > "$PID_FILE"

# 等待 server-started message（检查 log file）
for i in {1..50}; do
  if grep -q "server-started" "$LOG_FILE" 2>/dev/null; then
    # 在短窗口后验证 server 仍然 alive（捕捉 process reapers）
    alive="true"
    for _ in {1..20}; do
      if ! kill -0 "$SERVER_PID" 2>/dev/null; then
        alive="false"
        break
      fi
      sleep 0.1
    done
    if [[ "$alive" != "true" ]]; then
      echo "{\"error\": \"Server started but was killed. Retry in a persistent terminal with: $SCRIPT_DIR/start-server.sh${PROJECT_DIR:+ --project-dir $PROJECT_DIR} --host $BIND_HOST --url-host $URL_HOST --foreground\"}"
      exit 1
    fi
    grep "server-started" "$LOG_FILE" | head -1
    exit 0
  fi
  sleep 0.1
done

# Timeout - server didn't start
echo '{"error": "Server failed to start within 5 seconds"}'
exit 1
