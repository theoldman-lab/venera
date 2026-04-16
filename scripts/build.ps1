# Venera Android 构建脚本 (PowerShell)
# 适用于 Windows 系统

$ErrorActionPreference = "Stop"

Write-Host "========================================"
Write-Host "  Venera Android 构建脚本"
Write-Host "========================================"
Write-Host ""

# 颜色定义
$Red = "Red"
$Green = "Green"
$Yellow = "Yellow"

function Write-Success {
    param([string]$Message)
    Write-Host $Message -ForegroundColor $Green
}

function Write-Error-Custom {
    param([string]$Message)
    Write-Host $Message -ForegroundColor $Red
}

function Write-Warning-Custom {
    param([string]$Message)
    Write-Host $Message -ForegroundColor $Yellow
}

# 显示用法
function Show-Usage {
    Write-Host "用法：.\scripts\build.ps1 [选项]"
    Write-Host ""
    Write-Host "选项:"
    Write-Host "  debug       构建调试版 APK"
    Write-Host "  release     构建发布版 APK (未签名)"
    Write-Host "  signed      构建发布版 APK (已签名)"
    Write-Host "  split       按 CPU 架构分割构建"
    Write-Host "  clean       清理构建缓存"
    Write-Host "  all         构建所有版本"
    Write-Host ""
    Write-Host "示例:"
    Write-Host "  .\scripts\build.ps1 debug      # 构建调试版"
    Write-Host "  .\scripts\build.ps1 release    # 构建发布版"
    Write-Host "  .\scripts\build.ps1 split      # 构建分架构版本"
    Write-Host ""
}

# 检查 Flutter
$flutterCmd = Get-Command "flutter" -ErrorAction SilentlyContinue
if (-not $flutterCmd) {
    Write-Error-Custom "错误：未找到 Flutter，请先安装 Flutter"
    exit 1
}

# 检查 Android SDK
$androidHome = $env:ANDROID_HOME
if (-not $androidHome) {
    Write-Warning-Custom "警告：ANDROID_HOME 未设置"
    if (-not (Test-Path "android\local.properties")) {
        Write-Error-Custom "错误：android\local.properties 不存在"
        Write-Host "请先运行 '.\scripts\setup.ps1' 配置环境"
        exit 1
    }
}

# 获取 Flutter 版本
$flutterVersion = flutter --version 2>&1 | Select-String -Pattern 'Flutter' | ForEach-Object { $_ -replace 'Flutter ([0-9.]+).*', '$1' }
Write-Host "Flutter 版本：$flutterVersion"
Write-Host ""

# 构建函数
function Build-Debug {
    Write-Host "========================================"
    Write-Host "  构建调试版 APK"
    Write-Host "========================================"
    flutter build apk --debug
    Write-Success "✓ 调试版构建完成"
    Write-Host "输出：build\app\outputs\flutter-apk\app-debug.apk"
    Write-Host ""
}

function Build-Release {
    Write-Host "========================================"
    Write-Host "  构建发布版 APK (未签名)"
    Write-Host "========================================"
    flutter build apk --release --no-shrink
    Write-Success "✓ 发布版构建完成"
    Write-Host "输出：build\app\outputs\flutter-apk\app-release.apk"
    Write-Host ""
}

function Build-Signed {
    Write-Host "========================================"
    Write-Host "  构建发布版 APK (已签名)"
    Write-Host "========================================"
    
    if (-not (Test-Path "android\key.properties")) {
        Write-Error-Custom "错误：android\key.properties 不存在"
        Write-Host "请先运行 '.\scripts\generate_key.ps1' 生成签名密钥"
        exit 1
    }
    
    flutter build apk --release
    Write-Success "✓ 签名版构建完成"
    Write-Host "输出：build\app\outputs\flutter-apk\release\"
    Write-Host ""
}

function Build-Split {
    Write-Host "========================================"
    Write-Host "  按 CPU 架构分割构建"
    Write-Host "========================================"
    flutter build apk --split-per-abi --release
    Write-Success "✓ 分架构构建完成"
    Write-Host "输出：build\app\outputs\flutter-apk\release\"
    Write-Host "  - armeabi-v7a: 32 位 ARM"
    Write-Host "  - arm64-v8a: 64 位 ARM (现代设备)"
    Write-Host "  - x86_64: 64 位 x86 (模拟器)"
    Write-Host ""
}

function Clean-Build {
    Write-Host "========================================"
    Write-Host "  清理构建缓存"
    Write-Host "========================================"
    flutter clean
    if (Test-Path "build") {
        Remove-Item -Recurse -Force "build"
    }
    Write-Success "✓ 清理完成"
    Write-Host ""
}

# 主逻辑
param(
    [Parameter(Position=0)]
    [string]$BuildType = ""
)

switch ($BuildType.ToLower()) {
    "debug" { Build-Debug }
    "release" { Build-Release }
    "signed" { Build-Signed }
    "split" { Build-Split }
    "clean" { Clean-Build }
    "all" { Build-Debug; Build-Split }
    "" { Show-Usage; exit 0 }
    default {
        Write-Error-Custom "错误：未知选项 '$BuildType'"
        Show-Usage
        exit 1
    }
}

Write-Host "========================================"
Write-Host "  构建完成！"
Write-Host "========================================"
