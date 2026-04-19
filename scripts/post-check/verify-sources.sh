#!/bin/bash
set -e

SOURCE_DIR=${1:-/workspace/aosp-ndk}
NDK_VERSION=${2:-26}

echo "=== Post-Check: Source Verification ==="

# 检查目录结构
echo "1. 检查目录结构..."
REQUIRED_DIRS=(
    "ndk"
    "bionic"
    "prebuilts/ndk"
    "prebuilts/clang"
    "prebuilts/gcc"
)

for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "$SOURCE_DIR/$dir" ]; then
        echo "  ✅ $dir"
    else
        echo "  ❌ 缺少: $dir"
        exit 1
    fi
done

# 检查 Git 提交历史
echo "2. 检查 Git 历史..."
cd $SOURCE_DIR/.repo/manifests 2>/dev/null || cd $SOURCE_DIR
if [ -d ".git" ]; then
    LATEST_COMMIT=$(git log --oneline -1 2>/dev/null || echo "unknown")
    echo "  ✅ 最新提交: $LATEST_COMMIT"
else
    echo "  ⚠️ 非 Git 仓库，跳过"
fi

# 检查必要文件
echo "3. 检查必要文件..."
REQUIRED_FILES=(
    "ndk/source.properties"
    "bionic/Android.bp"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$SOURCE_DIR/$file" ]; then
        echo "  ✅ $file"
    else
        echo "  ⚠️ 缺少: $file (可能正常)"
    fi
done

# 检查磁盘使用
echo "4. 检查磁盘使用..."
SIZE=$(du -sh $SOURCE_DIR 2>/dev/null | cut -f1)
echo "  ✅ 源码大小: $SIZE"

echo "=== Source Verification Passed ==="
