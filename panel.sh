#!/bin/bash
################################################################################
# panel.sh — 交互式启动面板（tmux 多窗格）
# 需要: tmux (brew install tmux / apt install tmux)
#
# 布局示意（全员模式）:
# ┌──────────────────┬──────────────────┐
# │   Marshall       │    Euler         │
# │   (Leader)       │   (算法设计)     │
# │                  ├──────────────────┤
# │                  │    Forge         │
# │                  │   (代码开发)     │
# ├──────────────────┼──────────────────┤
# │   Sentinel       │    Lens          │
# │   (代码测试)     │   (代码分析)     │
# ├──────────────────┼──────────────────┤
# │   Atlas          │    Chronicle     │
# │   (文档编写)     │   (日志记录)     │
# └──────────────────┴──────────────────┘
################################################################################

SESSION="agent-team"
DIR="$(cd "$(dirname "$0")" && pwd)"

# 检查 tmux
if ! command -v tmux &>/dev/null; then
    echo "❌ 需要安装 tmux"
    echo "   macOS:  brew install tmux"
    echo "   Ubuntu: sudo apt install tmux"
    exit 1
fi

# 检查 claude
if ! command -v claude &>/dev/null; then
    echo "❌ 需要安装 Claude Code"
    echo "   npm install -g @anthropic-ai/claude-code"
    exit 1
fi

# 如果 session 已存在
if tmux has-session -t "$SESSION" 2>/dev/null; then
    echo "Agent Team 会话已存在"
    echo ""
    echo "  1) 连接到现有会话"
    echo "  2) 关闭并重新启动"
    echo "  3) 退出"
    echo ""
    read -rp "请选择 [1-3]: " choice
    case $choice in
        1) tmux attach-session -t "$SESSION"; exit 0 ;;
        2) tmux kill-session -t "$SESSION" ;;
        *) exit 0 ;;
    esac
fi

echo "=========================================="
echo "  Agent Team — 启动面板"
echo "=========================================="
echo ""
echo "  a) 全员启动 (Marshall + Euler + Forge + Sentinel + Lens + Atlas + Chronicle)"
echo "  b) 核心开发 (Marshall + Euler + Forge + Sentinel)"
echo "  c) 仅 Leader (Marshall)"
echo "  d) 算法+开发 (Euler + Forge)"
echo "  e) 测试+分析+文档 (Sentinel + Lens + Atlas)"
echo "  q) 退出"
echo ""
read -rp "请选择: " selection

case $selection in
    a|A)
        # 全员: 7 个窗格
        tmux new-session -d -s "$SESSION" -c "$DIR/leader" -n "Agent Team"
        tmux send-keys -t "$SESSION" "claude -c 2>/dev/null || claude" C-m

        tmux split-window -h -t "$SESSION" -c "$DIR/euler"
        tmux send-keys -t "$SESSION" "claude -c 2>/dev/null || claude" C-m

        tmux select-pane -t "$SESSION:0.0"
        tmux split-window -v -t "$SESSION" -c "$DIR/sentinel"
        tmux send-keys -t "$SESSION" "claude -c 2>/dev/null || claude" C-m

        tmux split-window -v -t "$SESSION" -c "$DIR/atlas"
        tmux send-keys -t "$SESSION" "claude -c 2>/dev/null || claude" C-m

        tmux select-pane -t "$SESSION:0.1"
        tmux split-window -v -t "$SESSION" -c "$DIR/forge"
        tmux send-keys -t "$SESSION" "claude -c 2>/dev/null || claude" C-m

        tmux split-window -v -t "$SESSION" -c "$DIR/lens"
        tmux send-keys -t "$SESSION" "claude -c 2>/dev/null || claude" C-m

        tmux split-window -v -t "$SESSION" -c "$DIR/chronicle"
        tmux send-keys -t "$SESSION" "claude -c 2>/dev/null || claude" C-m

        tmux select-pane -t "$SESSION:0.0"
        tmux attach-session -t "$SESSION"
        ;;
    b|B)
        # 核心开发: Marshall + Euler + Forge + Sentinel
        tmux new-session -d -s "$SESSION" -c "$DIR/leader" -n "Agent Team"
        tmux send-keys -t "$SESSION" "claude -c 2>/dev/null || claude" C-m

        tmux split-window -h -t "$SESSION" -c "$DIR/euler" -p 50
        tmux send-keys -t "$SESSION" "claude -c 2>/dev/null || claude" C-m

        tmux split-window -v -t "$SESSION" -c "$DIR/forge"
        tmux send-keys -t "$SESSION" "claude -c 2>/dev/null || claude" C-m

        tmux select-pane -t "$SESSION:0.0"
        tmux split-window -v -t "$SESSION" -c "$DIR/sentinel"
        tmux send-keys -t "$SESSION" "claude -c 2>/dev/null || claude" C-m

        tmux select-pane -t "$SESSION:0.0"
        tmux attach-session -t "$SESSION"
        ;;
    c|C)
        tmux new-session -d -s "$SESSION" -c "$DIR/leader" -n "Agent Team"
        tmux send-keys -t "$SESSION" "claude -c 2>/dev/null || claude" C-m
        tmux attach-session -t "$SESSION"
        ;;
    d|D)
        # 算法+开发: Euler + Forge
        tmux new-session -d -s "$SESSION" -c "$DIR/euler" -n "算法+开发"
        tmux send-keys -t "$SESSION" "claude -c 2>/dev/null || claude" C-m

        tmux split-window -h -t "$SESSION" -c "$DIR/forge"
        tmux send-keys -t "$SESSION" "claude -c 2>/dev/null || claude" C-m

        tmux attach-session -t "$SESSION"
        ;;
    e|E)
        # 测试+分析+文档
        tmux new-session -d -s "$SESSION" -c "$DIR/sentinel" -n "测试+分析+文档"
        tmux send-keys -t "$SESSION" "claude -c 2>/dev/null || claude" C-m

        tmux split-window -h -t "$SESSION" -c "$DIR/lens"
        tmux send-keys -t "$SESSION" "claude -c 2>/dev/null || claude" C-m

        tmux split-window -v -t "$SESSION" -c "$DIR/atlas"
        tmux send-keys -t "$SESSION" "claude -c 2>/dev/null || claude" C-m

        tmux select-pane -t "$SESSION:0.0"
        tmux attach-session -t "$SESSION"
        ;;
    *)
        exit 0
        ;;
esac
