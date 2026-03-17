---
name: Shared Memory Protocol
description: Use when team agents need to read, write, or manage shared team knowledge (architecture decisions, API conventions, coding standards). Provides the approval-based governance model for shared memory.
version: 1.0.1
---

# Shared Memory Protocol

The shared memory system ensures team knowledge consistency through an approval-based governance model.

## Architecture

```
shared-memory.json    ← Protected team knowledge store
approval-queue.json   ← Pending change requests
status.json           ← Real-time team state (open access)
```

## Access Rules

| Operation           | Who               | Method                           |
| ------------------- | ----------------- | -------------------------------- |
| Read shared-memory  | All agents        | Direct file read                 |
| Write shared-memory | Non-leader agents | Submit request → Leader approves |
| Write shared-memory | Marshall (Leader) | Direct write                     |
| Read/Write status   | All agents        | Direct access                    |

## Workflow for Members

1. Identify need to record a team convention
2. Submit request: include key, content, and reason
3. Notify Marshall for approval
4. **Wait for approval before using the convention in code**

## What Belongs in Shared Memory

- Architecture decisions (e.g., "Use microservice pattern")
- API conventions (e.g., "REST with JSON, snake_case fields")
- Coding standards (e.g., "Python: Black formatter, line width 88")
- Algorithm specifications (e.g., "Large datasets: external merge sort")
- Bug patterns (e.g., "Always validate UTF-8 input")

## What Does NOT Belong

- Temporary task status (use status.json)
- Individual work notes
- Code itself
