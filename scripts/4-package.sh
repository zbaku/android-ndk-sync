#!/bin/bash
set -e

echo "=== NDK Package Script ==="

export NDK_VERSION=${NDK_VERSION:-26}
export AOSP_BRANCH="ndk-r${NDK_VERSION}"

echo "NDK Version: $NDK_VERSION"

cd /workspace

echo "=== 1. Create NDK directory ==="
mkdir -p android-ndk-${NDK_VERSION}
mkdir -p android-ndk-${NDK_VERSION}/{toolchains,sysroot,platforms}

echo "=== 2. Copy toolchains ==="
cp -r aosp-ndk/out/target/product/*/obj/EXECUTABLES/*/llvm*/ toolchains/ 2>/dev/null || true

echo "=== 3. Copy sysroot ==="
cp -r aosp-ndk/out/target/product/*/sysroot/* android-ndk-${NDK_VERSION}/sysroot/ 2>/dev/null || true
cp -r ndk-headers/* android-ndk-${NDK_VERSION}/sysroot/usr/ 2>/dev/null || true

echo "=== 4. Create source.properties ==="
cat > android-ndk-${NDK_VERSION}/source.properties << EOF
Pkg.Desc = Android NDK
Pkg.Revision = ${NDK_VERSION}
NDK Version = ${NDK_VERSION}
Build Date = $(date -u +%Y-%m-%d)
Branch = ${AOSP_BRANCH}
EOF

echo "=== 5. Create NOTICE ==="
cat > android-ndk-${NDK_VERSION}/NOTICE.txt << 'NOTICE'
Android NDK
Copyright (C) Google LLC
Licensed under the Apache License 2.0
NOTICE

echo "=== 6. Package ==="
tar -czf android-ndk-${NDK_VERSION}.tar.gz android-ndk-${NDK_VERSION}/
sha256sum android-ndk-${NDK_VERSION}.tar.gz > android-ndk-${NDK_VERSION}.tar.gz.sha256

echo "=== 7. Post-Check ==="
if [ -f "scripts/post-check/verify-package.sh" ]; then
    cd scripts
    ../scripts/post-check/verify-package.sh
    cd ../..
fi

echo "=== Package Complete ==="
ls -lh android-ndk-${NDK_VERSION}.tar.gz*
