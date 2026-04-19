#!/bin/bash
set -e

echo "=== Setup ARM64 Cross-Compilation Toolchain ==="

TOOLCHAIN_DIR=${1:-/workspace/toolchains}
mkdir -p $TOOLCHAIN_DIR

echo "=== 1. Install ARM64 cross-compiler ==="
apt-get update && apt-get install -y \
    gcc-aarch64-linux-gnu \
    g++-aarch64-linux-gnu \
    libc6-dev-arm64-cross \
    binutils-aarch64-linux-gnu \
    libstdc++-arm64-cross

echo "=== 2. Install LLVM ARM64 backend ==="
apt-get install -y llvm llvm-aarch64-linux-gnu

echo "=== 3. Find and link toolchain ==="
# Find aarch64 gcc
AARCH64_GCC=$(which aarch64-linux-gnu-gcc)
AARCH64_GXX=$(which aarch64-linux-gnu-g++)

if [ -z "$AARCH64_GCC" ]; then
    echo "❌ aarch64-linux-gnu-gcc not found"
    exit 1
fi

echo "  ✅ aarch64-linux-gnu-gcc: $AARCH64_GCC"
echo "  ✅ aarch64-linux-gnu-g++: $AARCH64_GXX"

# Create symlinks for NDK-style paths
mkdir -p $TOOLCHAIN_DIR/llvm/prebuilt/linux-aarch_64/bin
ln -sf $(dirname $AARCH64_GCC)/* $TOOLCHAIN_DIR/llvm/prebuilt/linux-aarch_64/bin/
ln -sf $(dirname $AARCH64_GXX)/* $TOOLCHAIN_DIR/llvm/prebuilt/linux-aarch_64/bin/

# Copy sysroot
SYSROOT=/usr/aarch64-linux-gnu
mkdir -p $TOOLCHAIN_DIR/llvm/prebuilt/linux-aarch_64/sysroot
cp -r $SYSROOT/* $TOOLCHAIN_DIR/llvm/prebuilt/linux-aarch_64/sysroot/ 2>/dev/null || true

echo "=== 4. Environment variables ==="
cat << 'ENV'
export TOOLCHAIN_DIR=/workspace/toolchains
export PATH="\${TOOLCHAIN_DIR}/llvm/prebuilt/linux-aarch_64/bin:\$PATH"
export CC=aarch64-linux-gnu-gcc
export CXX=aarch64-linux-gnu-g++
export SYSROOT=\${TOOLCHAIN_DIR}/llvm/prebuilt/linux-aarch_64/sysroot
export TARGET=aarch64-linux-android
export API=26
ENV

echo "=== 5. Verify installation ==="
echo "aarch64-linux-gnu-gcc version:"
aarch64-linux-gnu-gcc --version | head -1

echo ""
echo "=== Toolchain Setup Complete ==="
echo "Add to your scripts:"
echo "  source /workspace/android-ndk-sync/scripts/setup-toolchain.sh"
