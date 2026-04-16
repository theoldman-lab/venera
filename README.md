# Due to my limited time and energy, this project is no longer maintained. Feel free to fork it.
# 由于本人精力有限，此项目已停止维护，欢迎 fork

# venera
[![flutter](https://img.shields.io/badge/flutter-3.41.4-blue)](https://flutter.dev/)
[![License](https://img.shields.io/github/license/venera-app/venera)](https://github.com/venera-app/venera/blob/master/LICENSE)
[![stars](https://img.shields.io/github/stars/venera-app/venera?style=flat)](https://github.com/venera-app/venera/stargazers)

[![Download](https://img.shields.io/github/v/release/venera-app/venera)](https://github.com/venera-app/venera/releases)
[![AUR Version](https://img.shields.io/aur/version/venera-bin)](https://aur.archlinux.org/packages/venera-bin)
[![F-Droid Version](https://img.shields.io/f-droid/v/com.github.wgh136.venera)](https://f-droid.org/packages/com.github.wgh136.venera/)

A comic reader that support reading local and network comics.

## Features
- Read local comics
- Use javascript to create comic sources
- Read comics from network sources
- Manage favorite comics
- Download comics
- View comments, tags, and other information of comics if the source supports
- Login to comment, rate, and other operations if the source supports

## Quick Start

### 1. Clone the repository

```bash
git clone https://github.com/venera-app/venera.git
cd venera
```

### 2. Setup environment

**Linux/macOS:**
```bash
./scripts/setup.sh
```

**Windows (PowerShell):**
```powershell
.\scripts\setup.ps1
```

Or manually follow the [Setup Guide](SETUP_GUIDE.md).

### 3. Build for your platform

**Linux/macOS:**
```bash
./scripts/build.sh all
```

**Windows (PowerShell):**
```powershell
.\scripts\build.ps1 all
```

Or use Flutter directly: `flutter build apk`, `flutter build ios`, etc.

## Documentation

- **[Setup Guide](SETUP_GUIDE.md)** - Complete environment setup instructions
- **[Comic Source](doc/comic_source.md)** - Create new comic sources
- **[Headless Mode](doc/headless_doc.md)** - Run in headless mode
- **[Import Comics](doc/import_comic.md)** - Import comic files
- **[JS API](doc/js_api.md)** - JavaScript API reference

## Build from source

### Prerequisites

- **Flutter** 3.41.4 (see [flutter.dev](https://flutter.dev/docs/get-started/install))
- **Rust** 1.85.1 (see [rustup.rs](https://rustup.rs/))
- **Java** 17 (for Android builds)

### Platform-specific requirements

#### Android
- Android Studio with SDK and NDK
- Run `flutter doctor --android-licenses` to accept licenses

#### iOS (macOS only)
- Xcode 16.4+
- CocoaPods: `sudo gem install cocoapods`

#### Linux
```bash
sudo apt install -y ninja-build libgtk-3-dev webkit2gtk-4.1
```

#### Windows
- Visual Studio Build Tools with C++ workload
- Inno Setup (for creating installers)

### Build commands

```bash
# Get dependencies
flutter pub get

# Build
flutter build apk          # Android
flutter build ios          # iOS
flutter build macos        # macOS
flutter build linux        # Linux
flutter build windows      # Windows
```

## Create a new comic source

See [Comic Source Documentation](doc/comic_source.md)

## Thanks

### Tags Translation
[EhTagTranslation](https://github.com/EhTagTranslation/Database)

The Chinese translation of the manga tags is from this project.

## Headless Mode

See [Headless Documentation](doc/headless_doc.md)

## Contributing

Contributions are welcome! Please feel free to submit pull requests or report issues.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
