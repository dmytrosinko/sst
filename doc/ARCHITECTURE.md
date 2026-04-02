# Project Architecture

This document describes the high-level architecture of the Self Service Terminal (SST) application. The project is designed with modularity, scalability, and strict separation of concerns in mind, leveraging Qt 6's rich QML module system natively.

---

## 1. High-Level Overview

SST is a Qt 6.10 C++/QML application tailored for kiosk and terminal environments. The architecture is cleanly divided into:
- **Core Entry Point (`app`)**: The main executable that bootstraps the primary engine, located directly under `src/`.
- **Modules**: Reusable cross-cutting capabilities (like hardware communication), located in `src/modules/`.
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
├── CMakeLists.txt         # Defines 'project(testservice)' and 'URI service.testservice' 
├── ServiceModel.h         # C++ logic class (in 'namespace testservice')
├── ServiceModel.cpp       # Registers as a QML_SINGLETON to control the workflow
└── qml/
    ├── Service.qml        # The main wrapper using QQC2.SwipeView
    ├── Screen1.qml        # e.g., Number input and 'Next' button
    ├── Screen2.qml        # e.g., String input and 'Back' button
    └── Screen3.qml        # e.g., 'Thank You' text and 'Quit' button
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
