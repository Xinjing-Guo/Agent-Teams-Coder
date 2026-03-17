# Skill: 多语言编码

## 触发条件

当需要用指定语言实现算法或功能时使用。

## 语言选择指南

| 场景          | 推荐语言   | 理由                      |
| ------------- | ---------- | ------------------------- |
| 数据处理/脚本 | Python     | 生态丰富，开发快          |
| 高性能计算    | C/C++      | 控制底层，最快            |
| 统计分析      | R          | 统计生态最强              |
| 科学计算      | Julia      | 接近 C 性能，写法接近数学 |
| 自动化/运维   | Shell      | 系统集成最便捷            |
| 通用后端      | Python/C++ | 视性能需求选择            |

## 编码检查清单（每次提交前必查）

- [ ] 函数有文档字符串/注释
- [ ] 变量命名有意义
- [ ] 边界条件已处理（空输入、越界、类型错误）
- [ ] 无硬编码魔法数字
- [ ] 异常处理具体（非裸 except）
- [ ] 内存安全（C/C++: 分配对应释放）
- [ ] 已自测通过基本用例

## 多语言模板

### Python

```python
"""模块说明."""
import logging
from typing import ...

logger = logging.getLogger(__name__)

def function_name(param: type) -> return_type:
    """功能说明.

    Args:
        param: 参数说明.

    Returns:
        返回值说明.

    Raises:
        ValueError: 异常条件.
    """
    ...
```

### C

```c
/**
 * @brief 功能说明
 * @param param 参数说明
 * @return 返回值说明
 */
type function_name(type param) {
    if (param == NULL) { return ERROR; }
    ...
}
```

### C++

```cpp
/**
 * @brief 功能说明
 */
auto function_name(const Type& param) -> ReturnType {
    ...
}
```

### R

```r
#' 功能说明
#' @param param 参数说明
#' @return 返回值说明
#' @export
function_name <- function(param) {
    ...
}
```

### Julia

```julia
"""
    function_name(param::Type) -> ReturnType

功能说明.
"""
function function_name(param::Type)::ReturnType
    ...
end
```

### Shell

```bash
#!/bin/bash
set -euo pipefail

# 功能说明
# 用法: script.sh <arg>
function_name() {
    local param="$1"
    ...
}
```
