#!/bin/bash
set -e

echo "=== NDK Build Libraries Script ==="

export NDK_VERSION=${NDK_VERSION:-26}

cd /workspace/aosp-ndk

echo "=== 1. Build libc++ ==="
make libc++ -j$(nproc)

echo "=== 2. Build sysroot headers ==="
make sysroot -j$(nproc)

echo "=== 3. Package headers ==="
mkdir -p /workspace/ndk-headers
cp -r prebuilts/ndk/**/sysroot/usr/include /workspace/ndk-headers/ 2>/dev/null || true

echo "=== 4. Post-Check ==="
if [ -f "../scripts/post-check/verify-libs.sh" ]; then
    ../scripts/post-check/verify-libs.sh out/
fi

echo "=== Build Libraries Complete ==="
