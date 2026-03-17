# Skill: Changelog Generation

## Trigger

When a task completes and changes need to be documented for version tracking.

## Changelog Format (Keep a Changelog)

```markdown
# Changelog

All notable changes to this project are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/).

## [Unreleased]

### Added

- New sorting algorithm with O(n log n) guaranteed performance
- Python and C dual-language implementation

### Changed

- Improved memory efficiency of merge step by 40%

### Fixed

- Buffer overflow in C implementation for arrays > 10M elements
- Off-by-one error in boundary check

### Removed

- Deprecated bubble sort fallback

## [1.0.0] - 2026-03-17

### Added

- Initial release with quicksort and mergesort
- Python package with type hints
- C library with CMake build
- Test suite with 95% coverage
- Complete documentation (4-chapter manual)
```

## Categories

| Category       | When to Use                             |
| -------------- | --------------------------------------- |
| **Added**      | New features, new functions, new files  |
| **Changed**    | Modifications to existing functionality |
| **Deprecated** | Features marked for future removal      |
| **Removed**    | Features deleted in this version        |
| **Fixed**      | Bug fixes                               |
| **Security**   | Vulnerability patches                   |

## Versioning (Semantic)

```
MAJOR.MINOR.PATCH

MAJOR: breaking API changes (function signature changed, removed function)
MINOR: new features, backward compatible
PATCH: bug fixes, no API changes
```

## Auto-Generation Process

1. Collect all team activities from activity log
2. Categorize each change (Added/Changed/Fixed/etc.)
3. Write user-facing descriptions (not internal implementation details)
4. Order by importance within each category
5. Include attribution: "Based on Euler's algorithm design" etc.
