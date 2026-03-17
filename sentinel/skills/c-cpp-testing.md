# Skill: C/C++ Testing

## Trigger

When testing C or C++ code.

## Google Test (C++)

```cpp
#include <gtest/gtest.h>
#include "mylib.h"

TEST(SortTest, EmptyArray) {
    std::vector<int> v;
    my_sort(v);
    EXPECT_TRUE(v.empty());
}

TEST(SortTest, AlreadySorted) {
    std::vector<int> v = {1, 2, 3, 4, 5};
    my_sort(v);
    EXPECT_EQ(v, (std::vector<int>{1, 2, 3, 4, 5}));
}

TEST(SortTest, ReverseSorted) {
    std::vector<int> v = {5, 4, 3, 2, 1};
    my_sort(v);
    EXPECT_EQ(v, (std::vector<int>{1, 2, 3, 4, 5}));
}

TEST(SortTest, Duplicates) {
    std::vector<int> v = {3, 1, 3, 2, 1};
    my_sort(v);
    EXPECT_EQ(v, (std::vector<int>{1, 1, 2, 3, 3}));
}

// Parameterized test
class FibTest : public testing::TestWithParam<std::pair<int, int>> {};

TEST_P(FibTest, Values) {
    auto [input, expected] = GetParam();
    EXPECT_EQ(fibonacci(input), expected);
}

INSTANTIATE_TEST_SUITE_P(Fibonacci, FibTest, testing::Values(
    std::make_pair(0, 0), std::make_pair(1, 1),
    std::make_pair(10, 55), std::make_pair(20, 6765)
));
```

## CUnit (C)

```c
#include <CUnit/CUnit.h>
#include <CUnit/Basic.h>
#include "mylib.h"

void test_sort_empty(void) {
    int arr[] = {};
    my_sort(arr, 0);
    CU_ASSERT_EQUAL(0, 0);  /* no crash */
}

void test_sort_single(void) {
    int arr[] = {42};
    my_sort(arr, 1);
    CU_ASSERT_EQUAL(arr[0], 42);
}

int main(void) {
    CU_initialize_registry();
    CU_pSuite suite = CU_add_suite("Sort", NULL, NULL);
    CU_add_test(suite, "empty", test_sort_empty);
    CU_add_test(suite, "single", test_sort_single);
    CU_basic_run_tests();
    CU_cleanup_registry();
    return CU_get_error();
}
```

## Memory Analysis

### Valgrind

```bash
# Leak check
valgrind --leak-check=full --show-leak-kinds=all ./test_runner

# Expected output for clean code:
# All heap blocks were freed -- no leaks are possible
```

### AddressSanitizer (compile-time)

```bash
gcc -fsanitize=address -g -O1 test.c -o test_asan
./test_asan
# Reports buffer overflows, use-after-free, memory leaks at runtime
```

### UndefinedBehaviorSanitizer

```bash
gcc -fsanitize=undefined -g test.c -o test_ubsan
# Detects: integer overflow, null dereference, misaligned access
```

## CMake Integration

```cmake
enable_testing()
find_package(GTest REQUIRED)
add_executable(tests tests/test_sort.cpp)
target_link_libraries(tests PRIVATE mylib GTest::gtest_main)
add_test(NAME unit_tests COMMAND tests)

# With valgrind
find_program(VALGRIND valgrind)
if(VALGRIND)
    add_test(NAME memcheck
        COMMAND ${VALGRIND} --leak-check=full $<TARGET_FILE:tests>)
endif()
```
