# Venera 版本依赖对照表

本文档列出 Venera 项目的所有版本依赖，确保开发环境配置正确。

## 核心依赖

| 组件 | 版本 | 配置文件 | 说明 |
|------|------|----------|------|
| **Flutter** | 3.41.4 | `pubspec.yaml` | 必须匹配 |
| **Dart SDK** | >=3.8.0 <4.0.0 | `pubspec.yaml` | 随 Flutter 安装 |
| **Java** | 17 | `android/app/build.gradle` | 必须 JDK 17 |
| **Gradle** | 8.13 | `gradle-wrapper.properties` | 自动下载 |
| **Android Gradle Plugin** | 8.12.3 | `settings.gradle` | 自动配置 |
| **Kotlin** | 2.1.0 | `settings.gradle` | 自动配置 |

## Android SDK 依赖

| 组件 | 版本 | 配置文件 | 说明 |
|------|------|----------|------|
| **Compile SDK** | 35 | `android/app/build.gradle` | Flutter 3.41.4 默认 |
| **Target SDK** | 35 | `android/app/build.gradle` | Flutter 3.41.4 默认 |
| **Min SDK** | 21 | `android/app/build.gradle` | Flutter 3.41.4 默认 |
| **Build Tools** | 35.0.0 | - | 推荐安装 |
| **NDK** | 28.0.13004108 | `android/app/build.gradle` | 必须匹配 |
| **Platform Tools** | latest | - | 推荐最新 |

## 主要 Flutter 依赖

| 依赖 | 版本 | 说明 |
|------|------|------|
| path_provider | any | 路径提供 |
| intl | any | 国际化 |
| sqlite3 | ^2.7.4 | 数据库 |
| sqlite3_flutter_libs | ^0.5.30 | SQLite 原生库 |
| flutter_qjs | git (8feae95) | JavaScript 引擎 |
| crypto | ^3.0.6 | 加密 |
| dio | ^5.9.2 | HTTP 客户端 |
| html | ^0.15.6 | HTML 解析 |
| pointycastle | ^4.0.0 | 加密算法 |
| url_launcher | ^6.3.2 | URL 启动 |
| photo_view | git (a1255d1) | 图片查看 |
| share_plus | ^12.0.1 | 分享 |
| flutter_reorderable_grid_view | ^5.4.0 | 网格排序 |
| uuid | ^4.5.1 | UUID 生成 |
| flutter_inappwebview | git (3ef899b) | WebView |
| app_links | ^7.0.0 | 应用链接 |
| flutter_file_dialog | ^3.0.3 | 文件对话框 |
| zip_flutter | ^0.0.13 | ZIP 支持 |
| lodepng_flutter | git (ac7d05d) | PNG 解码 |
| rhttp | ^0.15.1 | HTTP 客户端 |
| webdav_client | git (2f669c9) | WebDAV |
| battery_plus | ^7.0.0 | 电池信息 |
| local_auth | ^3.0.1 | 本地认证 |
| flutter_saf | git (fe182cd) | 存储访问框架 |
| dynamic_color | ^1.8.1 | 动态颜色 |
| shimmer_animation | ^2.1.0 | 动画 |
| flutter_7zip | git (b333447) | 7ZIP 支持 |
| flex_seed_scheme | ^4.0.1 | 颜色主题 |
| yaml | ^3.1.3 | YAML 解析 |
| enough_convert | ^1.6.0 | 编码转换 |
| display_mode | ^0.0.2 | 显示模式 |
| flutter_staggered_grid_view | ^0.7.0 | 交错网格 |

## Android 库依赖

| 依赖 | 版本 | 说明 |
|------|------|------|
| androidx.activity:activity-ktx | 1.10.1 | AndroidX Activity |
| androidx.documentfile:documentfile | 1.0.1 | DocumentFile API |

## 版本兼容性说明

### Java 版本
- **必须使用 JDK 17**
- 不兼容 JDK 21（可能导致构建失败）
- 不兼容 JDK 11（版本过低）

### Gradle 与 AGP 版本对应
| Gradle | Android Gradle Plugin |
|--------|----------------------|
| 8.13 | 8.12.3 |
| 8.12 | 8.11.x |
| 8.11 | 8.9.x |

### Flutter 与 SDK 版本对应
| Flutter | Compile SDK | Target SDK | Min SDK |
|---------|-------------|------------|---------|
| 3.41.4 | 35 | 35 | 21 |
| 3.38.x | 34 | 34 | 21 |
| 3.24.x | 34 | 34 | 21 |

## 检查版本命令

### 检查 Flutter 版本
```bash
flutter --version
```

### 检查 Java 版本
```bash
java -version
```

### 检查 Gradle 版本
```bash
cd android
./gradlew --version
```

### 检查 Android SDK 版本
```bash
sdkmanager --list
```

### 检查 NDK 版本
```bash
$ANDROID_HOME/ndk-bundle/source.properties
# 或
cat $ANDROID_HOME/ndk/28.0.13004108/source.properties
```

## 更新依赖

### 更新 Flutter 依赖
```bash
flutter pub get
flutter pub upgrade
```

### 更新 Android 依赖
编辑以下文件：
- `android/app/build.gradle` - 应用级依赖
- `android/settings.gradle` - 插件版本

### 更新 Gradle
编辑 `android/gradle/wrapper/gradle-wrapper.properties`:
```properties
distributionUrl=https\://services.gradle.org/distributions/gradle-8.13-all.zip
```

### 更新 NDK
```bash
sdkmanager --install "ndk;28.0.13004108"
```

## 故障排除

### 问题：Java 版本不匹配
```
Error: The Java version does not match the required version.
```
**解决：** 安装 JDK 17 并设置 `JAVA_HOME`

### 问题：Gradle 版本不兼容
```
Error: Gradle version 8.13 is required for Android Gradle Plugin 8.12.3
```
**解决：** 更新 `gradle-wrapper.properties`

### 问题：NDK 版本不匹配
```
Error: NDK version 28.0.13004108 is required
```
**解决：** 通过 SDK Manager 安装正确的 NDK 版本

## 参考链接

- [Flutter 版本历史](https://docs.flutter.dev/release/archive)
- [Android Gradle Plugin 发布说明](https://developer.android.com/build/releases/gradle-plugin)
- [Gradle 发行版](https://gradle.org/releases/)
- [NDK 版本历史](https://developer.android.com/ndk/downloads)
