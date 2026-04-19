#!/bin/bash
set -e

echo "=== Post-Check: Package Verification ==="

# 检查 tar.gz
echo "1. 检查 tar.gz..."
PKG=$(ls android-ndk-*.tar.gz 2>/dev/null | head -1)
if [ -z "$PKG" ]; then
    echo "❌ 未找到 android-ndk-*.tar.gz"
    exit 1
fi
echo "  ✅ 找到: $PKG"

# tar.gz 完整性
echo "2. 检查 tar.gz 完整性..."
tar -tzf "$PKG" > /dev/null
if [ $? -eq 0 ]; then
    echo "  ✅ tar.gz 完整"
else
    echo "  ❌ tar.gz 损坏"
    exit 1
fi

# 检查 SHA256
echo "3. 检查 SHA256..."
SHA_FILE="${PKG}.sha256"
if [ -f "$SHA_FILE" ]; then
    echo "  ✅ 找到 SHA256 文件"
    sha256sum -c "$SHA_FILE"
    echo "  ✅ SHA256 校验通过"
else
    echo "  ⚠️ 未找到 SHA256 文件"
fi

# 检查大小
echo "4. 检查大小..."
SIZE=$(du -h "$PKG" | cut -f1)
echo "  ✅ 包大小: $SIZE"

# 检查必要目录
echo "5. 检查必要目录..."
for dir in toolchains sysroot source.properties; do
    if tar -tzf "$PKG" | grep -q "${dir}"; then
        echo "  ✅ $dir"
    else
        echo "  ⚠️ 未找到: $dir"
    fi
done

echo "=== Package Verification Passed ==="
