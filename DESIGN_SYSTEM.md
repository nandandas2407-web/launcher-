# LiquidOS — Visual & Architectural Design System Specification

## 1. Design Philosophy
LiquidOS combines **Apple Liquid Glass** (macOS/visionOS aesthetic) with **Soft Neumorphism** to create a dark-first, desktop-class operating environment for Android tablets, tailored specifically for coders and power users.

### Strict Design Mandates
1. **Zero Emoji Policy:** No emoji characters allowed anywhere in the UI or assets. All icons are custom-designed vector glyphs composited onto glass squircle backing plates.
2. **Unified Squircle Geometry:** Every container, icon plate, card, dialog, and control uses true superellipse (squircle) rounding with curvature smoothing (`n ≈ 4.0` / continuous corner curvature).
3. **Refractive Glass Edge:** All glass panels feature a 1px top-left to bottom-right refractive gradient border simulating light entry and internal reflection.
4. **Specular Highlight:** Linear and radial gradient sheens layered on top of panels to create visual depth and glass clarity.
5. **Spring Physics Motion:** UI transitions utilize organic spring curves (`SpringSimulation` / stiff-and-damped springs) instead of rigid linear animations.

---

## 2. Design Tokens & Material Parameters

### 2.1 Glass Panel Parameters
- **Backdrop Blur:**
  - Standard Glass: `sigmaX: 30.0, sigmaY: 30.0`
  - Deep Focus Glass (Dialogs/Search): `sigmaX: 45.0, sigmaY: 45.0`
  - Performance Mode Glass: `sigmaX: 10.0, sigmaY: 10.0` (or frosted solid fill)
- **Base Glass Fill:**
  - Dark Mode Base: `LinearGradient(begin: topLeft, end: bottomRight, colors: [Colors.white.withOpacity(0.12), Colors.white.withOpacity(0.04)])`
  - Light Mode Base: `LinearGradient(begin: topLeft, end: bottomRight, colors: [Colors.white.withOpacity(0.55), Colors.white.withOpacity(0.35)])`
- **Refractive Border (1px Hairline):**
  - Gradient: `LinearGradient(begin: topLeft, end: bottomRight, colors: [white.withOpacity(0.65), white.withOpacity(0.08)])`
- **Specular Highlight Gradient:**
  - Top Sheen: `LinearGradient(begin: topCenter, end: center, colors: [white.withOpacity(0.18), white.withOpacity(0.0)])`
- **Drop Shadow:**
  - BoxShadow: `color: black.withOpacity(0.35), blurRadius: 24.0, spreadRadius: -2.0, offset: Offset(0, 10)`

### 2.2 Squircle Superellipse Parameters
- Corner Smoothing Ratio: `0.6` (iOS/macOS continuous squircle)
- Base Squircle Corner Radius:
  - App Icon Base Plate: `18.0px`
  - Small Control Tile: `12.0px`
  - Glass Card / Panel: `22.0px`
  - Modal Window / Search Bar: `28.0px`
  - Dock Container: `32.0px`

### 2.3 Color Palette
- **Background Base:** `#0B0B0F` (Midnight Abyss)
- **Glass Base Tint:** `#14141E` (Dark Translucent Slate)
- **Primary Accent Options:**
  - Aqua Glass (Default): `#00E5FF`
  - Electric Indigo: `#6366F1`
  - Emerald Cyber: `#10B981`
  - Sunset Flame: `#FF6B6B`
  - Golden Ray: `#F59E0B`
- **Status Colors:**
  - Active / Online Dot: `#10B981`
  - Notification Badge Orb: `#FF3B30`
  - Warning State: `#F59E0B`
  - Termux / Code Accent: `#39FF14` (Neon Terminal Green)

### 2.4 Typography Hierarchy
- Font Family: Geometric Sans (`Inter` / System Humanist Sans)
- Scales:
  - Clock Large Display: 64pt, Light (w300)
  - Window / Header Title: 18pt, SemiBold (w600)
  - Menu Bar Item: 13pt, Medium (w500)
  - Desktop Icon Label: 12pt, Medium (w500) with soft drop shadow
  - Monospace (Terminal/Code): `JetBrains Mono` / System Monospace, 13pt

---

## 3. Custom Vector Icon Engine & "Glassification" Pipeline

Every third-party or imported icon passes through the **Glassification Pipeline**:
1. **Source Asset Input:** Third-party app vector/raster or bundled SVG mark.
2. **Squircle Crop Mask:** Clip source content into the continuous squircle boundary.
3. **Backing Plate Composite:** Place asset over the `LiquidGlassPanel` squircle substrate.
4. **Specular & Refractive Overlay:** Layer specular highlight gradient on top.
5. **Output:** A unified 3D-feeling liquid glass icon matching the system identity.

---

## 4. Performance Safeguards
- **Performance Mode Toggle:** Disables live blur filters in low-end device profiles, replacing `BackdropFilter` with semi-opaque acrylic fills to preserve 60-120 FPS.
- **Render Repaint Boundaries:** Key desktop tiles, dock items, and glass panels are isolated using `RepaintBoundary` widgets.
