# Venera 环境配置指南

本文档提供 Venera 项目的完整环境配置说明。

## 系统要求

- **操作系统**: Windows 10+, macOS 10.15+, Linux (Ubuntu 22.04+ 或兼容发行版)
- **磁盘空间**: 至少 10GB 可用空间
- **内存**: 建议 8GB 以上

## 核心依赖

### 1. Flutter (3.41.4)

Flutter 是主要的开发框架。

#### 安装方法

**推荐：使用 fvm 进行版本管理**

```bash
# 安装 fvm
dart pub global activate fvm

# 配置项目 Flutter 版本
fvm install 3.41.4
fvm use 3.41.4
```

**或者：直接安装**

访问 [flutter.dev](https://flutter.dev/docs/get-started/install) 下载并安装 Flutter 3.41.4。

验证安装：
```bash
flutter --version
```

### 2. Rust (1.85.1)

Rust 用于部分原生模块的编译。

#### 安装方法

```bash
# 使用 rustup 安装
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# 安装指定版本
rustup install 1.85.1
rustup default 1.85.1

# 安装需要的 targets
rustup target add aarch64-apple-darwin x86_64-apple-darwin \
  aarch64-linux-android armv7-linux-androideabi x86_64-linux-android
```

验证安装：
```bash
rustc --version
rustup show
```

### 3. Java Development Kit (17)

Android 构建需要 JDK 17。

#### 安装方法

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install openjdk-17-jdk
```

**macOS:**
```bash
brew install openjdk@17
```

**Windows:**
从 [Oracle](https://www.oracle.com/java/technologies/downloads/#java17) 或 [Adoptium](https://adoptium.net/) 下载安装。

设置 JAVA_HOME 环境变量：
```bash
# Linux/macOS
export JAVA_HOME=/path/to/jdk-17

# Windows (PowerShell)
$env:JAVA_HOME = "C:\Program Files\Java\jdk-17"
```

## 平台特定依赖

### Android

1. 安装 Android Studio
2. 安装 Android SDK 和 NDK
3. 配置环境变量：
   ```bash
   export ANDROID_HOME=$HOME/Android/Sdk
   export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
   ```

4. 接受许可证：
   ```bash
   flutter doctor --android-licenses
   ```

### iOS (仅 macOS)

1. 安装 Xcode 16.4+
2. 安装命令行工具：
   ```bash
   sudo xcode-select --switch /Applications/Xcode.app
   sudo xcodebuild -runFirstLaunch
   ```

3. 安装 CocoaPods：
   ```bash
   sudo gem install cocoapods
   ```

### Linux

安装必要的系统包：

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install -y ninja-build libgtk-3-dev webkit2gtk-4.1 \
    libayatana-appindicator3-dev librsvg2-dev \
    clang cmake git curl zip unzip xz-utils
```

**Arch Linux:**
```bash
sudo pacman -S ninja gtk3 webkit2gtk-4.1 appindicator3-git \
    librsvg clang cmake git curl zip unzip xz
```

### Windows

1. 安装 [Visual Studio Build Tools](https://visualstudio.microsoft.com/downloads/)
   - 选择 "C++ build tools"
   - 确保勾选 "MSVC" 和 "Windows 10/11 SDK"

2. 安装 [Inno Setup](https://jrsoftware.org/isdl.php) (用于创建安装包)：
   ```powershell
   choco install innosetup
   ```

3. 安装其他工具：
   ```powershell
   choco install yq python3
   pip install httpx
   ```

### macOS

1. 安装 Xcode 16.4+
2. 安装 Homebrew（如果尚未安装）：
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

3. 安装额外依赖：
   ```bash
   brew install cmake ninja
   ```

## 快速配置脚本

项目提供了自动化的环境配置脚本，请查看：

- **Linux/macOS**: `scripts/setup.sh`
- **Windows**: `scripts/setup.ps1`

运行脚本前请确保已安装基础工具（Git、curl 等）。

## 项目初始化

配置好环境后，运行以下命令初始化项目：

```bash
# 获取依赖
flutter pub get

# 检查环境
flutter doctor

# 运行项目
flutter run
```

## 构建项目

### Android
```bash
flutter build apk --release
# 或
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### macOS
```bash
flutter build macos --release
```

### Linux
```bash
flutter build linux --release
```

### Windows
```bash
flutter build windows --release
# 或使用构建脚本
python windows/build.py
```

## 常见问题

### Flutter 版本不匹配

如果使用 fvm：
```bash
fvm use 3.41.4
```

否则，请切换到正确的 Flutter 版本。

### Rust 版本问题

```bash
rustup install 1.85.1
rustup default 1.85.1
```

### Linux 缺少 GTK 依赖

```bash
sudo apt install libgtk-3-dev webkit2gtk-4.1
```

### Android 许可证未接受

```bash
flutter doctor --android-licenses
```

## 开发工具推荐

- **IDE**: VS Code (推荐) 或 Android Studio
- **VS Code 扩展**:
  - Flutter
  - Dart
  - Rust Analyzer (可选)

## 更新依赖

定期更新项目依赖：

```bash
flutter pub upgrade
flutter clean
flutter pub get
```

## 参考链接

- [Flutter 官方文档](https://flutter.dev/docs)
- [Rust 官方文档](https://doc.rust-lang.org/)
- [Android 开发者文档](https://developer.android.com/)
