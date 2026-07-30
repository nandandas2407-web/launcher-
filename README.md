# LiquidOS — macOS-Inspired Liquid Glass Launcher for Android Tablets

LiquidOS is a **Flutter-native Android launcher and desktop environment** purpose-built for developers, coders, and power users on Android tablets.

It replaces the default home screen with a dark-first **macOS-style Liquid Glass UI**, featuring a top menu bar, floating glass dock, free-form icon grid, virtual desktop spaces, Spotlight search, Control Center, Mission Control app switcher, and full icon glassification.

---

## 🌟 Key Features

- 🖥️ **macOS-Style Shell:** Top translucent menu bar, centered floating glass dock, dynamic blurred wallpapers, and virtual spaces.
- 🧪 **Coding-First Workflow:** Pre-curated integrations and quick-launch shortcuts for Termux, code editors, Git tools, file managers, and local dev servers.
- 💎 **Liquid Glass Morphism:** Procedural refractive borders, specular top sheen, squircle continuous curves, and customizable backdrop blur.
- 🎨 **Icon Glassification Engine:** Every app icon (including third-party and imported icons) is automatically cropped into a squircle and layered with glass specular highlights.
- 🛠️ **In-App Icon Generator & Customizer:** Design custom glass icons with custom shapes, gradients, and glyphs directly inside the launcher.
- 🔍 **Spotlight Search:** Global search bar for searching apps, launcher settings, and developer quick actions.
- 🎛️ **Control Center & Notifications:** Glass quick settings panel for Wi-Fi, Bluetooth, Volume, Brightness, DND, plus a slide-out calendar/notification drawer.
- 📂 **Glass Folders & Desktop Widgets:** Frosted glass desktop folders, clock widget, system resource gauges (Battery, Storage, RAM), quick terminal shortcut tile, and sticky notes.
- 🔄 **Layout Backup & Restore:** Export and import complete desktop, dock, and icon layouts as JSON files.
- ⚡ **Performance Mode:** Toggleable high-FPS mode for budget tablets, replacing live blur filters with optimized translucent acrylic fills.

---

## 📂 Architecture Overview

```
lib/
├── core/
│   ├── theme/          # Color tokens, glass properties, spring curves, liquid theme
│   ├── platform/       # Java/Android Platform Channel wrapper for Launcher & System APIs
│   └── utils/          # Squircle geometry, JSON layout import/export helpers
├── data/
│   ├── models/         # AppIconModel, FolderModel, DesktopLayoutModel, SettingsModel, etc.
│   ├── repositories/   # Layout, Apps, and Settings repositories with local persistence
├── widgets/            # Reusable Liquid Glass components (Panel, Squircle Clipper, Icon, Controls)
├── features/
│   ├── desktop/        # Desktop canvas, spaces pager, grid layout, icon drag-and-drop, folders
│   ├── dock/           # macOS-style floating dock with proximity magnification & indicators
│   ├── menu_bar/       # Top status bar, system menu, focused app title, status cluster
│   ├── control_center/ # Quick settings toggle tiles
│   ├── notification_center/ # Calendar and notifications drawer
│   ├── spotlight_search/    # Fuzzy app and quick-action search
│   ├── mission_control/     # Card-based recent apps overview
│   ├── icon_customizer/     # Icon picker, SVG importer, and in-app glass icon generator
│   ├── settings/            # macOS Preferences-style settings app
│   ├── onboarding/          # First-run "Set as Home Screen" launcher configuration flow
│   └── widgets_desktop/     # Clock, System Stats, Quick Terminal, Sticky Notes
└── main.dart
```

---

## 🚀 Native Android Setup

LiquidOS is registered as a HOME Launcher in `android/app/src/main/AndroidManifest.xml`:
- Contains `android.intent.action.MAIN` with categories `android.intent.category.HOME` and `android.intent.category.DEFAULT`.
- Requests `QUERY_ALL_PACKAGES` to detect and list installed coding apps and utilities.
- Implements custom Platform Channels in Java (`com.kll.liquidos.MainActivity`) for querying apps, launching intents, requesting home launcher selection, and fetching battery/storage metrics.

---

## 📜 License
MIT License. Built with Flutter & Native Android integration.
