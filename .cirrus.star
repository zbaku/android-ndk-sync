"""Android NDK Sync CI/CD - Cirrus Starlark Script"""

def main(ctx):
    return parallelize([
        sync_task(),
        build_core_task(),
        build_libs_task(),
        release_task()
    ])

def sync_task():
    return Task(
        name = "Sync NDK Sources",
        arm_container = {"image": "ubuntu:22.04"},
        environment = {
            "NDK_VERSION": "26",
            "AOSP_BRANCH": "ndk-r26",
            "CCACHE_DIR": "/workspace/ccache"
        },
        script = [
            "apt-get update && apt-get install -y repo git curl tar gzip xz-utils python3 ccache",
            "git clone https://github.com/zbaku/android-ndk-sync.git /workspace/android-ndk-sync",
            "cd /workspace",
            "mkdir -p aosp-ndk && cd aosp-ndk",
            "repo init -u https://github.com/aosp-mirror/platform/manifest -b $AOSP_BRANCH --depth=1",
            "repo sync -c -j$(nproc) --depth=1"
        ],
        cache = {"folders": ["/workspace/ccache"]}
    )

def build_core_task():
    return Task(
        name = "Build NDK Core",
        arm_container = {"image": "ubuntu:22.04"},
        depends_on = ["Sync NDK Sources"],
        script = [
            "apt-get update && apt-get install -y openjdk-17-jdk llvm clang lld",
            "cd /workspace/aosp-ndk",
            "source build/envsetup.sh",
            "lunch sdk_phone64_arm64-userdebug",
            "make clang -j$(nproc)",
            "make lld -j$(nproc)",
            "make llvm-ar -j$(nproc)"
        ],
        cache = {"folders": ["/workspace/ccache"]}
    )

def build_libs_task():
    return Task(
        name = "Build NDK Libraries",
        arm_container = {"image": "ubuntu:22.04"},
        depends_on = ["Build NDK Core"],
        script = [
            "cd /workspace/aosp-ndk",
            "make libc++ -j$(nproc)",
            "make sysroot -j$(nproc)"
        ]
    )

def release_task():
    return Task(
        name = "Package and Release",
        arm_container = {"image": "ubuntu:22.04"},
        depends_on = ["Build NDK Libraries"],
        script = [
            "cd /workspace",
            'mkdir -p android-ndk-26/{toolchains,sysroot,platforms}',
            "tar -czf android-ndk-26.tar.gz android-ndk-26/",
            "sha256sum android-ndk-26.tar.gz > android-ndk-26.tar.gz.sha256"
        ],
        artifacts = {
            "name": "ndk-package",
            "path": "android-ndk-26.tar.gz"
        }
    )
