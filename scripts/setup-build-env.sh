#!/bin/bash
set -e

echo "=== Setup Complete NDK Build Environment ==="

WORKSPACE=${1:-/workspace}
BUILD_DIR=$WORKSPACE/build-tools
mkdir -p $BUILD_DIR

export DEBIAN_FRONTEND=noninteractive

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
    bup

echo "=== 2. Java JDK (Required for Android builds) ==="
apt-get install -y openjdk-17-jdk
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-arm64
echo "  ✅ JAVA_HOME=$JAVA_HOME"

echo "=== 3. ARM64 Cross-Compilation Toolchain ==="
apt-get install -y \
    gcc-aarch64-linux-gnu \
    g++-aarch64-linux-gnu \
    libc6-dev-arm64-cross \
    binutils-aarch64-linux-gnu \
    libstdc++-arm64-cross

echo "=== 4. LLVM/Clang (ARM64 native) ==="
apt-get install -y llvm llvm-dev clang lld

echo "=== 5. Android NDK Specific Tools ==="
apt-get install -y \
    libc6-dev-arm64-cross \
    zlib1g-dev-arm64-cross \
    libssl-dev-arm64-cross

echo "=== 6. Create NDK-style Directory Structure ==="
NDK_TOOLCHAIN=$BUILD_DIR/ndk-toolchain
mkdir -p $NDK_TOOLCHAIN/llvm/prebuilt/linux-aarch_64

# Link ARM64 GCC to NDK structure
echo "  Creating NDK-style toolchain links..."
for tool in aarch64-linux-gnu-gcc aarch64-linux-gnu-g++ aarch64-linux-gnu-ar aarch64-linux-gnu-ld; do
    ln -sf $(which $tool) $NDK_TOOLCHAIN/llvm/prebuilt/linux-aarch_64/bin/${tool} 2>/dev/null || true
done

# Copy sysroot
SYSROOT=/usr/aarch64-linux-gnu
mkdir -p $NDK_TOOLCHAIN/llvm/prebuilt/linux-aarch_64/sysroot
cp -ra $SYSROOT/* $NDK_TOOLCHAIN/llvm/prebuilt/linux-aarch_64/sysroot/ 2>/dev/null || true

echo "=== 7. Environment Variables ==="
cat > $BUILD_DIR/envsetup.sh << 'ENV'
#!/bin/bash
export WORKSPACE=${WORKSPACE:-/workspace}
export BUILD_DIR=$WORKSPACE/build-tools
export NDK_TOOLCHAIN=$BUILD_DIR/ndk-toolchain
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-arm64

# ARM64 Cross-Compiler
export CROSS_ROOT=$NDK_TOOLCHAIN/llvm/prebuilt/linux-aarch_64
export PATH=$CROSS_ROOT/bin:$PATH
export CC=aarch64-linux-gnu-gcc
export CXX=aarch64-linux-gnu-g++
export AR=aarch64-linux-gnu-ar
export LD=aarch64-linux-gnu-ld
export SYSROOT=$CROSS_ROOT/sysroot
export TARGET=aarch64-linux-gnu

# Native tools
export PATH=$BUILD_DIR/ndk-toolchain/bin:$PATH

# ccache
export CCACHE_DIR=/workspace/ccache
export CCACHE_SIZE=10G

echo "NDK Build Environment configured:"
echo "  CC=$CC"
echo "  CXX=$CXX"
echo "  SYSROOT=$SYSROOT"
echo "  JAVA_HOME=$JAVA_HOME"
ENV

chmod +x $BUILD_DIR/envsetup.sh

echo "=== 8. Verify Installations ==="
echo ""
echo "Native tools:"
echo "  clang: $(which clang || echo 'not found')"
echo "  lld: $(which lld || echo 'not found')"
echo "  ninja: $(which ninja || echo 'not found')"
echo ""
echo "Cross-compiler:"
aarch64-linux-gnu-gcc --version | head -1
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
