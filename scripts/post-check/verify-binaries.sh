#!/bin/bash
set -e

OUT_DIR=${1:-out}
shift
BINARIES=("$@")

echo "=== Post-Check: Binary Verification ==="

for bin in "${BINARIES[@]}"; do
    echo "检查 $bin..."

    # 查找二进制
    BIN_PATH=$(find $OUT_DIR -name "${bin}*" -type f 2>/dev/null | head -1)

    if [ -z "$BIN_PATH" ]; then
        echo "❌ 未找到: $bin"
        exit 1
    fi

    echo "  ✅ 找到: $BIN_PATH"

    # 检查架构
    ARCH=$(file "$BIN_PATH" | grep -o "aarch64")
    if [ "$ARCH" != "aarch64" ]; then
        echo "  ❌ 架构错误: $(file "$BIN_PATH")"
        exit 1
    fi
    echo "  ✅ 架构正确: ARM64 (aarch64)"

    # 版本检查 (如果有)
    if [[ "$BIN_PATH" == *"clang"* ]]; then
        VERSION=$("$BIN_PATH" --version 2>/dev/null | head -1 || echo "unknown")
        echo "  ✅ 版本: $VERSION"
    fi
done

echo "=== Binary Verification Passed ==="
