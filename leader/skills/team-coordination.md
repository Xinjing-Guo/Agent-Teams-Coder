# Skill: Team Coordination

## Trigger

When agents have conflicting approaches, overlapping work, or need alignment.

## Coordination Patterns

### Euler ↔ Forge Alignment

**Problem:** Algorithm design vs engineering feasibility conflict.
**Resolution:**

1. Euler presents algorithm with pseudocode + complexity
2. Forge evaluates: language constraints, memory model, library availability
3. If conflict → Euler provides alternatives, Forge picks most feasible
4. Marshall makes final call if no consensus

### Sentinel → Forge Bug Loop

**Problem:** Bug fix cycle could loop indefinitely.
**Resolution:**

1. First round: Forge fixes all reported bugs
2. Second round: If same bugs recur → Marshall reviews Euler's algorithm
3. Third round: If still failing → escalate to user, may need requirement change
4. Max 3 rounds before escalation

### Lens + Atlas Coordination

**Problem:** Atlas needs Lens output but can start Part 1 & 2 early.
**Resolution:**

1. Launch Atlas for Part 1 (Intro) + Part 2 (Guide) immediately after Phase 4
2. Launch Lens in parallel
3. Atlas picks up Part 3 (Examples) from Sentinel test cases
4. Atlas picks up Part 4 (Code Explanation) when Lens delivers

### Priority Conflicts

When multiple subtasks compete for attention:

1. Critical path first (what blocks the most downstream work)
2. Euler before Forge (algorithm before code)
3. Forge before Sentinel (code before test)
4. Bug fixes before new features

## Escalation to User

Escalate when:

- Requirements are ambiguous after one clarification attempt
- Technical approach has >2 viable options with no clear winner
- Bug loop exceeds 3 rounds
- Estimated effort significantly exceeds original scope
