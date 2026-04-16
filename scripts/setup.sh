#!/bin/bash

set -e

echo "========================================"
echo "  Venera Android 开发环境快速配置脚本"
echo "========================================"
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 检查命令是否存在
check_command() {
    if command -v "$1" &> /dev/null; then
        echo -e "${GREEN}✓${NC} $1 已安装"
        return 0
    else
        echo -e "${RED}✗${NC} $1 未安装"
        return 1
    fi
}

# 检查 Java 版本
check_java_version() {
    if command -v java &> /dev/null; then
        java_version=$(java -version 2>&1 | head -1 | cut -d'"' -f2 | cut -d'.' -f1)
        if [ "$java_version" -ge 17 ]; then
            echo -e "${GREEN}✓${NC} Java 版本：$java_version (满足要求 >= 17)"
            return 0
        else
            echo -e "${RED}✗${NC} Java 版本：$java_version (需要 >= 17)"
            return 1
        fi
    fi
    return 1
}

# 显示安装指南
show_install_guide() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  环境安装指南${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
    
    echo -e "${YELLOW}1. 安装 Java JDK 17+${NC}"
    echo ""
    echo "   **Ubuntu/Debian:**"
    echo "   sudo apt update"
    echo "   sudo apt install openjdk-17-jdk"
    echo ""
    echo "   **macOS (Homebrew):**"
    echo "   brew install openjdk@17"
    echo "   echo 'export PATH=\"/opt/homebrew/opt/openjdk@17/bin\":\$PATH' >> ~/.zshrc"
    echo ""
    echo "   **Windows:**"
    echo "   从 https://adoptium.net 下载 Temurin JDK 17"
    echo "   安装后设置 JAVA_HOME 环境变量"
    echo ""
    
    echo -e "${YELLOW}2. 安装 Android SDK${NC}"
    echo ""
    echo "   **方法一：使用 Android Studio (推荐)**"
    echo "   1. 下载 Android Studio: https://developer.android.com/studio"
    echo "   2. 安装后打开 SDK Manager"
    echo "   3. 安装以下组件:"
    echo "      - Android SDK Platform (API 35)"
    echo "      - Android SDK Build-Tools"
    echo "      - Android Emulator (可选)"
    echo "      - NDK (Side by side) 28.0.13004108"
    echo ""
    echo "   **方法二：命令行工具**"
    echo "   1. 下载 Command Line Tools: https://developer.android.com/studio#command-tools"
    echo "   2. 解压到 ~/Android/Sdk/cmdline-tools"
    echo "   3. 运行:"
    echo "      sdkmanager \"platform-tools\" \"platforms;android-35\" \"build-tools;35.0.0\" \"ndk;28.0.13004108\""
    echo ""
    
    echo -e "${YELLOW}3. 配置环境变量${NC}"
    echo ""
    echo "   **Linux/macOS (~/.bashrc 或 ~/.zshrc):**"
    echo "   export ANDROID_HOME=\$HOME/Android/Sdk"
    echo "   export PATH=\$PATH:\$ANDROID_HOME/tools:\$ANDROID_HOME/platform-tools"
    echo "   source ~/.bashrc  # 或 source ~/.zshrc"
    echo ""
    echo "   **Windows (PowerShell):**"
    echo "   \$env:ANDROID_HOME = \"C:\\Users\\YourName\\AppData\\Local\\Android\\Sdk\""
    echo "   \$env:PATH = \"\$env:PATH;\$env:ANDROID_HOME\\tools;\$env:ANDROID_HOME\\platform-tools\""
    echo ""
    
    echo -e "${YELLOW}4. 安装 Flutter${NC}"
    echo ""
    echo "   **Linux:**"
    echo "   sudo snap install flutter --classic"
    echo "   # 或从 https://flutter.dev 下载手动安装"
    echo ""
    echo "   **macOS:**"
    echo "   brew install --cask flutter"
    echo ""
    echo "   **Windows:**"
    echo "   从 https://flutter.dev 下载 Flutter SDK"
    echo "   解压后设置 PATH 环境变量"
    echo ""
    echo "   **验证安装:**"
    echo "   flutter doctor"
    echo ""
    
    echo -e "${YELLOW}5. 安装 Android Studio (可选但推荐)${NC}"
    echo ""
    echo "   Android Studio 提供可视化的 SDK 管理界面"
    echo "   下载：https://developer.android.com/studio"
    echo ""
}

# 主流程
echo "=== 步骤 1: 检查系统依赖 ==="
echo ""

MISSING_DEPS=()

# 检查 Java
if ! check_java_version; then
    MISSING_DEPS+=("java")
fi

# 检查 Android SDK
if [ -n "$ANDROID_HOME" ] || [ -n "$ANDROID_SDK_ROOT" ]; then
    sdk_path="${ANDROID_HOME:-$ANDROID_SDK_ROOT}"
    echo -e "${GREEN}✓${NC} ANDROID_HOME 已设置：$sdk_path"
    
    # 检查必要的组件
    if [ -d "$sdk_path/platform-tools" ]; then
        echo -e "${GREEN}✓${NC} platform-tools 已安装"
    else
        echo -e "${RED}✗${NC} platform-tools 未安装"
        MISSING_DEPS+=("platform-tools")
    fi
    
    if [ -d "$sdk_path/ndk" ] || [ -d "$sdk_path/ndk/28.0.13004108" ]; then
        echo -e "${GREEN}✓${NC} NDK 已安装"
    else
        echo -e "${RED}✗${NC} NDK 未安装 (需要版本 28.0.13004108)"
        MISSING_DEPS+=("ndk")
    fi
else
    echo -e "${RED}✗${NC} ANDROID_HOME 未设置"
    MISSING_DEPS+=("android_sdk")
fi

# 检查 Flutter
if command -v flutter &> /dev/null; then
    flutter_version=$(flutter --version 2>&1 | grep "Flutter" | awk '{print $2}')
    echo -e "${GREEN}✓${NC} Flutter 已安装 (版本：$flutter_version)"
else
    echo -e "${RED}✗${NC} Flutter 未安装"
    MISSING_DEPS+=("flutter")
fi

# 检查 Git
if ! check_command git; then
    MISSING_DEPS+=("git")
fi

echo ""

# 如果有缺失的依赖，显示安装指南
if [ ${#MISSING_DEPS[@]} -gt 0 ]; then
    echo -e "${RED}发现 ${#MISSING_DEPS[@]} 个缺失的依赖:${NC}"
    for dep in "${MISSING_DEPS[@]}"; do
        echo "  - $dep"
    done
    echo ""
    read -p "是否显示详细的安装指南？(Y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
        show_install_guide
    fi
    echo -e "${YELLOW}安装完成后，请重新运行此脚本${NC}"
    exit 1
else
    echo -e "${GREEN}✓${NC} 所有依赖已安装"
fi

echo ""
echo "=== 步骤 2: 接受 Android 许可证 ==="
echo ""

if command -v flutter &> /dev/null; then
    echo "运行 flutter 接受 Android 许可证..."
    echo -e "${YELLOW}提示：需要按多次 'y' 接受所有许可证${NC}"
    flutter doctor --android-licenses || {
        echo -e "${RED}接受许可证失败${NC}"
        echo "请确保已正确安装 Android SDK"
        exit 1
    }
    echo -e "${GREEN}✓${NC} Android 许可证已接受"
else
    echo -e "${YELLOW}Flutter 未安装，跳过许可证接受${NC}"
fi

echo ""
echo "=== 步骤 3: 获取 Flutter 依赖 ==="
echo ""

if command -v flutter &> /dev/null; then
    echo "运行 flutter pub get..."
    flutter pub get
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓${NC} Flutter 依赖已安装"
    else
        echo -e "${RED}✗${NC} Flutter 依赖安装失败"
        exit 1
    fi
else
    echo -e "${YELLOW}Flutter 未安装，跳过依赖安装${NC}"
fi

echo ""
echo "=== 步骤 4: 配置本地属性 ==="
echo ""

# 创建 local.properties 如果不存在
if [ ! -f "android/local.properties" ]; then
    echo "创建 android/local.properties..."
    
    if [ -n "$ANDROID_HOME" ] || [ -n "$ANDROID_SDK_ROOT" ]; then
        sdk_path="${ANDROID_HOME:-$ANDROID_SDK_ROOT}"
        echo "sdk.dir=$sdk_path" > android/local.properties
        echo -e "${GREEN}✓${NC} 已创建 android/local.properties"
    else
        echo -e "${RED}✗${NC} 无法创建 android/local.properties"
        echo "请手动创建并设置 sdk.dir"
        echo "示例：sdk.dir=/home/username/Android/Sdk"
        exit 1
    fi
else
    echo -e "${GREEN}✓${NC} android/local.properties 已存在"
fi

echo ""
echo "=== 步骤 5: 配置签名密钥（可选） ==="
echo ""

if [ ! -f "android/key.properties" ]; then
    echo -e "${YELLOW}提示：签名密钥用于发布应用${NC}"
    echo ""
    echo "如需生成签名密钥，请运行:"
    echo "  ./scripts/generate_key.sh"
    echo ""
    echo "或者手动创建 android/key.properties 文件："
    echo "  storeFile=/path/to/keystore.jks"
    echo "  storePassword=your_password"
    echo "  keyAlias=your_alias"
    echo "  keyPassword=your_password"
    echo ""
    read -p "是否现在生成签名密钥？(y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        ./scripts/generate_key.sh
    fi
else
    echo -e "${GREEN}✓${NC} android/key.properties 已存在"
fi

echo ""
echo "========================================"
echo "  配置完成！"
echo "========================================"
echo ""
echo -e "${GREEN}✓${NC} 开发环境已配置完成"
echo ""
echo "下一步："
echo "  1. 运行 'flutter doctor' 检查开发环境状态"
echo "  2. 运行 'flutter build apk --debug' 构建调试版"
echo "  3. 运行 'flutter build apk --release' 构建发布版"
echo ""
echo "常用构建命令："
echo "  调试版：flutter build apk --debug"
echo "  发布版：flutter build apk --release"
echo "  分架构：flutter build apk --split-per-abi --release"
echo ""
echo "或使用构建脚本："
echo "  ./scripts/build.sh debug    # 调试版"
echo "  ./scripts/build.sh split    # 分架构版本"
echo "  ./scripts/build.sh all      # 所有版本"
echo ""
