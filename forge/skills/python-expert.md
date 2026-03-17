# Skill: Python Expert

## Trigger

When implementing in Python.

## Project Setup

```bash
# Standard project layout
project/
├── pyproject.toml          # Use modern packaging
├── src/
│   └── package_name/
│       ├── __init__.py
│       └── module.py
├── tests/
│   ├── conftest.py
│   └── test_module.py
└── README.md
```

## Type Hints (Always Use)

```python
from typing import Optional, Union, TypeVar, Generic
from collections.abc import Sequence, Mapping, Iterator

def process(data: list[float], threshold: float = 0.5) -> dict[str, float]:
    ...

T = TypeVar("T")
class Container(Generic[T]):
    def get(self) -> T: ...
```

## Patterns

### Context Managers

```python
from contextlib import contextmanager

@contextmanager
def managed_resource(path: str):
    resource = acquire(path)
    try:
        yield resource
    finally:
        resource.close()
```

### Dataclasses over raw dicts

```python
from dataclasses import dataclass, field

@dataclass
class Config:
    learning_rate: float = 0.001
    epochs: int = 100
    layers: list[int] = field(default_factory=lambda: [64, 32])
```

### Logging (never print)

```python
import logging
logger = logging.getLogger(__name__)
logger.info("Processing %d items", len(items))
```

### Error Handling

```python
# Specific exceptions, never bare except
try:
    result = compute(data)
except ValueError as e:
    logger.error("Invalid data: %s", e)
    raise
except (IOError, OSError) as e:
    logger.warning("I/O issue: %s", e)
    return fallback_value
```

## Performance Tips

- `numpy` for numerical arrays (avoid Python loops over numbers)
- `collections.defaultdict` / `Counter` for counting
- Generator expressions for large sequences: `sum(x**2 for x in data)`
- `functools.lru_cache` for memoization
- `multiprocessing.Pool` for CPU-bound parallelism
- Profile first: `python -m cProfile script.py`

## Libraries by Domain

| Domain    | Library                |
| --------- | ---------------------- |
| Numerical | numpy, scipy           |
| Data      | pandas, polars         |
| Plotting  | matplotlib, seaborn    |
| ML        | scikit-learn, torch    |
| CLI       | argparse, click, typer |
| HTTP      | requests, httpx        |
| Async     | asyncio, aiohttp       |
| Testing   | pytest, hypothesis     |
