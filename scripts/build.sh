#!/bin/bash

set -e

echo "========================================"
echo "  Venera Android 构建脚本"
echo "========================================"
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 显示用法
show_usage() {
    echo "用法：$0 [选项]"
    echo ""
    echo "选项:"
    echo "  debug       构建调试版 APK"
    echo "  release     构建发布版 APK (未签名)"
    echo "  signed      构建发布版 APK (已签名)"
    echo "  split       按 CPU 架构分割构建"
    echo "  clean       清理构建缓存"
    echo "  all         构建所有版本"
    echo ""
    echo "示例:"
    echo "  $0 debug      # 构建调试版"
    echo "  $0 release    # 构建发布版"
    echo "  $0 split      # 构建分架构版本"
    echo ""
}

# 检查 Flutter
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}错误：未找到 Flutter，请先安装 Flutter${NC}"
    exit 1
fi

# 检查 Android SDK
if [ -z "$ANDROID_HOME" ] && [ -z "$ANDROID_SDK_ROOT" ]; then
    echo -e "${YELLOW}警告：ANDROID_HOME 未设置${NC}"
    if [ ! -f "android/local.properties" ]; then
        echo -e "${RED}错误：android/local.properties 不存在${NC}"
        echo "请先运行 './scripts/setup.sh' 配置环境"
        exit 1
    fi
fi

# 获取 Flutter 版本
flutter_version=$(flutter --version 2>&1 | grep "Flutter" | awk '{print $2}')
echo "Flutter 版本：$flutter_version"
echo ""

# 构建函数
build_debug() {
    echo "========================================"
    echo "  构建调试版 APK"
    echo "========================================"
    flutter build apk --debug
    echo -e "${GREEN}✓${NC} 调试版构建完成"
    echo "输出：build/app/outputs/flutter-apk/app-debug.apk"
    echo ""
}

build_release() {
    echo "========================================"
    echo "  构建发布版 APK (未签名)"
    echo "========================================"
    flutter build apk --release --no-shrink
    echo -e "${GREEN}✓${NC} 发布版构建完成"
    echo "输出：build/app/outputs/flutter-apk/app-release.apk"
    echo ""
}

build_signed() {
    echo "========================================"
    echo "  构建发布版 APK (已签名)"
    echo "========================================"
    
    if [ ! -f "android/key.properties" ]; then
        echo -e "${RED}错误：android/key.properties 不存在${NC}"
        echo "请先运行 './scripts/generate_key.sh' 生成签名密钥"
        exit 1
    fi
    
    flutter build apk --release
    echo -e "${GREEN}✓${NC} 签名版构建完成"
    echo "输出：build/app/outputs/flutter-apk/release/"
    echo ""
}

build_split() {
    echo "========================================"
    echo "  按 CPU 架构分割构建"
    echo "========================================"
    flutter build apk --split-per-abi --release
    echo -e "${GREEN}✓${NC} 分架构构建完成"
    echo "输出：build/app/outputs/flutter-apk/release/"
    echo "  - armeabi-v7a: 32 位 ARM"
    echo "  - arm64-v8a: 64 位 ARM (现代设备)"
    echo "  - x86_64: 64 位 x86 (模拟器)"
    echo ""
}

clean_build() {
    echo "========================================"
    echo "  清理构建缓存"
    echo "========================================"
    flutter clean
    rm -rf build/
    echo -e "${GREEN}✓${NC} 清理完成"
    echo ""
}

# 主逻辑
case "${1:-}" in
    debug)
        build_debug
        ;;
    release)
        build_release
        ;;
    signed)
        build_signed
        ;;
    split)
        build_split
        ;;
    clean)
        clean_build
        ;;
    all)
        build_debug
        build_split
        ;;
    "")
        show_usage
        exit 0
        ;;
    *)
        echo -e "${RED}错误：未知选项 '$1'${NC}"
        show_usage
        exit 1
        ;;
esac

echo "========================================"
echo "  构建完成！"
echo "========================================"
