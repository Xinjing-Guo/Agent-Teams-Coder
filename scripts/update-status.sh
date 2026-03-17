#!/bin/bash
################################################################################
# update-status.sh — 更新成员实时状态
# 用法: bash update-status.sh <agent_name> <status> [current_work] [blockers]
#   status: idle | working | blocked | waiting | done
#
# 示例:
#   bash update-status.sh forge working "实现排序算法" ""
#   bash update-status.sh sentinel blocked "" "等待 Forge 提交代码"
################################################################################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
STATUS_FILE="$SCRIPT_DIR/../shared/memory/status.json"

AGENT="${1:?用法: update-status.sh <agent_name> <status> [current_work] [blockers]}"
STATUS="${2:?缺少 status 参数 (idle|working|blocked|waiting|done)}"
CURRENT_WORK="${3:-}"
BLOCKERS="${4:-}"

TIMESTAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

# 验证 status
case "$STATUS" in
    idle|working|blocked|waiting|done) ;;
    *) echo "❌ 无效的 status: ${STATUS} (只支持 idle/working/blocked/waiting/done)"; exit 1 ;;
esac

# 检查 python
if command -v python3 &>/dev/null; then
    PY=python3
elif command -v python &>/dev/null; then
    PY=python
else
    echo "❌ 需要 Python"; exit 1
fi

STATUS_FILE="$STATUS_FILE" AGENT="$AGENT" STATUS="$STATUS" \
CURRENT_WORK="$CURRENT_WORK" BLOCKERS="$BLOCKERS" TIMESTAMP="$TIMESTAMP" \
$PY -c "
import json, os, sys

status_file = os.environ['STATUS_FILE']
agent = os.environ['AGENT']
status = os.environ['STATUS']
current_work = os.environ['CURRENT_WORK']
blockers_str = os.environ['BLOCKERS']
timestamp = os.environ['TIMESTAMP']

with open(status_file, 'r') as f:
    data = json.load(f)

if agent not in data['members']:
    print(f'未知成员: {agent}')
    sys.exit(1)

data['members'][agent]['status'] = status
data['members'][agent]['current_work'] = current_work
data['members'][agent]['last_active'] = timestamp

if blockers_str:
    data['members'][agent]['blockers'] = [b.strip() for b in blockers_str.split(',')]
else:
    data['members'][agent]['blockers'] = []

data['meta']['last_updated'] = timestamp
data['meta']['updated_by'] = agent

with open(status_file, 'w') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)
"

echo "✅ 状态已更新: $AGENT → $STATUS"
[ -n "$CURRENT_WORK" ] && echo "   当前工作: $CURRENT_WORK" || true
[ -n "$BLOCKERS" ] && echo "   阻塞项: $BLOCKERS" || true
