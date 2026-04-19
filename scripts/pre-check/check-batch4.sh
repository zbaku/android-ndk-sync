#!/bin/bash
set -e

echo "=== Batch 4 Pre-Check ==="

# 检查构建产物
echo "1. 检查 out/ 目录..."
if [ ! -d "out/target/product" ]; then
    echo "❌ 构建产物不存在"
    exit 1
fi
echo "✅ out/ 存在"

# 检查必要产出
echo "2. 检查必要产出..."
for check in clang lld sysroot; do
    if ! find out/ -name "$check*" &> /dev/null; then
        echo "❌ 缺少: $check"
        exit 1
    fi
    echo "✅ $check 存在"
done

# 检查磁盘空间 (需要至少 2x 产出大小)
echo "3. 检查打包空间..."
SIZE=$(du -sm out/ | cut -f1)
AVAIL=$(df -BM /workspace | tail -1 | awk '{print $4}' | tr -d 'M')
if [ "$AVAIL" -lt $((SIZE * 2)) ]; then
    echo "❌ 空间不足: 需要 ~$((SIZE * 2))MB, 可用 ${AVAIL}MB"
    exit 1
fi
echo "✅ 打包空间足够"

echo "=== Batch 4 Pre-Check 通过 ==="
