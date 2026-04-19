#!/bin/bash
set -e

echo "=== Batch 3 Pre-Check ==="

# 检查 clang 是否已构建
echo "1. 检查 clang..."
if ! find out/ -name "clang*" -type f &> /dev/null; then
    echo "❌ clang 未构建，请先执行 build-core"
    exit 1
fi
echo "✅ clang 已构建"

# 检查 lld
echo "2. 检查 lld..."
if ! find out/ -name "lld" -type f &> /dev/null; then
    echo "❌ lld 未构建"
    exit 1
fi
echo "✅ lld 已构建"

# 检查 llvm-ar
echo "3. 检查 llvm-ar..."
if ! find out/ -name "llvm-ar" -type f &> /dev/null; then
    echo "❌ llvm-ar 未构建"
    exit 1
fi
echo "✅ llvm-ar 已构建"

echo "=== Batch 3 Pre-Check 通过 ==="
