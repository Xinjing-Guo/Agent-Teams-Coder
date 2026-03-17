# Skill: Performance Testing

## Trigger

When validating code performance, identifying bottlenecks, or establishing benchmarks.

## Benchmarking Methodology

1. **Warmup**: Run function 3-5 times before measuring (JIT, cache effects)
2. **Repeat**: Measure N>=100 iterations for stable statistics
3. **Report**: median (not mean) + IQR or std dev
4. **Compare**: always compare against a baseline
5. **Scale**: test at 10x, 100x, 1000x input size to verify complexity

## Language-Specific Tools

### Python

```python
import timeit
import tracemalloc

# Timing
time = timeit.timeit(lambda: my_sort(data.copy()), number=1000)

# Memory
tracemalloc.start()
result = my_function(large_data)
current, peak = tracemalloc.get_traced_memory()
tracemalloc.stop()
print(f"Peak memory: {peak / 1024:.1f} KB")

# pytest-benchmark
def test_sort_perf(benchmark):
    data = list(range(10000, 0, -1))
    benchmark(my_sort, data)
```

### C/C++

```c
#include <time.h>

clock_t start = clock();
for (int i = 0; i < ITERATIONS; i++) {
    my_sort(data, n);
}
double elapsed = (double)(clock() - start) / CLOCKS_PER_SEC / ITERATIONS;
printf("Average: %.6f seconds\n", elapsed);
```

```bash
# Profiling
gcc -pg -O2 main.c -o main && ./main && gprof main gmon.out
# Memory profiling
valgrind --tool=massif ./main && ms_print massif.out.*
```

### Julia

```julia
using BenchmarkTools
@benchmark my_sort(data) setup=(data=rand(10000))
```

## Performance Report Template

```markdown
## Performance Report — [Module]

### Environment

- CPU: [model]
- RAM: [size]
- OS: [version]
- Compiler/Runtime: [version + flags]

### Benchmarks

| Function | Input Size | Time (median) | Memory (peak) | Complexity (observed) |
| -------- | ---------- | ------------- | ------------- | --------------------- |
| sort     | 1,000      | 0.12 ms       | 8 KB          | —                     |
| sort     | 10,000     | 1.3 ms        | 80 KB         | ~O(n log n)           |
| sort     | 100,000    | 15.1 ms       | 800 KB        | ~O(n log n) ✓         |

### Scaling Analysis

[Does measured scaling match Euler's predicted complexity?]

### Bottlenecks Identified

1. [Function/line]: [issue], accounts for X% of runtime
2. [Memory allocation pattern]: [peak usage concern]

### Recommendations

1. [Optimization suggestion]
```

## Red Flags

- Time grows faster than expected complexity → algorithm issue, report to Euler
- Memory grows linearly when it shouldn't → leak, report to Forge
- Performance varies >20% between runs → measurement issue, increase iterations
