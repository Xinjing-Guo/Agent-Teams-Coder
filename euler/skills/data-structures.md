# Skill: Data Structure Selection

## Trigger

When designing an algorithm, choose the optimal data structure based on access patterns and constraints.

## Selection Guide

| Need                   | Data Structure                | Time (avg)            | Space      |
| ---------------------- | ----------------------------- | --------------------- | ---------- |
| Fast lookup by key     | Hash Map                      | O(1) get/set          | O(n)       |
| Ordered iteration      | Balanced BST (Red-Black, AVL) | O(log n) ops          | O(n)       |
| Priority access        | Binary Heap / Fibonacci Heap  | O(log n) extract      | O(n)       |
| Range queries          | Segment Tree / BIT            | O(log n) query/update | O(n)       |
| Prefix/string matching | Trie                          | O(L) lookup           | O(Σ·L)     |
| Graph traversal        | Adjacency List                | O(V+E) BFS/DFS        | O(V+E)     |
| Dense graph            | Adjacency Matrix              | O(1) edge check       | O(V²)      |
| Union-Find             | Disjoint Set                  | O(α(n)) ≈ O(1)        | O(n)       |
| Interval overlap       | Interval Tree                 | O(log n + k) query    | O(n)       |
| Spatial queries        | KD-Tree / R-Tree              | O(log n) nearest      | O(n)       |
| FIFO/LIFO              | Queue / Stack                 | O(1) push/pop         | O(n)       |
| Sorted dynamic         | Skip List                     | O(log n) ops          | O(n log n) |

## Language-Specific Implementations

| Structure  | Python                     | C++              | R                      | Julia               |
| ---------- | -------------------------- | ---------------- | ---------------------- | ------------------- |
| Hash Map   | `dict`                     | `unordered_map`  | `list` / `environment` | `Dict`              |
| Sorted Map | — (use `sortedcontainers`) | `map`            | —                      | `SortedDict` (pkg)  |
| Heap       | `heapq`                    | `priority_queue` | — (manual)             | `DataStructures.jl` |
| Queue      | `collections.deque`        | `queue`          | —                      | `DataStructures.jl` |
| Set        | `set`                      | `unordered_set`  | —                      | `Set`               |

## Decision Checklist

When recommending a data structure to Forge:

- [ ] What are the dominant operations? (insert, delete, search, range query)
- [ ] What is the expected data size?
- [ ] Is ordering required?
- [ ] Is thread safety needed?
- [ ] What is the memory budget?
- [ ] Does the target language have a built-in implementation?
