# Skill: API Documentation

## Trigger

When documenting public functions, classes, modules, or CLI interfaces.

## Function Documentation Template

````markdown
### `function_name(param1, param2, *, keyword_only)`

**Description**: One clear sentence about what this function does.

**Parameters**:
| Name | Type | Default | Description |
|------|------|---------|-------------|
| `param1` | `list[float]` | — (required) | Input data array |
| `param2` | `str` | `"auto"` | Algorithm selection |
| `keyword_only` | `bool` | `False` | Enable verbose output |

**Returns**:
| Type | Description |
|------|-------------|
| `dict[str, float]` | Results with keys: `mean`, `std`, `max` |

**Raises**:
| Exception | Condition |
|-----------|-----------|
| `ValueError` | If `param1` is empty |
| `TypeError` | If `param1` contains non-numeric values |

**Example**:

```python
>>> result = function_name([1.0, 2.0, 3.0])
>>> print(result)
{'mean': 2.0, 'std': 0.816, 'max': 3.0}
```
````

**Notes**:

- Thread-safe: Yes
- Complexity: O(n)
- Since: v1.0.0

````

## CLI Documentation Template

```markdown
### `command_name`

**Usage**: `program command_name [OPTIONS] <INPUT>`

**Description**: What this command does.

**Arguments**:
| Argument | Required | Description |
|----------|----------|-------------|
| `INPUT` | Yes | Input file path |

**Options**:
| Flag | Short | Default | Description |
|------|-------|---------|-------------|
| `--output` | `-o` | stdout | Output file path |
| `--format` | `-f` | `json` | Output format (json/csv/table) |
| `--verbose` | `-v` | off | Enable verbose logging |

**Examples**:
```bash
# Basic usage
program command_name data.csv

# With options
program command_name -o result.json -f json data.csv
````

**Exit Codes**:
| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | Invalid input |
| 2 | Runtime error |

````

## Module Overview Template

```markdown
## Module: `module_name`

**Purpose**: One sentence.

**Public API**:
| Symbol | Type | Description |
|--------|------|-------------|
| `ClassName` | class | Main processor |
| `function_a` | function | Helper for X |
| `CONSTANT` | const | Default threshold value |

**Dependencies**: `numpy`, `scipy.optimize`

**Usage**:
```python
from mypackage.module_name import ClassName
obj = ClassName(config)
result = obj.process(data)
````

```

## Checklist
- [ ] Every public function/class documented
- [ ] Every parameter has type + description
- [ ] At least one runnable example per function
- [ ] Exceptions documented
- [ ] Return types documented
- [ ] Examples are copy-paste-ready
```
