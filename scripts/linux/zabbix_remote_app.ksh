#!/bin/ksh
# Generic Zabbix remote-operation example for Linux/AIX.
# Do not hard-code credentials, private keys, or production paths.

set -u

APP_NAME="${1:-}"
ACTION="${2:-status}"
BASE_DIR="${APP_BASE_DIR:-/opt/apps}"
WAIT_TIMEOUT="${REMOTE_TIMEOUT:-30}"

if [ -z "$APP_NAME" ]; then
  echo "Usage: $0 <app-name> <start|stop|restart|status>"
  exit 2
fi

case "$APP_NAME" in
  sample-app|sample-batch)
    ;;
  *)
    echo "DENIED: application is not in the allow-list: $APP_NAME"
    exit 3
    ;;
esac

APP_DIR="$BASE_DIR/$APP_NAME"
START_SCRIPT="$APP_DIR/bin/start.sh"
STOP_SCRIPT="$APP_DIR/bin/stop.sh"
PID_FILE="$APP_DIR/run/$APP_NAME.pid"

is_running() {
  if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE" 2>/dev/null)
    if [ -n "${PID:-}" ] && kill -0 "$PID" 2>/dev/null; then
      return 0
    fi
  fi
  return 1
}

wait_for_running() {
  i=0
  while [ "$i" -lt "$WAIT_TIMEOUT" ]; do
    if is_running; then
      return 0
    fi
    sleep 1
    i=$((i + 1))
  done
  return 1
}

wait_for_stopped() {
  i=0
  while [ "$i" -lt "$WAIT_TIMEOUT" ]; do
    if ! is_running; then
      return 0
    fi
    sleep 1
    i=$((i + 1))
  done
  return 1
}

start_app() {
  if is_running; then
    echo "ALREADY_RUNNING: $APP_NAME"
    return 0
  fi

  if [ ! -x "$START_SCRIPT" ]; then
    echo "ERROR: start script is not executable: $START_SCRIPT"
    return 4
  fi

  if ! "$START_SCRIPT"; then
    echo "ERROR: start script failed: $APP_NAME"
    return 10
  fi

  if ! wait_for_running; then
    echo "ERROR: $APP_NAME did not become running within ${WAIT_TIMEOUT}s"
    return 11
  fi

  echo "SUCCESS: $APP_NAME started"
  return 0
}

stop_app() {
  if ! is_running; then
    echo "ALREADY_STOPPED: $APP_NAME"
    return 0
  fi

  if [ ! -x "$STOP_SCRIPT" ]; then
    echo "ERROR: stop script is not executable: $STOP_SCRIPT"
    return 5
  fi

  if ! "$STOP_SCRIPT"; then
    echo "ERROR: stop script failed: $APP_NAME"
    return 12
  fi

  if ! wait_for_stopped; then
    echo "ERROR: $APP_NAME did not stop within ${WAIT_TIMEOUT}s"
    return 13
  fi

  echo "SUCCESS: $APP_NAME stopped"
  return 0
}

case "$ACTION" in
  start)
    start_app
    ;;
  stop)
    stop_app
    ;;
  restart)
    stop_app && start_app
    ;;
  status)
    if is_running; then
      echo "RUNNING: $APP_NAME"
      exit 0
    else
      echo "STOPPED: $APP_NAME"
      exit 1
    fi
    ;;
  *)
    echo "Unsupported action: $ACTION"
    exit 2
    ;;
esac
