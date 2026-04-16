# Venera 快速构建脚本

此脚本提供快捷的项目构建命令，支持多平台构建。

## 使用方法

### Linux/macOS

```bash
# 构建所有可用平台
./scripts/build.sh all

# 构建特定平台
./scripts/build.sh android    # Android APK
./scripts/build.sh ios        # iOS IPA
./scripts/build.sh macos      # macOS DMG
./scripts/build.sh linux      # Linux (deb + AppImage)
./scripts/build.sh windows    # Windows (需要 Windows 环境)

# 仅清理构建缓存
./scripts/build.sh clean
```

### Windows (PowerShell)

```powershell
# 构建所有可用平台
.\scripts\build.ps1 all

# 构建特定平台
.\scripts\build.ps1 android   # Android APK
.\scripts\build.ps1 windows   # Windows exe + zip

# 仅清理构建缓存
.\scripts\build.ps1 clean
```

## 输出目录

构建产物将保存在 `dist/` 目录中：

```
dist/
├── android/       # Android 构建产物
├── ios/           # iOS 构建产物
├── macos/         # macOS 构建产物
├── linux/         # Linux 构建产物
└── windows/       # Windows 构建产物
```

## 前置条件

运行此脚本前，请确保：

1. 已运行 `scripts/setup.sh` 或 `scripts/setup.ps1` 配置环境
2. 已通过 `flutter doctor` 验证环境
3. 已运行 `flutter pub get` 获取依赖

## 注意事项

- iOS 和 macOS 构建仅可在 macOS 上执行
- Windows 构建仅可在 Windows 上执行
- Android 构建需要配置签名密钥（可选）
- Linux 构建需要额外的打包工具
