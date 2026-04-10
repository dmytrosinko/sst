# Project Architecture

This document describes the high-level architecture of the Self Service Terminal (SST) application. The project is designed with modularity, scalability, and strict separation of concerns in mind, leveraging Qt 6's rich QML module system natively.

---

## 1. High-Level Overview

SST is a Qt 6.10 C++/QML application tailored for kiosk and terminal environments. The architecture is cleanly divided into:
- **Core Entry Point (`app`)**: The main executable that bootstraps the primary engine, located directly under `src/`.
- **Modules**: Reusable cross-cutting capabilities, located in `src/modules/`:
  - `modules.controls` — shared UI component library (buttons, inputs, keyboard, numpad)
  - `modules.finance` — transaction lifecycle controller, session model, and backend singleton
  - `modules.hardware` — hardware abstraction layer (validator driver, emulator, system telemetry)
  - `modules.services` — JSON-backed service catalog tree model (`ServiceTreeModel`)
  - `modules.style` — design token theming (palettes, colors, typography)
  - `modules.ui` — application-level screens and UI chrome (home, header, footer, overlays)
- **Services**: Dedicated stateful workflows designed for user-facing terminal operations, located in `src/services/`.

---

## 2. Services Architecture

One of the central pillars of the SST project is **Services**. A service represents a discrete business workflow that we offer to the user. 

### What is a Service?
A service is a predefined set of steps (typically screens) that a user must complete to arrive at a goal. 
For example, to process a "Top Up Bank Account" service:
1. **Screen 1**: User inputs their account number.
2. **Screen 2**: User inserts cash.
3. **Screen 3**: User retrieves their receipt.

Each individual step maps to a dedicated screen within the service. 

### Service Module Rules
To enforce architectural boundaries, all services are strictly treated as standalone QML modules and must observe the following rules:

1. **Location**: All services must act as QML modules placed inside the **`src/services/[service name]`** directory.
2. **Structural Parity**: Aside from residing in the `src/services/` parent directory rather than `src/modules/`, every service module **must strictly adhere to the standard QML module layout defined in `doc/CONTRIBUTING.md`**.
   - QML UI items go inside a `qml/` subfolder.
   - Assets go inside an `assets/` subfolder.
   - C++ logic files must be CamelCase and may sit at the service root.
3. **Module URI**: Following the project's namespace schema, the URI defined in the service's `CMakeLists.txt` should be: `URI service.[service name]`.

### Example: The `testservice` Module
To visualize how these rules come together, consider the `testservice` implementation located in `src/services/testservice`:

```text
src/services/testservice/
├── CMakeLists.txt             # Defines 'project(testservice)' and 'URI service.testservice'
├── ServiceModel.h             # C++ logic class (in 'namespace testservice')
├── ServiceModel.cpp           # Registers as a QML_SINGLETON to control the workflow
└── qml/
    ├── Service.qml                # Main workflow wrapper using QQC2.SwipeView
    ├── NumericInputScreen.qml     # Reusable numeric entry screen
    ├── ScreenInputString.qml      # Free-text string entry step
    ├── ScreenInputNumber.qml      # Numeric entry step
    ├── ScreenInputPhone.qml       # Phone number entry step
    ├── ScreenInputIban.qml        # IBAN entry step
    ├── ScreenInputCardNumber.qml  # Card number entry step
    ├── ScreenInsertCash.qml       # Cash insertion / validator step
    └── Screen3.qml               # Confirmation / receipt step
```

**Workflow Execution Example:**
1. The backend `ServiceModel` tracks `m_currentScreen` as an integer and binds it to a standard QML property `currentScreen`.
2. The primary `Service.qml` wraps all active screens in a `SwipeView` and strictly observes the C++ model:
   ```qml
   QQC2.SwipeView {
       currentIndex: ServiceModel.currentScreen
       interactive: false // Lock interaction so UI buttons control flow
       
       Screen1 { onQuitRequested: root.quitService() }
       Screen2 {}
       Screen3 {}
   }
   ```
3. Buttons within `Screen1`/`2` directly trigger `ServiceModel.goToNextScreen()` or `goToPreviouseScreen()` natively crossing the C++/QML boundary. 

---

## 3. General Modules Architecture

While Services handle direct user-facing workflows, generalized features that run headless or behave as globally available components belong in the `src/modules/` directory.

- Examples: `hardware` module (parsing CPU stats, dispatching hardware commands), `network` module, `printing` module.
- URIs evaluate dynamically to: `modules.[module name]`.

By strictly separating terminal logic into **Modules** (tools/features) and **Services** (user workflows), the SST architecture remains scalable and testable.

---

## 4. Style & Theming Architecture

All visual tokens (colors, font sizes) are centralized in the **`modules.style`** QML module located at `src/modules/style/`. This eliminates hardcoded color strings scattered across QML files and enables future theme switching.

### Module Layout

```text
src/modules/style/
├── CMakeLists.txt          # Registers all three singletons; URI = modules.style
└── qml/
    ├── Style.qml           # Root singleton — the single import consumers use
    ├── DarkStyle.qml       # Concrete dark theme — Nord-palette design tokens
    └── SimbankPallete.qml  # Extended brand palette — secondary colours, gradients, font family
```

### How It Works

1. **`DarkStyle.qml`** — a `pragma Singleton` `QtObject` that declares every design token used across the application as `readonly property` values:

   | Category | Properties |
   |----------|-----------|
   | **Backgrounds** | `background`, `surfacePrimary`, `surfaceSecondary`, `surfaceHover`, `surfacePressed` |
   | **Borders** | `borderDefault`, `borderAccent`, `borderStrong` |
   | **Text** | `textPrimary`, `textSecondary`, `textOnAccent`, `textHeading` |
   | **Accent / Status** | `accentPrimary`, `accentSecondary`, `statusSuccess`, `statusWarning` |
   | **Dynamic/Themed** | `backgroundGradient`, `tileColor`, `categoryTileColor`, `buttonColor`, `buttonDisabledColor`, `backButtonColor`, `languageToggleColor` |
   | **Per-component Text** | `tileTextColor`, `buttonTextColor`, `backButtonTextColor`, `languageToggleTextColor`, etc. |
   | **Keyboard** | `keyboardBackground`, `keyColor`, `keyHoverColor`, `keyPressedColor`, `keyTextColor`, `keyHighlightColor`, etc. |
   | **Input Fields** | `inputTextColor`, `inputPlaceholderColor`, `inputBackgroundColor`, `inputBorderColor` |
   | **Typography** | `fontSizeSmall` (14), `fontSizeNormal` (16), `fontSizeLarge` (18), `fontSizeXLarge` (24) |

2. **`SimbankPallete.qml`** — a `pragma Singleton` `QtObject` providing the extended brand palette:
   - Named flat colours (`logoWhite`, `accentPurpleBase`, `statusGreen`, and 40+ secondary palette colours)
   - 17 named background gradients (`backgroundGradient1`…`backgroundGradient17`) for the animated background
   - `fontFamily` — the application-wide typeface (EuclidCircularB)
   - `allSecondaryColors` and `allBackgroundGradients` list properties consumed by `StyleConfigurator`

3. **`Style.qml`** — a `pragma Singleton` `QtObject` that exposes a single `currentStyle` property pointing to a `DarkStyle` instance. All consumer code references `Style.currentStyle.*`, keeping one clean indirection layer for future theme switching.

3. **Consumer usage** — any QML file that needs a color or font size imports the module and reads the token:

   ```qml
   import modules.style

   Rectangle {
       color: Style.currentStyle.surfacePrimary
       border.color: Style.currentStyle.borderAccent

       Text {
           color: Style.currentStyle.textPrimary
           font.pixelSize: Style.currentStyle.fontSizeNormal
       }
   }
   ```

### Adding a New Theme

To create an alternative theme (e.g., `LightStyle`):

1. Add `qml/LightStyle.qml` as a `pragma Singleton` `QtObject` with the **same property names** but different values.
2. Register it in `CMakeLists.txt` with `QT_QML_SINGLETON_TYPE TRUE`.
3. Update `Style.qml` to switch `currentStyle` between `DarkStyle` and `LightStyle` based on user preference or configuration.

---

## 5. Testing Architecture (CTest & QtTest)

To ensure regressions do not bleed into the isolated components natively, the testing boundaries map dynamically across CTest utilizing:

- **1:1 File Segregation**: Every source file has a perfectly isolated `tst_[filename]` counterpart.
- **GUI-Less Isolation**: C++ structural behaviors bind entirely to `QTEST_GUILESS_MAIN` natively explicitly avoiding system interaction rendering timeouts seamlessly across Linux or Windows headless builds natively!
- **Componentized View Bounds**: QML evaluates simulated UI constraints by implicitly isolating bounds properties (`width/height`) directly against component wrappers mapped within `qt_add_executable()` natively avoiding Window execution constraints!

---

## 6. Keyboard Shortcuts

All keyboard shortcuts are declared as QML `Shortcut` items and are active while the application window is focused.

| Shortcut | Defined In | Description |
|----------|------------|-------------|
| `Ctrl+X` | `src/Main.qml` | Quit the application immediately (`Qt.quit()`) |
| `Ctrl+G` | `src/modules/ui/qml/Home.qml` | Toggle the **Style Configurator** window (live theme editor) |
| `Ctrl+A` | `src/modules/ui/qml/Home.qml` | Toggle **Attract Mode** — starts the idle kiosk animation; press again while active to stop it |
| `Ctrl+E` | `src/modules/ui/qml/Home.qml` | Toggle the **Validator Emulator** debug window (hardware-emulation UI for bill-validator testing) |
