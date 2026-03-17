# Skill: Python Testing

## Trigger

When testing Python code.

## pytest Essentials

### Basic Test Structure

```python
import pytest
from mypackage.core import compute

class TestCompute:
    def test_normal_input(self):
        assert compute([1, 2, 3]) == 6

    def test_empty_input(self):
        assert compute([]) == 0

    def test_negative_values(self):
        assert compute([-1, -2]) == -3

    def test_invalid_type(self):
        with pytest.raises(TypeError):
            compute("not a list")
```

### Parametrize (Multiple Cases)

```python
@pytest.mark.parametrize("input_data, expected", [
    ([1, 2, 3], 6),
    ([], 0),
    ([0], 0),
    ([-1, 1], 0),
    ([1e10, 1e-10], 1e10),  # floating point
])
def test_compute(input_data, expected):
    assert compute(input_data) == pytest.approx(expected)
```

### Fixtures

```python
@pytest.fixture
def sample_data():
    return {"values": [1.0, 2.0, 3.0], "weights": [0.5, 0.3, 0.2]}

@pytest.fixture
def temp_file(tmp_path):
    f = tmp_path / "test_data.csv"
    f.write_text("a,b\n1,2\n3,4\n")
    return f

def test_with_fixture(sample_data):
    result = process(sample_data["values"])
    assert result > 0
```

### Mocking

```python
from unittest.mock import patch, MagicMock

def test_api_call():
    with patch("mypackage.client.requests.get") as mock_get:
        mock_get.return_value.json.return_value = {"status": "ok"}
        result = fetch_status()
        assert result == "ok"
        mock_get.assert_called_once()
```

## Coverage

```bash
pytest --cov=mypackage --cov-report=term-missing --cov-fail-under=80
```

## Performance Benchmark

```python
import pytest

@pytest.mark.benchmark
def test_sort_performance(benchmark):
    data = list(range(10000, 0, -1))
    result = benchmark(sorted, data)
    assert result == list(range(1, 10001))
```

## Running Tests

```bash
pytest                          # all tests
pytest tests/test_core.py       # specific file
pytest -k "test_compute"        # by name pattern
pytest -x                       # stop on first failure
pytest -v --tb=short            # verbose, short traceback
pytest --durations=10           # slowest 10 tests
```
