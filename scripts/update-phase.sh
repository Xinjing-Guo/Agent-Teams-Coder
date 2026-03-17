#!/bin/bash
################################################################################
# update-phase.sh — Marshall 更新当前工作流阶段
# 用法: bash update-phase.sh <phase_number> <task_name>
#
# 示例:
#   bash update-phase.sh 1 "开发排序库"
#   bash update-phase.sh 4 "开发排序库"
################################################################################

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
STATUS_FILE="$SCRIPT_DIR/../shared/memory/status.json"

PHASE="${1:?用法: update-phase.sh <phase_number> <task_name>}"
TASK="${2:?缺少 task_name 参数}"

TIMESTAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

# 阶段描述映射
declare -A PHASE_DESC
PHASE_DESC[1]="阶段 1: 需求分析"
PHASE_DESC[2]="阶段 2: 算法设计"
PHASE_DESC[3]="阶段 3: 代码开发"
PHASE_DESC[4]="阶段 4: 代码测试"
PHASE_DESC[5]="阶段 5: 代码分析"
PHASE_DESC[6]="阶段 6: 文档编写"
PHASE_DESC[7]="阶段 7: 汇总交付"

DESC="${PHASE_DESC[$PHASE]:-未知阶段}"

if command -v python3 &>/dev/null; then
    PY=python3
elif command -v python &>/dev/null; then
    PY=python
else
    echo "❌ 需要 Python"; exit 1
fi

$PY -c "
import json

with open('$STATUS_FILE', 'r') as f:
    data = json.load(f)

data['team_status']['current_task'] = '''$TASK'''
data['team_status']['phase'] = '$PHASE'
data['team_status']['phase_description'] = '$DESC'
data['meta']['last_updated'] = '$TIMESTAMP'
data['meta']['updated_by'] = 'marshall'

with open('$STATUS_FILE', 'w') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)
"

echo "✅ 工作流阶段已更新"
echo "   任务: $TASK"
echo "   $DESC"
