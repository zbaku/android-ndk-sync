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

## 模块

- NDK 核心工具链 (clang, lld, llvm-ar)
- C++ 标准库 (libc++)
- Sysroot 和头文件

## 验证

每个批次包含 Pre-Check 和 Post-Check 验证，确保构建正确性。

## License

Apache 2.0
