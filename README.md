# Venera

一个 Android 漫画阅读应用。
> 由于本人精力有限，该fork专注于安卓端（包括Eink设备）的优化与维护，如有其他平台需求，请另寻高见

## 功能
- 阅读本地漫画
- 使用 JavaScript 创建漫画源
- 阅读网络漫画源
- 管理收藏夹
- 下载漫画
- 查看评论、标签等信息
- 登录评论、评分等操作

## 快速开始

### 1. 克隆仓库

```bash
git clone https://github.com/venera-app/venera.git
cd venera
```

### 2. 配置环境

**详细安装指南：** 请参阅 [scripts/INSTALL.md](scripts/INSTALL.md) 获取各平台的详细安装说明。

**快速配置：**

**Linux/macOS:**
```bash
./scripts/setup.sh
```

**Windows (PowerShell):**
```powershell
.\scripts\setup.ps1
```

### 3. 构建应用

**Linux/macOS:**
```bash
# 调试版
./scripts/build.sh debug

# 发布版（按 CPU 架构分割）
./scripts/build.sh split
```

**Windows (PowerShell):**
```powershell
# 调试版
.\scripts\build.ps1 debug

# 发布版（按 CPU 架构分割）
.\scripts\build.ps1 split
```

## 环境要求

| 组件 | 版本 | 说明 |
|------|------|------|
| Flutter | 3.41.4 | 跨平台框架 |
| Java | JDK 17 | Android 构建 |
| Gradle | 8.13 | 自动下载 |
| Android Gradle Plugin | 8.12.3 | 自动配置 |
| Kotlin | 2.1.0 | 自动配置 |
| Android SDK | API 35 | 包含 platform-tools |
| Android NDK | 28.0.13004108 | 原生库支持 |

## 构建

### 手动构建

```bash
# 获取依赖
flutter pub get

# 构建调试版
flutter build apk --debug

# 构建发布版
flutter build apk --release

# 按 CPU 架构分割构建
flutter build apk --split-per-abi --release
```

### 使用脚本

详见 [scripts/README.md](scripts/README.md)

## 文档

- **[Comic Source](doc/comic_source.md)** - 创建新的漫画源
- **[JS API](doc/js_api.md)** - JavaScript API 参考

## 致谢

### 标签翻译
[EhTagTranslation](https://github.com/EhTagTranslation/Database)

漫画标签中文翻译来自此项目。

## 更新日志

### 2026-05-06

#### 修复 WebDAV 同步上传失败（`flutter_rust_bridge` 未初始化）
- **问题：** `rhttp` 初始化失败后，WebDAV 数据同步仍强制使用 `RHttpAdapter`，导致 `flutter_rust_bridge has not been initialized` 错误，上传/下载均不可用。
- **修复：** `lib/utils/data_sync.dart` — 在创建 WebDAV 客户端时检查 `isRhttpAvailable`，未初始化时回退至 `IOHttpClientAdapter`（标准 dart:io HTTP），与 `AppDio` 保持一致。
- **提交：** `0c6385b` `9ed2e78`

#### 修复漫画下载取消后残留在磁盘的文件夹
- **问题：** 下载失败后取消任务，已下载的漫画文件夹未能删除，堆积占用存储空间。
- **根因分析（三处缺陷）：**
  1. 取消时未调用 `ImageDownloader.cancelAllLoadingImages()` 释放阻塞的网络流，导致 `_ImageDownloadWrapper.wait()` 永久挂起，`Directory.delete()` 永远不会执行；
  2. 章节目录创建时通过 `LocalManager.getChapterDirectoryName()` 消毒了特殊字符（`/\:*?"<>|` 替换为 `_`），但删除时直接使用原始章节名，导致 `existsSync()` 返回 false 而跳过删除；
  3. 当漫画已存在于本地库且下载所有章节（`chapters == null`）时，取消操作无清理逻辑。
- **修复：** `lib/network/download.dart`
  - `cancel()` / `pause()`：新增 `ImageDownloader.cancelAllLoadingImages()` 调用，强制中断所有挂起的图片下载网络流；
  - `cancel()`：章节删除路径统一使用 `LocalManager.getChapterDirectoryName()`，且补充 `chapters ?? _images?.keys` 作为删除目标回退；
  - `_ImageDownloadWrapper.start()`：重构退出逻辑，将 `isCancelled` 时的 `return` 改为 `break`，所有退出路径（正常结束 / 取消 / 异常）统一通过 finally 块 resolve 所有 completer，彻底解除 `wait()` 挂起风险。
- **提交：** 未提交（本次会话）

#### 修复本地漫画无法删除磁盘文件
- **问题：** 删除已下载的本地漫画时，磁盘上的目录文件未被清理。
- **修复：** 使用 `DeleteService` 平台感知的目录删除逻辑，正确删除 `baseDir` 对应的本地文件。
- **提交：** `0e8e5f1`

#### 清理未使用变量
- 移除 `desktop_webview.dart` 中未使用的 `_currentUrl` 字段及赋值。
- 移除 `reader.dart` 中未使用的 `_isInit` 字段及赋值。

---

## License

MIT License - 详见 [LICENSE](LICENSE) 文件。
