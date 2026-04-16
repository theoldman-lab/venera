# 生成 Android 签名密钥 (PowerShell)
# 适用于 Windows 系统

$ErrorActionPreference = "Stop"

Write-Host "========================================"
Write-Host "  生成 Android 签名密钥"
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

# 检查 keytool 是否存在
$keytoolCmd = Get-Command "keytool" -ErrorAction SilentlyContinue
if (-not $keytoolCmd) {
    Write-Error-Custom "错误：未找到 keytool，请确保已安装 Java JDK"
    exit 1
}

# 默认值
$defaultAlias = "venera"
$defaultKeypass = "venera123"
$defaultStorepass = "venera123"
$defaultValidity = "10000"
$defaultDname = "CN=Venera, OU=Development, O=Venera, L=Unknown, ST=Unknown, C=Unknown"

Write-Host "生成密钥库参数："
Write-Host "  别名 (Alias): $defaultAlias"
Write-Host "  密钥密码 (Key Password): $defaultKeypass"
Write-Host "  密钥库密码 (Store Password): $defaultStorepass"
Write-Host "  有效期 (Validity): $defaultValidity 天"
Write-Host ""

# 确认
$response = Read-Host "是否使用默认参数生成密钥？(Y/n)"
if ($response -and $response.ToLower() -eq "n") {
    Write-Host "请输入自定义参数："
    $alias = Read-Host "别名 (Alias) [$defaultAlias]"
    if (-not $alias) { $alias = $defaultAlias }
    
    $keypass = Read-Host "密钥密码 (Key Password) [$defaultKeypass]"
    if (-not $keypass) { $keypass = $defaultKeypass }
    
    $storepass = Read-Host "密钥库密码 (Store Password) [$defaultStorepass]"
    if (-not $storepass) { $storepass = $defaultStorepass }
    
    $validity = Read-Host "有效期 (Validity in days) [$defaultValidity]"
    if (-not $validity) { $validity = $defaultValidity }
} else {
    $alias = $defaultAlias
    $keypass = $defaultKeypass
    $storepass = $defaultStorepass
    $validity = $defaultValidity
}

# 创建密钥库目录
$keystoreDir = "android\app"
$keystoreFile = "$keystoreDir\venera.keystore"

if (-not (Test-Path $keystoreDir)) {
    New-Item -ItemType Directory -Force -Path $keystoreDir | Out-Null
}

Write-Host ""
Write-Host "正在生成密钥库..."

# 使用密钥库生成命令
$keytoolArgs = @(
    "-genkey", "-v",
    "-keystore", $keystoreFile,
    "-alias", $alias,
    "-keyalg", "RSA",
    "-keysize", "2048",
    "-validity", $validity,
    "-storepass", $storepass,
    "-keypass", $keypass,
    "-dname", $defaultDname
)

& keytool $keytoolArgs

Write-Success "✓ 密钥库已生成：$keystoreFile"

# 创建 key.properties
$keyPropertiesPath = "android\key.properties"

Write-Host ""
Write-Host "正在创建 $keyPropertiesPath..."

$keyPropertiesContent = @"
storeFile=$keystoreFile
storePassword=$storepass
keyAlias=$alias
keyPassword=$keypass
"@

$keyPropertiesContent | Out-File -FilePath $keyPropertiesPath -Encoding ASCII -NoNewline

Write-Success "✓ 已创建 $keyPropertiesPath"

Write-Host ""
Write-Host "========================================"
Write-Host "  密钥生成完成！"
Write-Host "========================================"
Write-Host ""
Write-Warning-Custom "重要提示："
Write-Host "  1. 请妥善保管密钥库文件和密码"
Write-Host "  2. 不要将密钥文件提交到版本控制系统"
Write-Host "  3. 建议使用强密码替换默认密码"
Write-Host ""
Write-Host "下一步："
Write-Host "  运行 '.\scripts\setup.ps1' 完成环境配置"
Write-Host "  或运行 'flutter build apk' 构建应用"
Write-Host ""
