#!/bin/bash
set -e

NDK_DIR=${1:-/workspace/android-ndk}

echo "=== NDK 功能测试 ==="

# 设置 PATH (根据实际路径调整)
export PATH="${NDK_DIR}/toolchains/llvm/prebuilt/linux-aarch_64/bin:${PATH}"

# 1. 简单 C 编译测试
echo "1. 测试 C 编译..."
cat > /tmp/test.c << 'EOF'
#include <stdio.h>
int main() {
    printf("Hello from NDK!\n");
    return 0;
}
EOF

clang --target=aarch64-linux-android /tmp/test.c -o /tmp/test
/tmp/test
echo "✅ C 编译测试通过"

# 2. C++ 编译测试
echo "2. 测试 C++ 编译..."
cat > /tmp/testcpp.cpp << 'EOF'
#include <iostream>
int main() {
    std::cout << "Hello from NDK C++!" << std::endl;
    return 0;
}
EOF

clang++ --target=aarch64-linux-android /tmp/testcpp.cpp -o /tmp/testcpp -lc++
/tmp/testcpp
echo "✅ C++ 编译测试通过"

# 3. 汇编测试
echo "3. 测试汇编..."
cat > /tmp/test.s << 'EOF'
.section __TEXT,__text
.globl _main
_main:
    mov x0, #0
    ret
EOF

clang --target=aarch64-linux-android /tmp/test.s -o /tmp/test_asm
echo "✅ 汇编测试通过"

# 4. 静态库测试
echo "4. 测试静态库创建..."
echo "int add(int a, int b) { return a + b; }" > /tmp/add.c
clang -c /tmp/add.c -o /tmp/add.o
ar rcs /tmp/libadd.a /tmp/add.o
echo "✅ 静态库创建测试通过"

echo ""
echo "=== 所有功能测试通过 ==="
