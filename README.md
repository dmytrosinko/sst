# Self Service Terminal (Kiosk)

![Self Service Terminal](https://raw.githubusercontent.com/dmytrosinko/sst/main/docs/screenshot.png)

A **Self Service Terminal** application built with **Qt**, **C++**, and **CMake**. The application provides a touch‑friendly interface for users to perform self‑service tasks in a secure, isolated environment.

---

## Table of Contents

- [Features](#features)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Building the Project](#building-the-project)
  - [Using Qt Creator (GUI)](#using-qt-creator-gui)
  - [Command‑Line (CMake)](#command-line-cmake)
- [Running the Application](#running-the-application)
- [Development Tips](#development-tips)
- [License](#license)

---

## Features

- Full‑screen kiosk mode with optional **Qt Quick** UI.
- Touch‑screen support and on‑screen keyboard integration.
- Cross‑platform: **Windows 10/11** and **Linux** (Ubuntu, Fedora, etc.).
- Built with **Qt 6.10** for the latest UI components and performance improvements.

---

## Prerequisites

| Platform | Required Tools |
|----------|----------------|
| **Windows** | • Visual Studio 2022 (MSVC) or MinGW‑64<br>• Qt 6.10 (MSVC or MinGW) installed via the Qt Online Installer<br>• CMake ≥ 3.24<br>• Git (optional) |
| **Linux** | • GCC ≥ 11 or Clang ≥ 13<br>• Qt 6.10 development packages (`qt6-base-dev`, `qt6-declarative-dev`, etc.)
• CMake ≥ 3.24<br>• Git (optional) |

> **Tip**: Ensure the `CMAKE_PREFIX_PATH` environment variable points to the Qt installation directory (e.g., `C:\Qt\6.10.0\msvc2019_64` on Windows or `/opt/Qt6.10.0` on Linux).

---

## Project Structure

```text
sst/
├── CMakeLists.txt          # Top‑level CMake configuration
├── src/                    # Core source code and QML entry points
│   ├── CMakeLists.txt      # Binds core executable and submodules
│   ├── main.cpp            # C++ bootstrapping engine
│   ├── Main.qml            # Primary layout wrapper
│   ├── TranslationManager.*# Global C++ Translation singleton
│   ├── modules/            # Independent plugins
│   │   ├── controls/       # Reusable UI controls (Button, TextField, TextArea)
│   │   ├── hardware/       # Hardware integration (CPU, RAM, FPS)
│   │   └── style/          # Theming & design tokens
│   │       └── qml/
│   │           ├── Style.qml      # Singleton – exposes currentStyle
│   │           └── DarkStyle.qml  # Singleton – Nord palette colors & fonts
│   ├── services/           # Stateful user-facing workflows (e.g., testservice)
│   └── translations/       # Auto-generated qt_add_translation dictionaries (.ts)
├── tests/                  # 1:1 Explicit Unit and Integration Tests
│   ├── cpp/                # C++ Logic execution evaluators using QtTest
│   └── qml/                # QML UI bound execution evaluators using QtQuickTest
├── doc/                    # Documentation and contribution standards
│   ├── ARCHITECTURE.md     # Core module architectural strategies
│   └── CONTRIBUTING.md     # Setup, coding, and localization guidelines
└── README.md
```

---

## Building the Project

### Using Qt Creator (GUI)
1. **Open the project**
   - Launch **Qt Creator**.
   - Choose **File → Open File or Project…** and select `CMakeLists.txt` in the repository root.
2. **Configure the kit**
   - In the *Configure Project* dialog, select a kit that matches your compiler and Qt version (e.g., *Desktop Qt 6.10.0 MSVC 2019 64bit*).
   - Click **Configure**.
3. **Build**
   - Press **Ctrl + B** or click the **Build** button.
   - The build output appears in the *Compile Output* pane.
4. **Run**
   - Press **Ctrl + R** or click the **Run** button. The application launches in a new window.

### Command‑Line (CMake)
#### Windows (MSVC)
```powershell
# 1. Clone the repository (if not already)
git clone https://github.com/dmytrosinko/sst.git
cd sst

# 2. Create a build directory
mkdir build && cd build

# 3. Configure with CMake (adjust the Qt path if necessary)
cmake .. -G "Visual Studio 17 2022" \
      -DCMAKE_PREFIX_PATH="C:/Qt/6.10.0/msvc2019_64"

# 4. Build (Release configuration shown; use Debug for development)
cmake --build . --config Release
```

#### Windows (MinGW)
```powershell
cmake .. -G "MinGW Makefiles" -DCMAKE_PREFIX_PATH="C:/Qt/6.10.0/mingw81_64"
mingw32-make -j$(nproc)
```

#### Linux (GCC/Clang)
```bash
# 1. Clone the repository
git clone https://github.com/dmytrosinko/sst.git
cd sst

# 2. Create a build directory
mkdir build && cd build

# 3. Configure with CMake (Qt path may be auto‑detected if installed in /opt/Qt)
cmake .. -DCMAKE_PREFIX_PATH="/opt/Qt6.10.0"

# 4. Build
make -j$(nproc)
```

> **Note**: If `cmake` cannot locate Qt, set the `CMAKE_PREFIX_PATH` environment variable manually before running the configure step.

---

## Running the Application

- **From Qt Creator**: Use the *Run* button as described above.
- **From the command line**:
  - After a successful build, the executable resides in `build/Release/` (Windows) or `build/` (Linux).
  - Run it directly:
    ```bash
    ./SelfServiceTerminal   # Linux
    .\Release\SelfServiceTerminal.exe   # Windows Release
    ```
- **Kiosk mode**: The application can be launched with the `--kiosk` flag to start full‑screen without window decorations:
  ```bash
  ./SelfServiceTerminal --kiosk
  ```

---

## Development Tips

- **Hot‑reload QML**: When editing QML files, enable *Qt Quick Designer* live preview in Qt Creator for instant UI feedback.
- **Testing**: The project uses **Qt Test** for C++ unit tests and **QML Test** for QML components.
  - **C++ Tests**: Add test source files under `tests/` and link them with `Qt6::Test`. CMake will automatically register these tests. Run them with:
    ```bash
    ctest --output-on-failure
    ```
  - **QML Tests**: Place QML test files under `tests/qml/`. They are executed using the `Qt6::QmlTest` module. Run QML tests via:
    ```bash
    ctest -R qml
    ```


