#!/bin/bash
set -e

echo "=== Batch 2 Pre-Check ==="

# 检查源码存在
if [ ! -d ".repo" ]; then
    echo "❌ 源码不存在，请先执行 sync"
    exit 1
fi
echo "✅ 源码存在"

# 检查构建环境
if [ ! -f "build/envsetup.sh" ]; then
    echo "❌ 构建环境未初始化"
    exit 1
fi
echo "✅ 构建环境存在"

# 检查磁盘空间 (需要 >20GB)
DISK_AVAIL=$(df -BG /workspace | tail -1 | awk '{print $4}' | tr -d 'G')
if [ "$DISK_AVAIL" -lt 20 ]; then
    echo "❌ 磁盘空间不足: ${DISK_AVAIL}GB (需要 >20GB)"
    exit 1
fi
echo "✅ 磁盘空间: ${DISK_AVAIL}GB"

# 检查必要工具
for tool in make gcc g++; do
    if ! command -v $tool &> /dev/null; then
        echo "❌ 缺少工具: $tool"
        exit 1
    fi
done
echo "✅ 构建工具完整"

echo "=== Batch 2 Pre-Check 通过 ==="
