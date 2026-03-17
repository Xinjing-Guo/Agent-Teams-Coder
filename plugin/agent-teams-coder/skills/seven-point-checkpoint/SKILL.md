---
name: Eight-Point Checkpoint
description: Mandatory pre-task checklist that every agent must complete before executing any work. Activates at the start of every task. Includes mandatory Chronicle CC on completion.
version: 1.1.0
---

# Eight-Point Mandatory Checkpoint

Every agent must complete these 8 steps in order before executing any task.

## The 8 Steps

### 1. Task Scope Confirmation

- Understand the task content and identify the core goal
- Confirm the task is within your responsibility
- If requirements are vague → ask Marshall for clarification
- If out of scope → decline and suggest the correct agent

### 2. Shared Memory Read

- Check team shared memory for relevant conventions
- DO NOT skip this step (no "I already know" shortcuts)

### 3. Smart Notification Check

- Check for messages from other team members
- If no new notifications → skip reading (save tokens)
- If new notifications → read and process

### 4. Team Status Sync

- Check current workflow phase
- Update your own status to "working"

### 5. Skill Applicability Check

- Check if any of your skills match this task
- If match → follow the skill's workflow
- If no match → proceed with standard approach

### 6. Task Decomposability Assessment

- Can this be split? (>= 3 steps? multi-file? parallelizable?)
- Output explicit conclusion: "decomposable" or "not decomposable"
- If decomposable → list subtasks with execution order

### 7. Git Operation Detection

- Does this task involve git commit/push?
- If yes → require explicit user authorization
- Never execute unauthorized git operations

### 8. Chronicle CC on Completion

- When your task is done, you MUST notify Chronicle with your output summary
- Run: `bash scripts/notify.sh <your_name> chronicle "<task summary>" "<what you did, what you produced, key data, issues found>"`
- Content must include: action taken, output files, key metrics (counts/pass rates/etc.), issues discovered
- Chronicle cannot "listen" — it must be actively notified by each member
- Skipping this step means Chronicle's log will be incomplete

## Violation Protocol

If you discover you skipped a step:

1. STOP current operation immediately
2. Announce: "Checkpoint violation detected — restarting"
3. Begin again from Step 1
