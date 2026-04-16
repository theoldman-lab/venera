# Venera 环境安装指南

本文档提供详细的环境配置说明，帮助您搭建 Venera 的开发和构建环境。

## 目录

- [系统要求](#系统要求)
- [Windows 安装指南](#windows-安装指南)
- [macOS 安装指南](#macos-安装指南)
- [Linux 安装指南](#linux-安装指南)
- [验证安装](#验证安装)
- [常见问题](#常见问题)

---

## 系统要求

| 组件 | 版本 | 说明 |
|------|------|------|
| 操作系统 | Windows 10 / macOS 10.14 / Ubuntu 18.04 | Windows 11 / macOS 12+ / Ubuntu 22.04 推荐 |
| 磁盘空间 | 10 GB | 20 GB+ 推荐 |
| 内存 | 8 GB | 16 GB+ 推荐 |
| Flutter | 3.41.4 | 必须 |
| Java | JDK 17 | 必须（项目使用 Java 17） |
| Gradle | 8.13 | 自动下载 |
| Android Gradle Plugin | 8.12.3 | 自动配置 |
| Kotlin | 2.1.0 | 自动配置 |
| Android SDK | API 34+ | 推荐 API 35 |
| Android NDK | 28.0.13004108 | 必须 |

---

## Windows 安装指南

### 1. 安装 Java JDK

**方法一：使用安装包（推荐）**

1. 访问 [Adoptium](https://adoptium.net/)
2. 下载 Temurin JDK 17 Windows x64 Installer
3. 运行安装程序，按照向导完成安装
4. 设置环境变量：
   - 右键"此电脑" → "属性" → "高级系统设置"
   - 点击"环境变量"
   - 新建系统变量：
     - 变量名：`JAVA_HOME`
     - 变量值：`C:\Program Files\Eclipse Adoptium\jdk-17.x.x`（实际安装路径）
   - 编辑 `Path` 变量，添加：`%JAVA_HOME%\bin`

**方法二：使用 Winget**

```powershell
winget install EclipseAdoptium.Temurin.17.JDK
```

**验证安装：**
```powershell
java -version
# 应显示 "version 17.x.x"
```

### 2. 安装 Android SDK

**方法一：使用 Android Studio（推荐）**

1. 下载 [Android Studio](https://developer.android.com/studio)
2. 安装 Android Studio
3. 首次启动时，SDK 会自动安装
4. 打开 SDK Manager（Tools → SDK Manager）
5. 安装以下组件：
   - Android SDK Platform 35
   - Android SDK Build-Tools 35.0.0
   - NDK (Side by side) 28.0.13004108
   - Android SDK Platform-Tools
   - Android SDK Tools

**方法二：使用命令行工具**

1. 下载 [Command Line Tools](https://developer.android.com/studio#command-tools)
2. 创建目录：`C:\Users\YourName\AppData\Local\Android\Sdk\cmdline-tools`
3. 解压下载的文件到该目录
4. 重命名解压后的文件夹为 `latest`
5. 打开命令提示符，运行：

```powershell
cd C:\Users\YourName\AppData\Local\Android\Sdk\cmdline-tools\latest\bin
sdkmanager "platform-tools" "platforms;android-36" "build-tools;28.0.3" "ndk;28.0.13004108"
```

### 3. 配置环境变量

1. 右键"此电脑" → "属性" → "高级系统设置"
2. 点击"环境变量"
3. 新建系统变量：
   - 变量名：`ANDROID_HOME`
   - 变量值：`C:\Users\YourName\AppData\Local\Android\Sdk`
4. 编辑 `Path` 变量，添加：
   - `%ANDROID_HOME%\platform-tools`
   - `%ANDROID_HOME%\tools`
   - `%ANDROID_HOME%\cmdline-tools\latest\bin`

### 4. 安装 Flutter

**方法一：手动安装（推荐）**

1. 下载 [Flutter SDK](https://docs.flutter.dev/get-started/install/windows)
2. 解压到 `C:\src\flutter`（或其他非系统目录）
3. 添加 Flutter 到 PATH：
   - 编辑 `Path` 环境变量
   - 添加：`C:\src\flutter\bin`
4. 重启终端

**方法二：使用 Chocolatey**

```powershell
choco install flutter
```

### 5. 安装 Git

1. 下载 [Git for Windows](https://git-scm.com/download/win)
2. 运行安装程序
3. 按照默认选项安装即可

---

## macOS 安装指南

### 1. 安装 Homebrew（如果未安装）

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. 安装 Java JDK

```bash
brew install openjdk@17
echo 'export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### 3. 安装 Android SDK

**方法一：使用 Android Studio（推荐）**

1. 下载 [Android Studio](https://developer.android.com/studio)
2. 安装 Android Studio
3. 打开 SDK Manager（Android Studio → Preferences → Appearance & Behavior → System Settings → Android SDK）
4. 安装以下组件：
   - Android SDK Platform 35
   - Android SDK Build-Tools 35.0.0
   - NDK (Side by side) 28.0.13004108
   - Android SDK Platform-Tools

**方法二：使用命令行**

```bash
# 安装 SDK 命令行工具
brew install --cask android-commandlinetools

# 接受许可证
sdkmanager --licenses

# 安装必要组件
sdkmanager "platform-tools" "platforms;android-35" "build-tools;35.0.0" "ndk;28.0.13004108"
```

### 4. 配置环境变量

编辑 `~/.zshrc` 或 `~/.bash_profile`：

```bash
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
```

应用更改：
```bash
source ~/.zshrc  # 或 source ~/.bash_profile
```

### 5. 安装 Flutter

**方法一：使用 Homebrew**

```bash
brew install --cask flutter
```

**方法二：手动安装**

1. 下载 [Flutter SDK](https://docs.flutter.dev/get-started/install/macos)
2. 解压到 `~/development/flutter`
3. 添加到 PATH：
   ```bash
   export PATH="$PATH:$HOME/development/flutter/bin"
   echo 'export PATH="$PATH:$HOME/development/flutter/bin"' >> ~/.zshrc
   ```

### 6. 安装 Xcode（可选，用于 iOS 开发）

```bash
xcode-select --install
sudo xcodebuild -license accept
```

---

## Linux 安装指南

### 1. 安装 Java JDK

**Ubuntu/Debian:**

```bash
sudo apt update
sudo apt install openjdk-17-jdk
```

**Fedora:**

```bash
sudo dnf install java-17-openjdk-devel
```

**Arch Linux:**

```bash
sudo pacman -S jdk17-openjdk
```

### 2. 安装 Android SDK

**方法一：使用 Android Studio（推荐）**

1. 下载 [Android Studio](https://developer.android.com/studio)
2. 解压并运行：
   ```bash
   tar -xzf android-studio-*.tar.gz -C ~/opt/
   ~/opt/android-studio/bin/studio.sh
   ```
3. 打开 SDK Manager 安装必要组件

**方法二：使用命令行**

```bash
# 创建目录
mkdir -p ~/Android/Sdk/cmdline-tools
cd ~/Android/Sdk/cmdline-tools

# 下载并解压命令行工具
wget https://dl.google.com/android/repository/commandlinetools-linux-*.zip
unzip commandlinetools-linux-*.zip
mv cmdline-tools latest

# 安装组件
~/Android/Sdk/cmdline-tools/latest/bin/sdkmanager "platform-tools" "platforms;android-35" "build-tools;35.0.0" "ndk;28.0.13004108"
```

### 3. 配置环境变量

编辑 `~/.bashrc` 或 `~/.zshrc`：

```bash
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
```

应用更改：
```bash
source ~/.bashrc  # 或 source ~/.zshrc
```

### 4. 安装 Flutter

**Ubuntu/Debian:**

```bash
sudo snap install flutter --classic
```

**Fedora:**

```bash
sudo dnf install flutter
```

**Arch Linux:**

```bash
sudo pacman -S flutter
```

**手动安装（通用）:**

```bash
# 下载并解压
cd ~/development
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_*.tar.xz
tar xf flutter_linux_*.tar.xz

# 添加到 PATH
export PATH="$PATH:$HOME/development/flutter/bin"
echo 'export PATH="$PATH:$HOME/development/flutter/bin"' >> ~/.bashrc
```

### 5. 安装依赖（Ubuntu/Debian）

```bash
sudo apt-get install curl git unzip xz-utils zip libglu1-mesa
```

### 6. 安装 Git

```bash
# Ubuntu/Debian
sudo apt install git

# Fedora
sudo dnf install git

# Arch
sudo pacman -S git
```

---

## 验证安装

### 1. 运行 Flutter Doctor

```bash
flutter doctor
```

应看到类似输出：

```
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel stable, 3.41.4, on ...)
[✓] Android toolchain - develop for Android devices (Android SDK version 35.0.0)
[✓] Xcode - develop for iOS and macOS (only on macOS)
[✓] Chrome - develop for the web
[✓] Android Studio (only on macOS/Windows)
[✓] Connected device (only when device connected)
[✓] Network resources

• No issues found!
```

### 2. 接受 Android 许可证

```bash
flutter doctor --android-licenses
```

按 `y` 接受所有许可证。

### 3. 运行快速配置脚本

```bash
# Linux/macOS
./scripts/setup.sh

# Windows
.\scripts\setup.ps1
```

---

## 常见问题

### 1. ANDROID_HOME 未设置

**症状：** 构建时提示 "ANDROID_HOME not set"

**解决：**
```bash
# Linux/macOS
export ANDROID_HOME=$HOME/Android/Sdk
echo 'export ANDROID_HOME=$HOME/Android/Sdk' >> ~/.bashrc

# Windows
$env:ANDROID_HOME = "C:\Users\YourName\AppData\Local\Android\Sdk"
```

### 2. 许可证未接受

**症状：** "You have not accepted the license agreements"

**解决：**
```bash
flutter doctor --android-licenses
```

### 3. NDK 版本不匹配

**症状：** "NDK version 28.0.13004108 is required"

**解决：**
在 Android Studio 的 SDK Manager 中安装指定版本的 NDK，或：

```bash
sdkmanager "ndk;28.0.13004108"
```

### 4. Flutter 下载慢

**症状：** `flutter pub get` 下载依赖很慢

**解决：** 使用国内镜像

```bash
# 设置环境变量
export PUB_HOSTED_URL=https://pub.flutter-io.cn
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn

# Windows PowerShell
$env:PUB_HOSTED_URL = "https://pub.flutter-io.cn"
$env:FLUTTER_STORAGE_BASE_URL = "https://storage.flutter-io.cn"
```

### 5. Gradle 下载慢

**解决：** 修改 `android/build.gradle`，使用国内镜像：

```groovy
allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url 'https://maven.aliyun.com/repository/google' }
        maven { url 'https://maven.aliyun.com/repository/public' }
    }
}
```

### 6. 磁盘空间不足

**症状：** 安装过程中提示空间不足

**解决：**
- 清理磁盘空间
- 将 SDK 安装到其他磁盘
- 使用 `sdkmanager` 只安装必要的组件

### 7. 权限问题（Linux/macOS）

**症状：** "Permission denied"

**解决：**
```bash
sudo chown -R $USER:$USER ~/Android/Sdk
chmod -R u+w ~/Android/Sdk
```

---

## 下一步

环境配置完成后：

1. 克隆项目：
   ```bash
   git clone https://github.com/venera-app/venera.git
   cd venera
   ```

2. 获取依赖：
   ```bash
   flutter pub get
   ```

3. 构建应用：
   ```bash
   flutter build apk --debug
   ```

4. 运行应用（需要连接设备或模拟器）：
   ```bash
   flutter run
   ```

---

## 参考链接

- [Flutter 官方文档](https://flutter.dev/docs)
- [Android 开发者文档](https://developer.android.com/docs)
- [Venera 项目 README](../README.md)
- [构建脚本说明](README.md)
