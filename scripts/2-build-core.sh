#!/bin/bash
set -e

echo "=== NDK Build Core Script ==="

export NDK_VERSION=${NDK_VERSION:-26}
export BUILD_TARGET=${BUILD_TARGET:-sdk_phone64_arm64-userdebug}
export CCACHE_DIR=${CCACHE_DIR:-/workspace/ccache}

echo "NDK Version: $NDK_VERSION"
echo "Build Target: $BUILD_TARGET"

cd /workspace/aosp-ndk

echo "=== 1. Setup build env ==="
source build/envsetup.sh
lunch $BUILD_TARGET

ccache -M 10G

echo "=== 2. Build clang ==="
make clang -j$(nproc)

echo "=== 3. Build lld ==="
make lld -j$(nproc)

echo "=== 4. Build llvm-ar ==="
make llvm-ar -j$(nproc)

echo "=== 5. Post-Check ==="
if [ -f "../scripts/post-check/verify-binaries.sh" ]; then
    ../scripts/post-check/verify-binaries.sh out/ clang lld llvm-ar
fi

echo "=== Build Core Complete ==="
