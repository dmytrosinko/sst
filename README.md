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
- [Keyboard Shortcuts](#keyboard-shortcuts)
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
├── CMakeLists.txt               # Top‑level CMake configuration
├── build_linux.ps1 / .sh        # Linux build helper scripts
├── src/                         # Core source code and QML entry points
│   ├── CMakeLists.txt           # Binds core executable and submodules
│   ├── main.cpp                 # C++ application entry point
│   ├── Main.qml                 # Root window – full‑screen host, splash, global shortcuts
│   ├── TranslationManager.*     # C++ singleton – runtime language switching
│   ├── FileWriter.*             # C++ helper – QML‑accessible file‑write utility
│   ├── assets/                  # Shared static assets embedded as Qt resources
│   │   ├── fonts/               # EuclidCircularB (.ttf) – Regular / Medium / SemiBold / Bold
│   │   ├── icons/               # Numeric digit & input‑type SVG icons
│   │   ├── logo.svg             # Application logo
│   │   ├── icon_category.svg    # Default category tile icon
│   │   ├── icon_service.svg     # Default service tile icon
│   │   └── services.json        # Service catalog – tree of categories & services
│   ├── modules/                 # Reusable feature modules (URI: modules.<name>)
│   │   ├── controls/            # UI control library
│   │   │   ├── CMakeLists.txt
│   │   │   ├── assets/          # Banknote & cash‑slot SVG assets
│   │   │   └── qml/
│   │   │       ├── Button.qml          # Primary action button
│   │   │       ├── BackButton.qml      # Navigation back button
│   │   │       ├── Tile.qml            # Service / category tile
│   │   │       ├── StringInput.qml     # Free‑text input + keyboard
│   │   │       ├── NumberInput.qml     # Numeric‑only input + numpad
│   │   │       ├── PhoneInput.qml      # Phone number input with mask
│   │   │       ├── IbanInput.qml       # IBAN input with validation
│   │   │       ├── CardInput.qml       # Card number input with mask
│   │   │       ├── CashValidator.qml   # Cash insertion widget (banknote display)
│   │   │       ├── NumPad.qml          # On‑screen numeric pad
│   │   │       ├── StringKeyboard.qml  # Full on‑screen QWERTY keyboard
│   │   │       ├── LanguageToggle.qml  # Language selector toggle
│   │   │       ├── TextField.qml       # Single‑line display text field
│   │   │       └── TextArea.qml        # Multi‑line display text area
│   │   ├── finance/             # Transaction engine (URI: modules.finance)
│   │   │   ├── CMakeLists.txt
│   │   │   ├── FinanceBackend.*        # QML‑exposed backend singleton
│   │   │   ├── TransactionController.*# Core transaction lifecycle controller
│   │   │   ├── TransactionSession.*    # Session data model
│   │   │   └── TransactionStatus.h    # Transaction status enum
│   │   ├── hardware/            # Hardware abstraction layer (URI: modules.hardware)
│   │   │   ├── CMakeLists.txt
│   │   │   ├── SystemInfo.*            # CPU / RAM / FPS telemetry
│   │   │   ├── PortScanner.*           # Serial port discovery
│   │   │   ├── ValidatorController.*   # High‑level validator orchestrator
│   │   │   ├── ValidatorDriver.*       # Low‑level MEI ccTalk driver
│   │   │   ├── ValidatorEmulator.*     # Software emulator for bill validator
│   │   │   ├── ValidatorInterface.*    # Abstract validator interface
│   │   │   ├── ValidatorTypes.h        # Shared validator enums & structs
│   │   │   └── qml/
│   │   │       └── HardwareInfo.qml    # QML telemetry overlay component
│   │   ├── services/            # Service catalog model (URI: modules.services)
│   │   │   ├── CMakeLists.txt
│   │   │   ├── ServiceTreeModel.*      # QAbstractItemModel – JSON‑backed tree
│   │   │   └── ServiceTreeItem.*       # Tree node data class
│   │   ├── style/               # Design‑token theming (URI: modules.style)
│   │   │   ├── CMakeLists.txt
│   │   │   └── qml/
│   │   │       ├── Style.qml           # Singleton – exposes currentStyle property
│   │   │       ├── DarkStyle.qml       # Dark theme – Nord‑inspired palette
│   │   │       └── SimbankPallete.qml  # Extended brand colour palette & gradients
│   │   └── ui/                  # Application‑level UI screens (URI: modules.ui)
│   │       ├── CMakeLists.txt
│   │       └── qml/
│   │           ├── Home.qml                  # Root screen – tile navigation + service host
│   │           ├── Header.qml                # Top chrome bar with logo & language toggle
│   │           ├── Footer.qml                # Bottom status bar
│   │           ├── MainBackground.qml        # Gradient animated background
│   │           ├── PanelBackground.qml       # Frosted‑glass panel base
│   │           ├── ServiceTileView.qml       # Grid tile navigator (categories → services)
│   │           ├── AttractModeOverlay.qml    # Idle attract‑mode animation overlay
│   │           ├── StyleConfigurator.qml     # Live theme editor window
│   │           └── ValidatorEmulatorWindow.qml # Debug cash‑validator emulation UI
│   ├── services/                # User‑facing service workflows (URI: service.<name>)
│   │   └── testservice/         # Reference service implementation
│   │       ├── CMakeLists.txt
│   │       ├── ServiceModel.*          # C++ workflow controller singleton
│   │       └── qml/
│   │           ├── Service.qml               # SwipeView workflow container
│   │           ├── NumericInputScreen.qml    # Reusable numeric entry screen
│   │           ├── ScreenInputString.qml     # String entry step
│   │           ├── ScreenInputNumber.qml     # Number entry step
│   │           ├── ScreenInputPhone.qml      # Phone entry step
│   │           ├── ScreenInputIban.qml       # IBAN entry step
│   │           ├── ScreenInputCardNumber.qml # Card number entry step
│   │           ├── ScreenInsertCash.qml      # Cash insertion step
│   │           └── Screen3.qml              # Confirmation / receipt step
│   └── translations/            # Qt Linguist translation files
│       ├── sst_en.ts / .qm      # English
│       ├── sst_ru.ts / .qm      # Russian
│       └── sst_ky.ts / .qm      # Kyrgyz
├── tests/                       # Automated test suite
│   ├── cpp/                     # C++ unit tests (QtTest + QTEST_GUILESS_MAIN)
│   │   ├── modules/hardware/    # SystemInfo & hardware logic tests
│   │   ├── services/testservice/ # ServiceModel workflow tests
│   │   └── tst_TranslationManager.cpp
│   └── qml/                     # QML component tests (QtQuickTest)
│       ├── modules/controls/    # Control component UI tests
│       ├── modules/hardware/    # Hardware QML component tests
│       ├── services/testservice/ # Service QML flow tests
│       └── tst_Main.qml
├── doc/                         # Documentation
│   ├── ARCHITECTURE.md          # Architectural design document
│   └── CONTRIBUTING.md          # Setup, coding, and localization guidelines
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

## Keyboard Shortcuts

All shortcuts are global and active while the application window is focused.

| Shortcut | Context | Description |
|----------|---------|-------------|
| `Ctrl+X` | Global | Quit the application immediately |
| `Ctrl+G` | Home screen | Toggle the **Style Configurator** window (live theme editor) |
| `Ctrl+A` | Home screen | Toggle **Attract Mode** — starts the idle animation; press again to stop it |
| `Ctrl+E` | Home screen | Toggle the **Validator Emulator** debug window (visible only when `USE_DEVICE_EMULATOR` is active) |

> **Note**: `Ctrl+X` is defined at the root `Window` level in `Main.qml`. All other shortcuts are defined inside `Home.qml`.

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


