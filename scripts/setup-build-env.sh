#!/bin/bash
set -e

echo "=== Setup NDK Build Environment (ARM64 Native) ==="

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

echo "=== 3. LLVM/Clang (ARM64 Native) ==="
apt-get install -y llvm llvm-dev clang lld

echo "=== 4. Native ARM64 Libraries ==="
apt-get install -y \
    libc6-dev-arm64 \
    zlib1g-dev \
    libssl-dev

echo "=== 5. Create Build Environment Script ==="
cat > $BUILD_DIR/envsetup.sh << 'ENV'
#!/bin/bash
export WORKSPACE=${WORKSPACE:-/workspace}
export BUILD_DIR=$WORKSPACE/build-tools
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-arm64

# Native ARM64 tools (no cross-compilation needed)
export PATH=/usr/bin:/bin:$PATH
export CC=clang
export CXX=clang++
export AR=llvm-ar
export LD=llvm-link
export LLD=ld.lld

# Android NDK specific
export ANDROID_NDK_ROOT=$BUILD_DIR/ndk
export ANDROID_SDK_ROOT=/usr

# ccache
export CCACHE_DIR=/workspace/ccache
export CCACHE_SIZE=10G

echo "NDK Build Environment (ARM64 Native):"
echo "  CC=$CC"
echo "  CXX=$CXX"
echo "  JAVA_HOME=$JAVA_HOME"
ENV

chmod +x $BUILD_DIR/envsetup.sh

echo "=== 6. Verify Installations ==="
echo ""
echo "Native tools:"
echo "  clang: $(which clang || echo 'not found')"
echo "  lld: $(which lld || echo 'not found')"
echo "  ninja: $(which ninja || echo 'not found')"
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
