#!/bin/bash
set -e

echo "=== Setup NDK Build Environment (ARM64 Native) ==="

WORKSPACE=${1:-/workspace}
BUILD_DIR=$WORKSPACE/build-tools
mkdir -p $BUILD_DIR

export DEBIAN_FRONTEND=noninteractive

echo "=== 0. Go (Required for AOSP soong/blueprint) ==="
apt-get install -y golang-go

echo "=== 1. Core Build Tools ==="
apt-get update
apt-get install -y \
    build-essential \
    cmake \
    ninja-build \
    pkg-config \
    python3 \
    python3-pip \
    curl \
    wget \
    git \
    rsync \
    tar \
    gzip \
    xz-utils \
    zip \
    unzip \
    ccache \
    automake \
    autoconf \
    libtool \
    bison \
    flex \
    gperf \
    bup \
    ncurses-dev

echo "=== 2. Go (for AOSP soong/blueprint) ==="
apt-get install -y golang-go

echo "=== 3. Java JDK (Required for Android builds) ==="
apt-get install -y openjdk-17-jdk
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-arm64
echo "  ✅ JAVA_HOME=$JAVA_HOME"

echo "=== 4. LLVM/Clang (ARM64 Native - Primary) ==="
apt-get install -y llvm llvm-dev clang lld

echo "=== 5. Native ARM64 Libraries ==="
apt-get install -y \
    libc6-dev-arm64 \
    zlib1g-dev \
    libssl-dev \
    libtinfo-dev \
    libffi-dev \
    python3-dev \
    uuid-dev \
    libncurses-dev

echo "=== 6. ARM64 GCC (Fallback/Backup) ==="
apt-get install -y \
    gcc-aarch64-linux-gnu \
    g++-aarch64-linux-gnu \
    libc6-dev-arm64-cross \
    binutils-aarch64-linux-gnu \
    libstdc++-arm64-cross

echo "=== 7. Create NDK-style Directory Structure ==="
NDK_TOOLCHAIN=$BUILD_DIR/ndk-toolchain
mkdir -p $NDK_TOOLCHAIN/llvm/prebuilt/linux-aarch_64/bin
mkdir -p $NDK_TOOLCHAIN/llvm/prebuilt/linux-aarch_64/sysroot

# Link primary tools (clang)
ln -sf /usr/bin/clang $NDK_TOOLCHAIN/llvm/prebuilt/linux-aarch_64/bin/clang 2>/dev/null || true
ln -sf /usr/bin/clang++ $NDK_TOOLCHAIN/llvm/prebuilt/linux-aarch_64/bin/clang++ 2>/dev/null || true
ln -sf /usr/bin/llvm-ar $NDK_TOOLCHAIN/llvm/prebuilt/linux-aarch_64/bin/llvm-ar 2>/dev/null || true
ln -sf /usr/bin/ld.lld $NDK_TOOLCHAIN/llvm/prebuilt/linux-aarch_64/bin/ld.lld 2>/dev/null || true

# Link fallback tools (gcc-aarch64)
ln -sf /usr/bin/aarch64-linux-gnu-gcc $NDK_TOOLCHAIN/llvm/prebuilt/linux-aarch_64/bin/aarch64-linux-gnu-gcc 2>/dev/null || true
ln -sf /usr/bin/aarch64-linux-gnu-g++ $NDK_TOOLCHAIN/llvm/prebuilt/linux-aarch_64/bin/aarch64-linux-gnu-g++ 2>/dev/null || true
ln -sf /usr/bin/aarch64-linux-gnu-ar $NDK_TOOLCHAIN/llvm/prebuilt/linux-aarch_64/bin/aarch64-linux-gnu-ar 2>/dev/null || true

# Copy sysroot
cp -ra /usr/aarch64-linux-gnu/* $NDK_TOOLCHAIN/llvm/prebuilt/linux-aarch_64/sysroot/ 2>/dev/null || true

echo "=== 8. Create Build Environment Script ==="
cat > $BUILD_DIR/envsetup.sh << 'ENV'
#!/bin/bash
export WORKSPACE=${WORKSPACE:-/workspace}
export BUILD_DIR=$WORKSPACE/build-tools
export NDK_TOOLCHAIN=$BUILD_DIR/ndk-toolchain
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-arm64

# Primary: Native ARM64 LLVM tools
export LLVM_ROOT=/usr/lib/llvm
export PATH=$LLVM_ROOT/bin:/usr/bin:/bin:$PATH
export CC=clang
export CXX=clang++
export AR=llvm-ar
export LD=ld.lld
export LLD=ld.lld

# Fallback: ARM64 GCC (if LLVM unavailable)
export CROSS_ROOT=$NDK_TOOLCHAIN/llvm/prebuilt/linux-aarch_64
export PATH=$CROSS_ROOT/bin:$PATH
export CC=gcc
export CXX=g++
export AR=ar
export LD=ld

# ccache
export CCACHE_DIR=/workspace/ccache
export CCACHE_SIZE=10G

echo "NDK Build Environment configured:"
echo "  Primary: clang/llvm (ARM64 native)"
echo "  Fallback: gcc-aarch64-linux-gnu"
echo "  CC=$CC"
echo "  JAVA_HOME=$JAVA_HOME"
ENV

chmod +x $BUILD_DIR/envsetup.sh

echo "=== 9. Verify Installations ==="
echo ""
echo "Primary (LLVM):"
echo "  clang: $(which clang || echo 'not found')"
echo "  lld: $(which lld || echo 'not found')"
echo ""
echo "Fallback (GCC):"
echo "  aarch64-linux-gnu-gcc: $(which aarch64-linux-gnu-gcc || echo 'not found')"
echo ""
echo "Java:"
java -version 2>&1 | head -1
echo ""
echo "Python:"
python3 --version
echo ""
echo "=== Build Environment Setup Complete ==="
echo ""
echo "To activate, run:"
echo "  source $BUILD_DIR/envsetup.sh"
