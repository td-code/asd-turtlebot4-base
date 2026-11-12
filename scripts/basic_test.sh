#!/usr/bin/env bash

# Copyright (c) 2026, Thao Dang, University of Applied Sciences Esslingen, Germany
# SPDX-License-Identifier: BSD-3-Clause

set -Eeuo pipefail

WORKSPACE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
HEADLESS=false
while (($#)); do
  case "$1" in
    --headless) HEADLESS=true ;;
    -h|--help)
      echo "Usage: $0 [--headless]"
      echo "  --headless  Run Gazebo without a GUI, using headless rendering."
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      echo "Usage: $0 [--headless]" >&2
      exit 2
      ;;
  esac
  shift
done

LOG_DIR="$(mktemp -d)"
BUILD_LOG="$LOG_DIR/build.log"
TOPIC_LOG="$LOG_DIR/topics.log"
SCAN_LOG="$LOG_DIR/scan.log"
LAUNCH_LOG="$LOG_DIR/launch.log"
LAUNCH_SID_FILE="$LOG_DIR/launch.sid"
LAUNCH_PID=""
LAUNCH_SID=""

launch_session_pids() {
  [[ -n "$LAUNCH_SID" ]] || return 0
  ps -eo pid=,sid=,stat= | awk -v session="$LAUNCH_SID" '$2 == session && $3 !~ /^Z/ {print $1}'
}

signal_launch_session() {
  local signal="$1"
  local pid

  while read -r pid; do
    [[ -n "$pid" ]] && kill "-$signal" "$pid" 2>/dev/null || true
  done < <(launch_session_pids)
}

print_log_tail() {
  local name="$1"
  local path="$2"

  if [[ -s "$path" ]]; then
    printf '\n--- %s (last 30 lines) ---\n' "$name" >&2
    tail -n 30 "$path" >&2
  fi
}

cleanup() {
  local status=$?
  local remaining_pids

  trap - EXIT
  if (( status != 0 )) && [[ -s "$LAUNCH_LOG" ]]; then
    echo "--- Simulation errors before shutdown (last 15 lines) ---" >&2
    grep -Ei '\[ERROR\]|\[Err\]|fatal|exception' "$LAUNCH_LOG" | tail -n 15 >&2 || true
  fi
  if [[ -n "$LAUNCH_PID" ]]; then
    echo "Stopping the simulation started by this test..."
    if [[ -n "$LAUNCH_SID" ]]; then
      kill -INT "$LAUNCH_SID" 2>/dev/null || true
      for _ in {1..20}; do
        remaining_pids="$(launch_session_pids)"
        if [[ -z "$remaining_pids" ]]; then
          break
        fi
        sleep 1
      done
      remaining_pids="$(launch_session_pids)"
      if [[ -n "$remaining_pids" ]]; then
        echo "Launch did not stop after SIGINT; sending SIGTERM." >&2
        signal_launch_session TERM
        sleep 2
        remaining_pids="$(launch_session_pids)"
        if [[ -n "$remaining_pids" ]]; then
          echo "Launch did not stop after SIGTERM; sending SIGKILL." >&2
          signal_launch_session KILL
        fi
      fi
    else
      kill -TERM "$LAUNCH_PID" 2>/dev/null || true
    fi
    wait "$LAUNCH_PID" 2>/dev/null || true
  fi

  if (( status != 0 )); then
    echo "Basic test failed." >&2
    print_log_tail "Build output" "$BUILD_LOG"
    print_log_tail "ROS topic output" "$TOPIC_LOG"
    print_log_tail "Laser scan output" "$SCAN_LOG"
    print_log_tail "Simulation launch output" "$LAUNCH_LOG"
  fi

  rm -rf -- "$LOG_DIR"
  exit "$status"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

for command in colcon ros2 timeout ps setsid env; do
  command -v "$command" >/dev/null 2>&1 || fail "Required command not found: $command"
done

ROS_SETUP="/opt/ros/jazzy/setup.bash"
[[ -r "$ROS_SETUP" ]] || fail "ROS setup file not found: $ROS_SETUP"
set +u
source "$ROS_SETUP"
set -u

if command -v curl >/dev/null 2>&1 && curl --fail --silent --head --max-time 10 https://www.google.com >/dev/null 2>&1; then
  echo "PASS: Internet connection is available."
else
  echo "WARN: Internet connection could not be verified; continuing."
fi

echo "Building the workspace..."
if ! (cd "$WORKSPACE_DIR" && colcon build --merge-install --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Release) >"$BUILD_LOG" 2>&1; then
  fail "Workspace build failed."
fi
echo "PASS: Workspace build completed."

set +u
source "$WORKSPACE_DIR/install/setup.bash"
set -u

echo "Checking the ROS parameter event topic..."
if ! timeout 10s ros2 topic list >"$TOPIC_LOG" 2>&1; then
  fail "'ros2 topic list' failed before starting the simulation."
fi
if ! grep -Fxq "/parameter_events" "$TOPIC_LOG"; then
  fail "Required topic /parameter_events was not found."
fi
echo "PASS: /parameter_events is available."

if [[ "$HEADLESS" == true ]]; then
  echo "Starting the TurtleBot 4 Gazebo simulation in headless mode..."
  launch_args=("$WORKSPACE_DIR/scripts/basic_test_headless.launch.py")
else
  echo "Starting the TurtleBot 4 Gazebo simulation..."
  launch_args=(turtlebot4_gz_bringup turtlebot4_gz.launch.py)
fi
setsid --wait env --default-signal=INT bash -c '
  printf "%s\n" "$(ps -o sid= -p "$$" | tr -d "[:space:]")" > "$1"
  cd "$2"
  shift 2
  exec ros2 launch "$@"
' _ "$LAUNCH_SID_FILE" "$WORKSPACE_DIR" "${launch_args[@]}" >"$LAUNCH_LOG" 2>&1 &
LAUNCH_PID=$!
for _ in {1..5}; do
  [[ -s "$LAUNCH_SID_FILE" ]] && LAUNCH_SID="$(<"$LAUNCH_SID_FILE")"
  [[ -n "$LAUNCH_SID" ]] && break
  kill -0 "$LAUNCH_PID" 2>/dev/null || break
  sleep 0.1
done
[[ -n "$LAUNCH_SID" ]] || fail "Could not isolate the simulation launch process."

echo "Waiting up to 30 seconds for /scan and /tf..."
topics_ready=false
for _ in {1..30}; do
  launch_state="$(ps -o stat= -p "$LAUNCH_PID" 2>/dev/null || true)"
  if [[ -z "$launch_state" || "$launch_state" == Z* ]]; then
    if wait "$LAUNCH_PID"; then
      fail "The simulation launch exited before its topics became available."
    else
      fail "The simulation launch failed before its topics became available."
    fi
  fi
  if timeout 5s ros2 topic list >"$TOPIC_LOG" 2>&1 \
    && grep -Fxq "/scan" "$TOPIC_LOG" \
    && grep -Fxq "/tf" "$TOPIC_LOG"; then
    topics_ready=true
    break
  fi
  sleep 1
done
[[ "$topics_ready" == true ]] || fail "Timed out waiting for /scan and /tf."
echo "PASS: /scan and /tf are available."

echo "Checking that /scan publishes a LaserScan message..."
if ! timeout 30s ros2 topic echo /scan --once --qos-reliability best_effort >"$SCAN_LOG" 2>&1; then
  fail "Could not receive a message from /scan."
fi
if ! grep -q '^ranges:' "$SCAN_LOG"; then
  fail "The /scan message did not contain the expected ranges field."
fi
echo "PASS: /scan published a LaserScan message."
echo "Basic test passed."
