#!/bin/bash
################################################################################
# launch-team.sh — 智能启动团队
# 检测 tmux 可用性，有则开多窗格，无则提示用子 Agent 模式
#
# 用法: bash launch-team.sh <plugin_root> <requirement> [model]
#   plugin_root: 插件根目录（用于定位 agent 配置）
#   requirement: 用户需求描述
#   model:       可选模型 (opus/haiku，默认 sonnet)
#
# 返回值:
#   exit 0 — tmux 已启动，多窗口模式
#   exit 1 — tmux 不可用，需要降级到子 Agent 模式
#   exit 2 — 已在 tmux 中，直接分屏
################################################################################

set -e

PLUGIN_ROOT="${1:?用法: launch-team.sh <plugin_root> <requirement> [model]}"
REQUIREMENT="${2:?缺少需求描述}"
MODEL="${3:-}"
SESSION="agent-team"

# ─── 项目根目录（脚本执行时的工作目录）───
PROJECT_DIR="$(pwd)"

# ─── Agent 名称与窗格标题映射（bash 3.2 兼容，不用 declare -A）───
AGENT_NAMES="marshall euler forge sentinel lens atlas chronicle"
AGENT_TITLES="Marshall_(Leader) Euler_(Algorithm) Forge_(Code) Sentinel_(Test) Lens_(Analysis) Atlas_(Docs) Chronicle_(Log)"

# ─── 根据 agent 名称获取显示标题 ───
get_agent_title() {
    local name="$1"
    local idx=0
    for n in $AGENT_NAMES; do
        if [ "$n" = "$name" ]; then
            local i=0
            for t in $AGENT_TITLES; do
                if [ "$i" = "$idx" ]; then
                    echo "$t" | tr '_' ' '
                    return
                fi
                i=$((i + 1))
            done
        fi
        idx=$((idx + 1))
    done
    echo "$name"
}

# ─── 根据 agent 名称获取其工作目录 ───
get_agent_dir() {
    local agent_name="$1"
    # marshall 对应 leader/ 目录，其余对应同名目录
    local dir_name="$agent_name"
    if [ "$agent_name" = "marshall" ]; then
        dir_name="leader"
    fi
    if [ -d "$PROJECT_DIR/$dir_name" ]; then
        echo "$PROJECT_DIR/$dir_name"
    else
        echo "$PLUGIN_ROOT/agents"
    fi
}

# ─── 检测 tmux ───
if ! command -v tmux &>/dev/null; then
    echo "TMUX_NOT_AVAILABLE"
    exit 1
fi

# ─── 检测 claude ───
if ! command -v claude &>/dev/null; then
    echo "CLAUDE_NOT_AVAILABLE"
    exit 1
fi

# ─── 模型参数 ───
MODEL_FLAG=""
case "$MODEL" in
    opus)  MODEL_FLAG="--model claude-opus-4-6" ;;
    haiku) MODEL_FLAG="--model claude-haiku-4-5-20251001" ;;
    "")    MODEL_FLAG="" ;;
esac

# ─── 向指定窗格发送初始 prompt ───
# 参数: $1=tmux_target (如 "$SESSION:0.0"), $2=agent_name
send_agent_prompt() {
    local target="$1"
    local agent_name="$2"
    if [ "$agent_name" = "marshall" ]; then
        tmux send-keys -t "$target" "团队收到新需求: ${REQUIREMENT} -- 请执行七步检查点初始化，然后开始任务拆解与分配。通过 notify.sh 向各成员下发任务。" C-m
    else
        tmux send-keys -t "$target" "团队收到新需求，请执行七步检查点初始化（读取 PERSONA.md -> 共享记忆 -> 检查通知 -> 更新状态 -> 检查 Skills -> 评估任务），然后等待 Marshall 的任务分配通知。执行: bash ../scripts/check-notify.sh ${agent_name}" C-m
    fi
}

# ─── 向所有窗格发送初始 prompt（等待 Claude 启动后）───
# 参数: $1=tmux session/window 前缀 (如 "$SESSION:0"), $2=窗格数量
send_all_prompts() {
    local prefix="$1"
    local pane_count="$2"
    # 等待 Claude 实例启动
    sleep 4
    local idx=0
    for agent in $AGENT_NAMES; do
        if [ "$idx" -ge "$pane_count" ]; then
            break
        fi
        send_agent_prompt "${prefix}.${idx}" "$agent"
        # 每个 prompt 之间间隔一小段避免冲突
        sleep 1
        idx=$((idx + 1))
    done
}

# ─── 如果已经在 tmux 内 ───
if [ -n "${TMUX:-}" ]; then
    echo "TMUX_INSIDE"
    # 在当前 tmux 会话中分屏
    CURRENT_WINDOW=$(tmux display-message -p '#I')
    CURRENT_SESSION=$(tmux display-message -p '#S')

    # 创建新窗口放团队
    tmux new-window -n "Agent Team" -c "$(get_agent_dir marshall)"
    TEAM_WINDOW=$(tmux display-message -p '#I')
    INSIDE_PREFIX="${CURRENT_SESSION}:${TEAM_WINDOW}"

    # Marshall (主窗格, pane 0)
    tmux send-keys "claude $MODEL_FLAG" C-m

    # Euler (pane 1)
    tmux split-window -h -c "$(get_agent_dir euler)"
    tmux send-keys "claude $MODEL_FLAG" C-m

    # Forge (pane 2) — split from Marshall vertically
    tmux select-pane -t "${INSIDE_PREFIX}.0"
    tmux split-window -v -c "$(get_agent_dir forge)"
    tmux send-keys "claude $MODEL_FLAG" C-m

    # Sentinel (pane 3) — split from Euler vertically
    tmux select-pane -t "${INSIDE_PREFIX}.2"
    tmux split-window -v -c "$(get_agent_dir sentinel)"
    tmux send-keys "claude $MODEL_FLAG" C-m

    # Lens (pane 4)
    tmux split-window -v -c "$(get_agent_dir lens)"
    tmux send-keys "claude $MODEL_FLAG" C-m

    # Atlas (pane 5)
    tmux select-pane -t "${INSIDE_PREFIX}.1"
    tmux split-window -v -c "$(get_agent_dir atlas)"
    tmux send-keys "claude $MODEL_FLAG" C-m

    # Chronicle (pane 6)
    tmux split-window -v -c "$(get_agent_dir chronicle)"
    tmux send-keys "claude $MODEL_FLAG" C-m

    # 回到 Marshall 窗格
    tmux select-pane -t "${INSIDE_PREFIX}.0"

    # 发送初始 prompt 到所有窗格
    send_all_prompts "$INSIDE_PREFIX" 7 &

    echo "TMUX_SPLIT_DONE"
    exit 2
fi

# ─── 正常启动新 tmux 会话 ───
if tmux has-session -t "$SESSION" 2>/dev/null; then
    tmux kill-session -t "$SESSION"
fi

# Marshall (左上, pane 0)
tmux new-session -d -s "$SESSION" -n "Agent Team" -c "$(get_agent_dir marshall)"
tmux send-keys -t "$SESSION" "claude $MODEL_FLAG" C-m

# Euler (右上, pane 1)
tmux split-window -h -t "$SESSION" -c "$(get_agent_dir euler)"
tmux send-keys -t "$SESSION" "claude $MODEL_FLAG" C-m

# Forge (右中, pane 2)
tmux split-window -v -t "$SESSION" -c "$(get_agent_dir forge)"
tmux send-keys -t "$SESSION" "claude $MODEL_FLAG" C-m

# Sentinel (左中, pane 3)
tmux select-pane -t "$SESSION:0.0"
tmux split-window -v -t "$SESSION" -c "$(get_agent_dir sentinel)"
tmux send-keys -t "$SESSION" "claude $MODEL_FLAG" C-m

# Lens (左下, pane 4)
tmux split-window -v -t "$SESSION" -c "$(get_agent_dir lens)"
tmux send-keys -t "$SESSION" "claude $MODEL_FLAG" C-m

# Atlas (右下, pane 5)
tmux select-pane -t "$SESSION:0.2"
tmux split-window -v -t "$SESSION" -c "$(get_agent_dir atlas)"
tmux send-keys -t "$SESSION" "claude $MODEL_FLAG" C-m

# Chronicle (最右下, pane 6)
tmux split-window -v -t "$SESSION" -c "$(get_agent_dir chronicle)"
tmux send-keys -t "$SESSION" "claude $MODEL_FLAG" C-m

# 回到 Marshall
tmux select-pane -t "$SESSION:0.0"

# 设置窗格标题
tmux select-pane -t "$SESSION:0.0" -T "Marshall (Leader)"
tmux select-pane -t "$SESSION:0.1" -T "Euler (Algorithm)"
tmux select-pane -t "$SESSION:0.2" -T "Forge (Code)"
tmux select-pane -t "$SESSION:0.3" -T "Sentinel (Test)"
tmux select-pane -t "$SESSION:0.4" -T "Lens (Analysis)"
tmux select-pane -t "$SESSION:0.5" -T "Atlas (Docs)"
tmux select-pane -t "$SESSION:0.6" -T "Chronicle (Log)"

# 启用窗格边框标题显示
tmux set-option -t "$SESSION" pane-border-status top
tmux set-option -t "$SESSION" pane-border-format " #{pane_title} "

# ─── 发送初始 prompt（后台执行，不阻塞调用方）───
send_all_prompts "$SESSION:0" 7 &

echo "TMUX_SESSION_CREATED"
echo "SESSION_NAME=$SESSION"
echo "REQUIREMENT=$REQUIREMENT"

# 不 attach — 让调用方决定是否 attach
# 用户可以执行: tmux attach -t agent-team
exit 0
