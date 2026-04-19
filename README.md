# Android NDK Sync & Build

定时/手动从 AOSP 同步 NDK 源码，构建并发布到 GitHub Releases。

## 触发方式

- **定时触发**：每季度 (1/4/7/10 月 1 日 00:00)
- **手动触发**：推送 tag `sync-ndk-latest`

## 构建产物

- `android-ndk-{VERSION}.tar.gz` (~10 GB)
- `android-ndk-{VERSION}.tar.gz.sha256`

## 架构

- **CI 平台**：Cirrus CI (ARM64)
- **源码**：AOSP GitHub Mirror
- **存储**：GitHub Releases

## 构建流程

| Task | 内容 | Pre-Check | Post-Check |
|------|------|-----------|------------|
| 1. Sync | repo init + sync | 无 | 目录结构 + Git |
| 2. Core | clang + lld + llvm-ar | 源码 + 磁盘 + 工具 | 二进制 + 架构 |
| 3. Libs | libc++ + headers | clang 版本 | .a + headers |
| 4. Package | tar.gz + upload | 产出完整 | SHA256 + tar.gz |

## 脚本结构

```
scripts/
├── 1-sync.sh           # Task 1: 同步源码
├── 2-build-core.sh     # Task 2: 构建核心
├── 3-build-libs.sh    # Task 3: 构建库
├── 4-package.sh        # Task 4: 打包发布
├── pre-check/          # 执行前检查
│   ├── check-batch2.sh
│   ├── check-batch3.sh
│   └── check-batch4.sh
└── post-check/         # 执行后验证
    ├── verify-sources.sh
    ├── verify-binaries.sh
    ├── verify-libs.sh
    └── verify-package.sh

tests/
└── test-functionality.sh  # 功能测试
```

## 本地测试

```bash
# 安装依赖
apt-get install repo git curl tar gzip xz-utils python3 ccache

# 同步源码
./scripts/1-sync.sh

# 构建核心
./scripts/2-build-core.sh

# 构建库
./scripts/3-build-libs.sh

# 打包
./scripts/4-package.sh

# 功能测试
./tests/test-functionality.sh
```

## 验证

```bash
# 检查源码
./scripts/post-check/verify-sources.sh

# 检查二进制
./scripts/post-check/verify-binaries.sh out/ clang lld llvm-ar

# 检查库
./scripts/post-check/verify-libs.sh out/

# 检查包
./scripts/post-check/verify-package.sh
```

## 环境变量

| 变量 | 默认值 | 说明 |
|------|--------|------|
| NDK_VERSION | 26 | NDK 版本 |
| AOSP_BRANCH | ndk-r26 | AOSP 分支 |
| BUILD_TARGET | sdk_phone64_arm64-userdebug | 构建目标 |
| CCACHE_DIR | /workspace/ccache | ccache 目录 |
| CCACHE_SIZE | 10G | ccache 大小 |

## License

Apache 2.0
