# Venera 构建脚本

本目录包含用于配置环境和构建 Android 应用的脚本。

## 📖 详细安装指南

如需详细的环境安装说明，请参阅 **[INSTALL.md](INSTALL.md)** 文档，其中包含：

- Windows/macOS/Linux 各平台的详细安装步骤
- 环境变量的配置方法
- 常见问题的解决方案
- 国内用户镜像配置

## 📋 版本依赖对照

如需查看项目的版本依赖，请参阅 **[VERSIONS.md](VERSIONS.md)** 文档，其中包含：

- 所有依赖的版本号
- 版本兼容性说明
- 版本检查命令
- 故障排除指南

---

## 脚本列表

### 环境配置

| 平台 | 脚本 | 说明 |
|------|------|------|
| Linux/macOS | `./setup.sh` | 配置 Android 开发环境 |
| Windows | `.\setup.ps1` | 配置 Android 开发环境 |

### 构建应用

| 平台 | 脚本 | 说明 |
|------|------|------|
| Linux/macOS | `./build.sh` | 构建 Android APK |
| Windows | `.\build.ps1` | 构建 Android APK |

### 生成签名密钥

| 平台 | 脚本 | 说明 |
|------|------|------|
| Linux/macOS | `./generate_key.sh` | 生成 Android 签名密钥 |
| Windows | `.\generate_key.ps1` | 生成 Android 签名密钥 |

## 快速开始

### 1. 环境配置

**Linux/macOS:**
```bash
./scripts/setup.sh
```

**Windows (PowerShell):**
```powershell
.\scripts\setup.ps1
```

### 2. 生成签名密钥（可选）

**Linux/macOS:**
```bash
./scripts/generate_key.sh
```

**Windows (PowerShell):**
```powershell
.\scripts\generate_key.ps1
```

### 3. 构建应用

**Linux/macOS:**
```bash
# 调试版
./scripts/build.sh debug

# 发布版（未签名）
./scripts/build.sh release

# 发布版（已签名）
./scripts/build.sh signed

# 按 CPU 架构分割构建
./scripts/build.sh split

# 构建所有版本
./scripts/build.sh all

# 清理构建缓存
./scripts/build.sh clean
```

**Windows (PowerShell):**
```powershell
# 调试版
.\scripts\build.ps1 debug

# 发布版（未签名）
.\scripts\build.ps1 release

# 发布版（已签名）
.\scripts\build.ps1 signed

# 按 CPU 架构分割构建
.\scripts\build.ps1 split

# 构建所有版本
.\scripts\build.ps1 all

# 清理构建缓存
.\scripts\build.ps1 clean
```

## 环境要求

### 必需

- **Flutter** 3.41.4
- **Java** 17 或更高版本
- **Android SDK** (包含 platform-tools)
- **Android NDK** 28.0.13004108

### 可选

- **Android Studio** (用于管理 SDK 组件)

## 环境变量

确保设置以下环境变量：

```bash
export ANDROID_HOME=$HOME/Android/Sdk  # Linux/macOS
$env:ANDROID_HOME = "C:\Users\...\Android\Sdk"  # Windows
```

## 构建输出

构建的 APK 文件位于：

```
build/app/outputs/flutter-apk/
├── app-debug.apk              # 调试版
├── app-release.apk            # 发布版（未签名）
└── release/
    ├── venera-<version>-armeabi-v7a.apk
    ├── venera-<version>-arm64-v8a.apk
    ├── venera-<version>-x86_64.apk
    └── venera-<version>.apk   # 通用 APK
```

## 故障排除

### ANDROID_HOME 未设置

```bash
# Linux/macOS
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools

# Windows
$env:ANDROID_HOME = "C:\Users\YourName\AppData\Local\Android\Sdk"
```

### 许可证未接受

```bash
flutter doctor --android-licenses
```

### 缺少 NDK

在 Android Studio 的 SDK Manager 中安装 NDK 28.0.13004108，或使用命令行：

```bash
$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --install "ndk;28.0.13004108"
```
