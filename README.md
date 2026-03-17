# Agent Team — 基于 Claude Code 的多智能体软件开发协作系统

> Marshall（Leader） 领导团队成员协作开发，共享记忆的写入/编辑/删除都需要 Marshall（Leader） 审批。

## 架构

<p align="center">
  <img src="docs/architecture.svg" alt="Agent Teams Coder 协作架构图" width="100%"/>
</p>

## 团队成员

| 代号                      | 名称   | 角色           | 核心技能                        |
| ------------------------- | ------ | -------------- | ------------------------------- |
| **Marshall（Leader）**    | 统帅   | Leader         | 任务拆解、分配、审批、汇总      |
| **Euler（算法设计师）**   | 欧拉   | 算法设计师     | 算法设计、数学建模、复杂度分析  |
| **Forge（代码开发）**     | 锻造者 | 代码开发工程师 | Python, C, C++, R, Julia, Shell |
| **Sentinel（代码测试）**  | 哨兵   | 代码测试工程师 | pytest, GTest, valgrind, 覆盖率 |
| **Lens（代码分析）**      | 透镜   | 代码分析师     | 代码结构、函数解读、逐行解释    |
| **Atlas（文档工程师）**   | 图鉴   | 文档工程师     | 说明书、使用案例、代码解释文档  |
| **Chronicle（日志记录）** | 编年史 | 日志记录员     | 活动记录、对话总结、更新日志    |

## 标准工作流

```
阶段 1: 需求分析    → Marshall（Leader） 拆解需求，Chronicle（日志记录） 开始记录
阶段 2: 算法设计    → Euler（算法设计师） 设计算法，与 Forge（代码开发） 对齐方案
阶段 3: 代码开发    → Forge（代码开发） 实现代码（基于 Euler（算法设计师） 的算法）
阶段 4: 代码测试    → Sentinel（代码测试） 严格测试，报告群发
阶段 5: 代码分析    → Lens（代码分析） 分析代码结构，逐行解释
阶段 6: 文档编写    → Atlas（文档工程师） 整合说明书（含测试用例 + 代码分析）
阶段 7: 汇总交付    → Marshall（Leader） 汇总，Chronicle（日志记录） 生成总结
```

## 前置要求

- Claude Code v2.1.32+（`claude --version` 检查）
- 启用 Agent Teams: 在 `settings.json` 或环境变量中设置:
  ```json
  { "env": { "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1" } }
  ```
- tmux（可选，用于 panel.sh 多窗格启动）

## 快速开始

### 方式一: 单独启动某个 Agent

```bash
./start-leader.sh           # Marshall（统帅）— 默认 Sonnet
./start-euler.sh            # Euler（算法设计）
./start-forge.sh            # Forge（代码开发）
./start-sentinel.sh         # Sentinel（测试）
./start-lens.sh             # Lens（代码分析）
./start-atlas.sh            # Atlas（文档）
./start-chronicle.sh        # Chronicle（日志）

# 指定模型
./start-euler.sh opus       # 用 Opus 模型启动
./start-forge.sh haiku      # 用 Haiku 模型启动
```

### 方式二: tmux 面板同时启动

```bash
./panel.sh
# 选择:
#   a) 全员启动 — 7 个窗格同时运行
#   b) 核心开发 — Marshall + Euler + Forge + Sentinel
#   c) 仅 Leader
#   d) 算法+开发 — Euler + Forge
#   e) 测试+分析+文档 — Sentinel + Lens + Atlas
```

### 方式三: 用 Agent Teams 从 Marshall（Leader） 启动

在 Marshall（Leader） 的 Claude Code 会话中直接说:

```
创建一个团队:
- Euler: 负责算法设计，工作目录 ../euler
- Forge: 负责代码开发，工作目录 ../forge
- Sentinel: 负责代码测试，工作目录 ../sentinel
- Lens: 负责代码分析，工作目录 ../lens
- Atlas: 负责文档编写，工作目录 ../atlas
- Chronicle: 负责日志记录，工作目录 ../chronicle

然后把以下需求拆解分配给他们: [你的需求]
```

## 项目结构

```
agent_team/
├── CLAUDE.md                          # 项目级指令（所有 Agent 共享）
├── README.md                          # 本文件
├── .gitignore
│
├── leader/                            # Marshall 配置
│   ├── CLAUDE.md
│   ├── PERSONA.md
│   └── skills/                        #   专属技能包
│       └── task-decomposition.md
│
├── euler/                             # Euler 配置
│   ├── CLAUDE.md
│   ├── PERSONA.md
│   └── skills/
│       ├── algorithm-design.md
│       └── complexity-analysis.md
│
├── forge/                             # Forge 配置
│   ├── CLAUDE.md
│   ├── PERSONA.md
│   └── skills/
│       ├── multi-language-coding.md
│       └── code-review-checklist.md
│
├── sentinel/                          # Sentinel 配置
│   ├── CLAUDE.md
│   ├── PERSONA.md
│   └── skills/
│       ├── test-strategy.md
│       └── bug-tracking.md
│
├── lens/                              # Lens 配置
│   ├── CLAUDE.md
│   ├── PERSONA.md
│   └── skills/
│       └── code-analysis-framework.md
│
├── atlas/                             # Atlas 配置
│   ├── CLAUDE.md
│   ├── PERSONA.md
│   └── skills/
│       └── manual-structure.md
│
├── chronicle/                         # Chronicle 配置
│   ├── CLAUDE.md
│   ├── PERSONA.md
│   └── skills/
│       └── activity-logging.md
│
├── shared/                            # 共享工作区
│   ├── memory/
│   │   ├── shared-memory.json         #   共享记忆（受保护）
│   │   ├── approval-queue.json        #   审批队列
│   │   └── status.json                #   团队实时状态
│   ├── tasks/                         #   任务记录
│   ├── notifications/                 #   通知文件
│   └── templates/                     #   文档模板
│       ├── prd.md
│       ├── bug.md
│       └── api.md
│
├── scripts/                           # 工具脚本
│   ├── memory-request.sh
│   ├── memory-approve.sh
│   ├── memory-reject.sh
│   ├── memory-write.sh
│   ├── notify.sh
│   ├── check-notify.sh
│   ├── update-status.sh              #   更新成员状态
│   └── update-phase.sh               #   更新工作流阶段
│
├── panel.sh                           # tmux 多窗格启动面板
├── start-leader.sh
├── start-euler.sh
├── start-forge.sh
├── start-sentinel.sh
├── start-lens.sh
├── start-atlas.sh
└── start-chronicle.sh
```

## 协作网络详解

### 核心协作关系

| 关系                                       | 说明                                                                              |
| ------------------------------------------ | --------------------------------------------------------------------------------- |
| Euler（算法设计师） ↔ Forge（代码开发）    | 算法→代码：Euler（算法设计师） 提供算法方案，Forge（代码开发） 实现并反馈工程约束 |
| Forge（代码开发） → Sentinel（代码测试）   | 代码→测试：Forge（代码开发） 完成代码后通知 Sentinel（代码测试） 测试             |
| Sentinel（代码测试） → Forge（代码开发）   | Bug→修复：Sentinel（代码测试） 报告 Bug，Forge（代码开发） 修复后回归测试         |
| Lens（代码分析） → Atlas（文档工程师）     | 分析→文档：Lens（代码分析） 提供逐行代码解释，Atlas（文档工程师） 写入说明书      |
| Sentinel（代码测试） → Atlas（文档工程师） | 测试→文档：Sentinel（代码测试） 提供测试用例，Atlas（文档工程师） 转化为使用案例  |
| Chronicle（日志记录） ← 全员               | 日志记录：Chronicle（日志记录） 监听所有成员活动并记录                            |

### Atlas 说明书四大章节来源

| 章节                   | 内容来源                             |
| ---------------------- | ------------------------------------ |
| 第一部分: 软件介绍     | Forge（技术架构）+ Euler（算法说明） |
| 第二部分: 使用说明书   | Forge（接口信息）+ 自身编写          |
| 第三部分: 使用案例     | Sentinel（测试用例转化）             |
| 第四部分: 代码逐行解释 | Lens（代码分析报告）                 |

## 核心机制

### 1. 七步强制检查点

每个成员收到任务后、执行操作前，必须完成 7 步检查：

| 步骤 | 检查内容         | 目的                           |
| ---- | ---------------- | ------------------------------ |
| 1    | 任务范围确认     | 防止越权或误解需求             |
| 2    | 共享记忆读取     | 确保遵循团队约定               |
| 3    | 智能通知检查     | 不遗漏队友消息                 |
| 4    | 团队状态同步     | 了解当前阶段，更新自己状态     |
| 5    | Skill 适用性检查 | 有专用 skill 就按 skill 流程走 |
| 6    | 任务可分解性评估 | 能拆就拆，提高效率             |
| 7    | Git 操作检测     | 防止未授权操作                 |

违规时自动停止并从第 1 步重新开始。

### 2. 团队实时状态 (status.json)

```bash
# 成员更新自己的状态
bash scripts/update-status.sh forge working "实现排序算法"
bash scripts/update-status.sh sentinel blocked "" "等待 Forge 提交代码"

# Marshall 更新工作流阶段
bash scripts/update-phase.sh 3 "开发排序库"
```

状态值: `idle` | `working` | `blocked` | `waiting` | `done`

### 3. Skill 系统

每个成员在 `skills/` 目录下有专属技能文件，包含标准化的执行流程、模板和检查清单。

```bash
# 示例: Forge 执行代码自审
cat forge/skills/code-review-checklist.md

# 示例: Sentinel 设计测试策略
cat sentinel/skills/test-strategy.md
```

### 4. 启动脚本模型选择

```bash
./start-euler.sh           # 默认 Sonnet
./start-euler.sh opus      # 使用 Opus（复杂算法设计）
./start-chronicle.sh haiku # 使用 Haiku（日志记录，节省成本）
```

## 许可证

MIT
