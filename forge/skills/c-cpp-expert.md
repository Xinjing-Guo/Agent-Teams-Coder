# Skill: C/C++ Expert

## Trigger

When implementing in C or C++.

## C — Safety Checklist

- [ ] Every `malloc` has matching `free`
- [ ] Every array access checks bounds
- [ ] Every pointer checked for NULL before dereference
- [ ] No buffer overflows in `strcpy`/`sprintf` (use `strncpy`/`snprintf`)
- [ ] No use-after-free
- [ ] No uninitialized variables
- [ ] Return values of system calls checked

### Memory Pattern

```c
int *buf = malloc(n * sizeof(*buf));  /* sizeof the pointer target */
if (!buf) { return -ENOMEM; }
/* ... use buf ... */
free(buf);
buf = NULL;  /* prevent use-after-free */
```

### Error Handling (goto cleanup)

```c
int process(const char *path) {
    int ret = -1;
    FILE *fp = fopen(path, "r");
    if (!fp) goto cleanup;

    char *buf = malloc(BUF_SIZE);
    if (!buf) goto close_file;

    /* ... work ... */
    ret = 0;

    free(buf);
close_file:
    fclose(fp);
cleanup:
    return ret;
}
```

## C++ — Modern Practices (C++17+)

### RAII / Smart Pointers

```cpp
#include <memory>
auto ptr = std::make_unique<Widget>(args...);   // exclusive ownership
auto shared = std::make_shared<Widget>(args...); // shared ownership
// Never use raw new/delete in application code
```

### Value Semantics

```cpp
// Pass by const reference for read-only
void process(const std::vector<int>& data);
// Return by value (move semantics handle efficiency)
std::vector<int> generate();
// Use std::string_view for non-owning string access
void log(std::string_view message);
```

### Error Handling

```cpp
// Use std::optional for "might not have a value"
std::optional<int> find(const std::string& key);
// Use std::expected (C++23) or exceptions for errors
// Never use error codes in C++ unless interfacing with C
```

### Containers

| Need                | Container                   |
| ------------------- | --------------------------- |
| Dynamic array       | `std::vector`               |
| Key-value (ordered) | `std::map`                  |
| Key-value (fast)    | `std::unordered_map`        |
| Set                 | `std::unordered_set`        |
| Queue               | `std::queue` / `std::deque` |
| Priority queue      | `std::priority_queue`       |
| Fixed-size array    | `std::array`                |

## Build Systems

```cmake
# CMakeLists.txt (modern CMake 3.14+)
cmake_minimum_required(VERSION 3.14)
project(mylib VERSION 1.0 LANGUAGES C CXX)
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

add_library(mylib src/core.c src/algo.cpp)
target_include_directories(mylib PUBLIC include/)

# Sanitizers for debug
target_compile_options(mylib PRIVATE
    $<$<CONFIG:Debug>:-fsanitize=address,undefined -g>)
```

## Debugging Tools

| Tool                       | Purpose                         |
| -------------------------- | ------------------------------- |
| valgrind --leak-check=full | Memory leak detection           |
| -fsanitize=address         | Buffer overflow, use-after-free |
| -fsanitize=undefined       | Undefined behavior              |
| gdb / lldb                 | Interactive debugger            |
| clang-tidy                 | Static analysis                 |
