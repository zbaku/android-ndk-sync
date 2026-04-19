#!/bin/bash
set -e

echo "=== NDK Sync Script ==="

export NDK_VERSION=${NDK_VERSION:-26}
export AOSP_BRANCH="ndk-r${NDK_VERSION}"
export CCACHE_DIR=${CCACHE_DIR:-/workspace/ccache}

echo "NDK Version: $NDK_VERSION"
echo "AOSP Branch: $AOSP_BRANCH"

echo "=== 1. Setup ==="
apt-get update && apt-get install -y \
  repo git curl tar gzip xz-utils python3 \
  ccache

export CCACHE_SIZE=10G

echo "=== 2. Init repo ==="
cd /workspace
mkdir -p aosp-ndk
cd aosp-ndk

repo init \
  -u https://github.com/aosp-mirror/platform/manifest \
  -b $AOSP_BRANCH \
  --depth=1 \
  --partial-clone \
  --clone-filter=blob:limit=10M \
  -g ndk,bionic,prebuilts/ndk,prebuilts/clang,prebuilts/gcc

echo "=== 3. Sync ==="
repo sync -c -j$(nproc) --depth=1 --fetch-submodules

echo "=== 4. Post-Check ==="
if [ -f "../scripts/post-check/verify-sources.sh" ]; then
    ../scripts/post-check/verify-sources.sh /workspace/aosp-ndk $NDK_VERSION
fi

echo "=== Sync Complete ==="
