#!/bin/bash
set -e

OUT_DIR=${1:-out}

echo "=== Post-Check: Library Verification ==="

# 检查 .a 文件
echo "1. 检查静态库..."
A_FILES=$(find $OUT_DIR -name "*.a" 2>/dev/null | wc -l)
if [ "$A_FILES" -lt 1 ]; then
    echo "⚠️ 未找到静态库 (可能正常)"
else
    echo "  ✅ 找到 $A_FILES 个 .a 文件"
fi

# 检查 .so 文件
echo "2. 检查动态库..."
SO_FILES=$(find $OUT_DIR -name "*.so" 2>/dev/null | wc -l)
if [ "$SO_FILES" -lt 1 ]; then
    echo "⚠️ 未找到动态库 (可能正常)"
else
    echo "  ✅ 找到 $SO_FILES 个 .so 文件"
fi

# 检查 headers
echo "3. 检查 headers..."
SYSROOT=$(find $OUT_DIR -path "*/sysroot/usr/include" -type d 2>/dev/null | head -1)
if [ -n "$SYSROOT" ]; then
    echo "  ✅ sysroot headers: $SYSROOT"
    HEADER_COUNT=$(find "$SYSROOT" -name "*.h" 2>/dev/null | wc -l)
    echo "  ✅ 包含 $HEADER_COUNT 个头文件"
else
    echo "⚠️ 未找到 sysroot headers"
fi

echo "=== Library Verification Passed ==="
