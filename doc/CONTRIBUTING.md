# Contributing Guidelines & Module Structure

When adding new modules, features, or fixing bugs in the Self Service Terminal (SST) project, please adhere to the following project structure layout and coding conventions. These rules ensure that our codebase remains scalable, clean, and developer-friendly.

---

## 1. Module File Structure

All QML and C++ architecture within the project is componentized into specific Qt modules. Each module must strictly follow this internal file and folder hierarchy:

```text
src/modules/<ModuleName>/
│
├── CMakeLists.txt         # Qt module definitions (qt_add_qml_module)
│
├── C++ Files              # C++ files can be at the root or under any subfolder
├── ...
│
├── qml/                   # ALL regular QML UI files MUST be in this folder
│   ├── Component.qml
│   └── ...
│
└── assets/                # ALL static assets (images, fonts, icons) MUST be in this folder
    ├── background.png
    └── icon.svg
```

### 1.1 QML Files Directory
All regular `.qml` definitions that construct the UI components, screens, or layouts must be placed inside the **`qml/`** subfolder of your module. Do not place QML UI components in the root of the module folder.

### 1.2 Module URI Naming
To prevent namespace collisions across the wider Qt application, the URI for modules placed within the `src/modules/` directory MUST reflect their path. The URI used inside `CMakeLists.txt` (`qt_add_qml_module`) should be:
**`modules.[ModuleName]`**

To enforce consistency and avoid typos, it is highly recommended to declare your module using the `project()` variable within your `CMakeLists.txt`:

```cmake
project(mymodule VERSION 1.0 LANGUAGES CXX)

qt_add_qml_module(${PROJECT_NAME}
    URI modules.${PROJECT_NAME}
    VERSION 1.0
    STATIC
    # ...
)
```

*(For example: `modules.hardware`, `modules.network`, etc.)*

### 1.3 Assets Directory
Static resources such as images, videos, audio, or fonts must be uniquely categorized under an **`assets/`** folder. Keep file names descriptive.

### 1.4 C++ Source Files Layout
Unlike QML or assets, your C++ implementation files (`.cpp` and `.h`) can reside directly in the root folder of the module, or you may organize them inside logical subfolders if the C++ portion of the module grows complex.

---

## 2. Naming Conventions

### 2.1 C++ File Naming
All C++ source files (`.cpp`) and header files (`.h`) **must be named using PascalCase (CamelCase)**:

- ❌ Incorrect: `systeminfo.cpp` / `system_info.h`
- ✅ Correct: `SystemInfo.cpp` / `SystemInfo.h`
- ✅ Correct: `HardwareManager.cpp`

### 2.2 C++ Namespaces
Namespaces are **mandatory** for all C++ classes residing in QML modules. 
- The namespace must be entirely in lowercase.
- The namespace should be exactly the same as the module name, or a shortened variation of the module name.
- Inside `.cpp` files, you must declare `using namespace [namespace];` immediately following the `#include` block.

### 2.3 QML File Naming
QML files should continue natively following QML PascalCase conventions for type registration (e.g. `HardwareInfo.qml`, `DeviceStatus.qml`).

### 2.4 Localization (I18n) Rules
To support multi-language terminals natively via Qt Linguist, **all human-readable UI strings in QML files MUST be marked for translation.** Make sure to wrap explicit string text directly in the `qsTr()` context function.

- ❌ Incorrect: `text: "Go to Main"`
- ❌ Incorrect: `placeholderText: "Enter number..."`
- ✅ Correct: `text: qsTr("Go to Main")`
- ✅ Correct: `placeholderText: qsTr("Enter number...")`

Data fed conditionally from internal C++ logic should bypass `qsTr()` in the QML file *if* it is translated within C++ bindings, but all static text encoded into QML bounds must maintain compliance to build unified `.ts` localization arrays.

---

## 3. Using the Style System

All colors and font sizes used within the application are managed centrally by the **`modules.style`** module. **Never hardcode color strings or pixel sizes directly in QML files.** Instead, always reference the tokens exposed through `Style.currentStyle`.

### 3.1 Importing and Using Tokens

Add `import modules.style` to any QML file that needs colors or font sizes, then reference tokens via `Style.currentStyle`:

```qml
import QtQuick
import modules.style

Rectangle {
    color: Style.currentStyle.surfacePrimary
    border.color: Style.currentStyle.borderAccent
    border.width: 2
    radius: 6

    Text {
        text: "Hello"
        color: Style.currentStyle.textPrimary
        font.pixelSize: Style.currentStyle.fontSizeNormal
    }
}
```

### 3.2 Do's and Don'ts

| ❌ Incorrect | ✅ Correct |
|-------------|-----------|
| `color: "#2E3440"` | `color: Style.currentStyle.surfacePrimary` |
| `color: "#ECEFF4"` | `color: Style.currentStyle.textPrimary` |
| `font.pixelSize: 16` | `font.pixelSize: Style.currentStyle.fontSizeNormal` |
| `border.color: "#88C0D0"` | `border.color: Style.currentStyle.borderAccent` |

### 3.3 Available Token Categories

| Category | Example Properties |
|----------|-------------------|
| **Backgrounds** | `background`, `surfacePrimary`, `surfaceSecondary`, `surfaceHover`, `surfacePressed` |
| **Borders** | `borderDefault`, `borderAccent`, `borderStrong` |
| **Text** | `textPrimary`, `textSecondary`, `textOnAccent`, `textHeading` |
| **Accent / Status** | `accentPrimary`, `accentSecondary`, `statusSuccess`, `statusWarning` |
| **Font Sizes** | `fontSizeSmall` (14), `fontSizeNormal` (16), `fontSizeLarge` (18), `fontSizeXLarge` (24) |

> Refer to `src/modules/style/qml/DarkStyle.qml` for the complete, authoritative list of all tokens.

### 3.4 Adding New Tokens

If a design requires a color or size not yet covered:

1. Add the `readonly property` to `DarkStyle.qml` with a descriptive name following the existing naming scheme (category prefix + purpose).
2. Use the new token in your QML files via `Style.currentStyle.yourNewToken`.
3. If multiple themes exist, add the matching property to every theme file (e.g., `LightStyle.qml`) to maintain interface parity.

---

## 4. Managing Asset References in QML

Hardcoded file paths to assets scattered throughout `.qml` files create maintenance loops and make refactoring difficult. 

To govern asset locations, **every module possessing assets MUST include a `qml/Assets.qml` singleton file.** 

### 4.1 The `Assets.qml` Singleton Pattern
Create an `Assets.qml` that maps human-readable properties to exactly correct, fully quantified `qrc:/` URL paths. 

```qml
// qml/Assets.qml
pragma Singleton
import QtQuick 2.0

QtObject {
    // Properties must be readonly. 
    // Always provide the absolute qrc string generated by the Qt resource system.
    readonly property string background: "qrc:/sst/modules/ui/assets/background.png"
    readonly property string infoIcon: "qrc:/sst/modules/ui/assets/info-icon.svg"
}
```

### 4.2 Using Assets in other QML files
Whenever you need an image or font resource, consume the singleton instead of hard-coding a relative path:

```qml
import QtQuick 2.0
// Import your module namespace if needed to access the singleton depending on your CMake setup

Image {
    source: Assets.background
    width: 200
    height: 200
}
```

This enforces compile-time or parser-time tracking of asset mapping rules, ensuring that renamed or missing files are caught at a single point of failure.

---

## 5. Testing & Quality Assurance

To ensure system stability, **every new functional addition (C++ logic or QML UI component) MUST be covered by dedicated unit or integration tests.**

### 5.1 Strict 1:1 Mapping Rule
The test structure mirrors the source framework explicitly. For every single `.cpp` or `.qml` file created under `src/`, there MUST be an accompanying `tst_[filename]` test file mapped correctly under the `tests/` directory.

- `src/modules/controls/qml/Button.qml` **must** have `tests/qml/modules/controls/tst_Button.qml`
- `src/services/testservice/ServiceModel.cpp` **must** have `tests/cpp/services/testservice/tst_ServiceModel.cpp`

### 5.2 Adding C++ Tests
1. Create your test file prefixed with `tst_` (e.g., `tst_YourClass.cpp`) under `tests/cpp/`.
2. Inside your C++ test, formulate a `QObject` testing subclass utilizing `QTEST_GUILESS_MAIN(Tst_YourClass)`.
3. Open `tests/cpp/CMakeLists.txt` and append your testing filename directly structurally to the module's `qt_add_executable` definition.
    ```cmake
    qt_add_executable(cpp_tst_mymodule 
        modules/mymodule/tst_YourClass.cpp
    )
    ```

### 5.3 Adding QML Component Tests
1. Create your explicit layout test prefixed with `tst_` (e.g., `tst_YourComponent.qml`) securely within `tests/qml/`.
2. Use Qt Quick `TestCase` to assign explicit simulated validation parameters avoiding relative native bounds errors:
    ```qml
    import QtQuick
    import QtTest
    
    TestCase {
        name: "tst_YourComponent"
        width: 200; height: 200;
        
        function test_evaluation() {
            verify(true, "Components evaluated natively!")
        }
    }
    ```
3. Open `tests/qml/CMakeLists.txt` and append your `.qml` stub strictly inside the matching `qt_add_executable()` source bounds natively. This explicitly forces QtCreator to detect and list your visual integration test!
