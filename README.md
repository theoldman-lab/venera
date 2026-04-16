# Venera

一个 Android 漫画阅读应用。

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

## License

MIT License - 详见 [LICENSE](LICENSE) 文件。
