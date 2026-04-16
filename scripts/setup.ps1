# Venera Android 开发环境快速配置脚本 (PowerShell)
# 适用于 Windows 系统

$ErrorActionPreference = "Stop"

Write-Host "========================================"
Write-Host "  Venera Android 开发环境快速配置脚本"
Write-Host "========================================"
Write-Host ""

# 颜色定义
$Red = "Red"
$Green = "Green"
$Yellow = "Yellow"
$Blue = "Blue"

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

function Write-Info {
    param([string]$Message)
    Write-Host $Message -ForegroundColor $Blue
}

# 检查命令是否存在
function Check-Command {
    param([string]$Name)
    $cmd = Get-Command $Name -ErrorAction SilentlyContinue
    if ($cmd) {
        Write-Success "✓ $Name 已安装"
        return $true
    } else {
        Write-Error-Custom "✗ $Name 未安装"
        return $false
    }
}

# 检查 Java 版本
function Check-Java-Version {
    try {
        $javaVersion = java -version 2>&1 | Select-String -Pattern 'version' | ForEach-Object { $_ -replace '.*"([0-9.]+)".*', '$1' }
        $majorVersion = [int]($javaVersion.Split('.')[0])
        if ($majorVersion -ge 17) {
            Write-Success "✓ Java 版本：$javaVersion (满足要求 >= 17)"
            return $true
        } else {
            Write-Error-Custom "✗ Java 版本：$javaVersion (需要 >= 17)"
            return $false
        }
    } catch {
        Write-Error-Custom "✗ Java 未安装"
        return $false
    }
}

# 显示安装指南
function Show-Install-Guide {
    Write-Host ""
    Write-Info "========================================"
    Write-Info "  环境安装指南"
    Write-Info "========================================"
    Write-Host ""
    
    Write-Warning-Custom "1. 安装 Java JDK 17+"
    Write-Host ""
    Write-Host "   从 https://adoptium.net 下载 Temurin JDK 17"
    Write-Host "   安装后设置 JAVA_HOME 环境变量:"
    Write-Host '   $env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17..."'
    Write-Host '   $env:PATH = "$env:PATH;$env:JAVA_HOME\bin"'
    Write-Host ""
    
    Write-Warning-Custom "2. 安装 Android SDK"
    Write-Host ""
    Write-Host "   **方法一：使用 Android Studio (推荐)**"
    Write-Host "   1. 下载 Android Studio: https://developer.android.com/studio"
    Write-Host "   2. 安装后打开 SDK Manager"
    Write-Host "   3. 安装以下组件:"
    Write-Host "      - Android SDK Platform (API 35)"
    Write-Host "      - Android SDK Build-Tools"
    Write-Host "      - Android Emulator (可选)"
    Write-Host "      - NDK (Side by side) 28.0.13004108"
    Write-Host ""
    Write-Host "   **方法二：命令行工具**"
    Write-Host "   1. 下载 Command Line Tools: https://developer.android.com/studio#command-tools"
    Write-Host "   2. 解压到 C:\Users\YourName\AppData\Local\Android\Sdk\cmdline-tools"
    Write-Host "   3. 运行:"
    Write-Host '      sdkmanager "platform-tools" "platforms;android-35" "build-tools;35.0.0" "ndk;28.0.13004108"'
    Write-Host ""
    
    Write-Warning-Custom "3. 配置环境变量"
    Write-Host ""
    Write-Host "   **永久设置 (系统环境变量):**"
    Write-Host "   1. 右键"此电脑" -> "属性" -> "高级系统设置""
    Write-Host "   2. 点击"环境变量""
    Write-Host "   3. 新建系统变量:"
    Write-Host '      变量名：ANDROID_HOME'
    Write-Host '      变量值：C:\Users\YourName\AppData\Local\Android\Sdk'
    Write-Host "   4. 编辑 Path 变量，添加:"
    Write-Host '      %ANDROID_HOME%\tools'
    Write-Host '      %ANDROID_HOME%\platform-tools'
    Write-Host ""
    Write-Host "   **临时设置 (当前 PowerShell 会话):**"
    Write-Host '   $env:ANDROID_HOME = "C:\Users\YourName\AppData\Local\Android\Sdk"'
    Write-Host '   $env:PATH = "$env:PATH;$env:ANDROID_HOME\tools;$env:ANDROID_HOME\platform-tools"'
    Write-Host ""
    
    Write-Warning-Custom "4. 安装 Flutter"
    Write-Host ""
    Write-Host "   1. 从 https://flutter.dev 下载 Flutter SDK"
    Write-Host "   2. 解压到 C:\src\flutter (或其他位置)"
    Write-Host "   3. 添加 Flutter 到 PATH:"
    Write-Host '      $env:PATH = "$env:PATH;C:\src\flutter\bin"'
    Write-Host "   4. 验证安装:"
    Write-Host "      flutter doctor"
    Write-Host ""
    Write-Host "   **注意：** 不要将 Flutter 安装到需要管理员权限的目录"
    Write-Host ""
    
    Write-Warning-Custom "5. 安装 Android Studio (可选但推荐)"
    Write-Host ""
    Write-Host "   Android Studio 提供可视化的 SDK 管理界面"
    Write-Host "   下载：https://developer.android.com/studio"
    Write-Host ""
    Write-Host "   安装后需要:"
    Write-Host "   - 安装 Android SDK"
    Write-Host "   - 安装 Android SDK Platform-Tools"
    Write-Host "   - 安装 Android SDK Build-Tools"
    Write-Host "   - 安装 Android SDK NDK (版本 28.0.13004108)"
    Write-Host ""
}

# 主流程
Write-Host "=== 步骤 1: 检查系统依赖 ==="
Write-Host ""

$MissingDeps = @()

# 检查 Java
if (-not (Check-Java-Version)) {
    $MissingDeps += "java"
}

# 检查 Android SDK
$androidHome = $env:ANDROID_HOME
if ($androidHome) {
    Write-Success "✓ ANDROID_HOME 已设置：$androidHome"
    
    # 检查必要的组件
    if (Test-Path "$androidHome\platform-tools") {
        Write-Success "✓ platform-tools 已安装"
    } else {
        Write-Error-Custom "✗ platform-tools 未安装"
        $MissingDeps += "platform-tools"
    }
    
    if (Test-Path "$androidHome\ndk" -or (Test-Path "$androidHome\ndk\28.0.13004108")) {
        Write-Success "✓ NDK 已安装"
    } else {
        Write-Error-Custom "✗ NDK 未安装 (需要版本 28.0.13004108)"
        $MissingDeps += "ndk"
    }
} else {
    Write-Error-Custom "✗ ANDROID_HOME 未设置"
    $MissingDeps += "android_sdk"
}

# 检查 Flutter
$flutterCmd = Get-Command "flutter" -ErrorAction SilentlyContinue
if ($flutterCmd) {
    $flutterVersion = flutter --version 2>&1 | Select-String -Pattern 'Flutter' | ForEach-Object { $_ -replace 'Flutter ([0-9.]+).*', '$1' }
    Write-Success "✓ Flutter 已安装 (版本：$flutterVersion)"
} else {
    Write-Error-Custom "✗ Flutter 未安装"
    $MissingDeps += "flutter"
}

# 检查 Git
if (-not (Check-Command "git")) {
    $MissingDeps += "git"
}

Write-Host ""

# 如果有缺失的依赖，显示安装指南
if ($MissingDeps.Count -gt 0) {
    Write-Error-Custom "发现 $($MissingDeps.Count) 个缺失的依赖:"
    foreach ($dep in $MissingDeps) {
        Write-Host "  - $dep"
    }
    Write-Host ""
    
    $response = Read-Host "是否显示详细的安装指南？(Y/n)"
    if ($response -ne "n" -and $response -ne "N") {
        Show-Install-Guide
    }
    Write-Host ""
    Write-Warning-Custom "安装完成后，请重新运行此脚本"
    exit 1
} else {
    Write-Success "✓ 所有依赖已安装"
}

Write-Host ""
Write-Host "=== 步骤 2: 接受 Android 许可证 ==="
Write-Host ""

Write-Host "运行 flutter 接受 Android 许可证..."
Write-Warning-Custom "提示：需要按多次 'y' 接受所有许可证"
try {
    flutter doctor --android-licenses 2>&1 | Out-String
    Write-Success "✓ Android 许可证已接受"
} catch {
    Write-Error-Custom "接受许可证失败"
    Write-Host "请确保已正确安装 Android SDK"
    exit 1
}

Write-Host ""
Write-Host "=== 步骤 3: 获取 Flutter 依赖 ==="
Write-Host ""

Write-Host "运行 flutter pub get..."
try {
    flutter pub get 2>&1 | Out-String
    Write-Success "✓ Flutter 依赖已安装"
} catch {
    Write-Error-Custom "✗ Flutter 依赖安装失败"
    exit 1
}

Write-Host ""
Write-Host "=== 步骤 4: 配置本地属性 ==="
Write-Host ""

# 创建 local.properties 如果不存在
$localPropertiesPath = "android\local.properties"
if (-not (Test-Path $localPropertiesPath)) {
    Write-Host "创建 $localPropertiesPath..."
    
    if ($androidHome) {
        "sdk.dir=$androidHome" | Out-File -FilePath $localPropertiesPath -Encoding ASCII
        Write-Success "✓ 已创建 $localPropertiesPath"
    } else {
        Write-Error-Custom "✗ 无法创建 $localPropertiesPath"
        Write-Host "请手动创建并设置 sdk.dir"
        Write-Host "示例：sdk.dir=C:\Users\YourName\AppData\Local\Android\Sdk"
        exit 1
    }
} else {
    Write-Success "✓ $localPropertiesPath 已存在"
}

Write-Host ""
Write-Host "=== 步骤 5: 配置签名密钥（可选） ==="
Write-Host ""

$keyPropertiesPath = "android\key.properties"
if (-not (Test-Path $keyPropertiesPath)) {
    Write-Warning-Custom "提示：签名密钥用于发布应用"
    Write-Host ""
    Write-Host "如需生成签名密钥，请运行:"
    Write-Host "  .\scripts\generate_key.ps1"
    Write-Host ""
    Write-Host "或者手动创建 android/key.properties 文件："
    Write-Host "  storeFile=C:/path/to/keystore.jks"
    Write-Host "  storePassword=your_password"
    Write-Host "  keyAlias=your_alias"
    Write-Host "  keyPassword=your_password"
    Write-Host ""
    
    $response = Read-Host "是否现在生成签名密钥？(y/N)"
    if ($response -eq "y" -or $response -eq "Y") {
        .\scripts\generate_key.ps1
    }
} else {
    Write-Success "✓ $keyPropertiesPath 已存在"
}

Write-Host ""
Write-Host "========================================"
Write-Host "  配置完成！"
Write-Host "========================================"
Write-Host ""
Write-Success "✓ 开发环境已配置完成"
Write-Host ""
Write-Host "下一步："
Write-Host "  1. 运行 'flutter doctor' 检查开发环境状态"
Write-Host "  2. 运行 'flutter build apk --debug' 构建调试版"
Write-Host "  3. 运行 'flutter build apk --release' 构建发布版"
Write-Host ""
Write-Host "常用构建命令："
Write-Host "  调试版：flutter build apk --debug"
Write-Host "  发布版：flutter build apk --release"
Write-Host "  分架构：flutter build apk --split-per-abi --release"
Write-Host ""
Write-Host "或使用构建脚本："
Write-Host "  .\scripts\build.ps1 debug    # 调试版"
Write-Host "  .\scripts\build.ps1 split    # 分架构版本"
Write-Host "  .\scripts\build.ps1 all      # 所有版本"
Write-Host ""
