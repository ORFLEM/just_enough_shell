# Architecture and Modular Structure of *JES*

## Architectural Principles
- **UI/Logic Separation:** QML (Quickshell) handles only rendering and input. All data processing, IPC parsing, and system calls are delegated to separate modules.
- **Feature-based Modularity:** Each UI component (bar, launcher, notifications, etc.) is isolated in its own directory. Minimal cross-dependencies.
- **Event-driven Model (Subscribe):** Long-lived connections via Go binaries subscribe to WM/MPD/system events, replacing inefficient bash polling loops.
- **Stable Shell Layer:** Scripts are written in POSIX sh/bash. No dependencies on fish/zsh runtimes, plugins, or interactive features.
- **Static Theme + Dynamic Accent:** Zenburn base is fixed. `wallust` extracts only the accent color from wallpapers to highlight UI elements.

## -- Project Directory Tree & Module Roles --:
```
.
├── shell.qml                 # Quickshell entry point. Registers and positions modules.
├── colors.json               # UI color definitions.
├── bar/                      # Status bar.
├── launcher/                 # App launcher: search, categories, background shader, Go backend.
├── wallpaper/                # Wallpaper picker & renderer: previews, application, TOML config, shader rendering.
├── notifications/            # Notification daemon.
├── popSysInf/                # System info popup (Brightness, Volume).
├── power/                    # Session menu: shutdown, reboot, sleep, logout, lock.
├── helpers/                  # QML helpers/utilities.
├── scripts/                  # Logic core: compiled Go binaries + bash scripts.
└── images/                   # Static icons, assets. (Currently nested in `bar/`, will be fixed later)
```

## -- Data Flow & IPC --:
1. **Initialization:** `shell.qml` launches modules. Each module invokes its corresponding script from `scripts/` on startup.
2. **Data Collection:**
   - Go binaries (`sys_info`, `music`, `Cava-internal`, `timed`, `cal`) handle high-volume data processing.
   - Bash scripts (`brightness.sh`, `vol.sh`, `workspace-*.sh`) handle core system logic for portability and readability.
3. **UI Delivery:** Data is streamed via `stdout` (JSON or plain strings for visualizers like Cava) → parsed in QML via `JsonListen`/`JsonPoll` → updates widget properties.
4. **Feedback Loop:** User actions (click, hotkey) → invoke script/binary → send command to WM/MPD/PipeWire → event updates UI.

## -- Stack & Optimization --:
| Layer    | Technology                            | Role                              |
|----------|---------------------------------------|-----------------------------------|
| WM       | swayfx (primary), Hyprland/Niri (WIP) | Tiling, effects, IPC              |
| UI       | Quickshell (Qt Quick / QML)           | Rendering, animations, input      |
| Backend  | Go 1.21+                              | High-volume data processing logic |
| Shell    | Bash 5.x / POSIX sh                   | Core system logic                 |
| Theme    | Zenburn + wallust                     | Static palette + dynamic accent   |
| Lock     | Hyprlock                              | Lock screen                       |
| Audio    | PipeWire + wpctl/pavucontrol          | Mixing, MPRIS, Cava               |

**Metrics:** CPU idle ~5–7% (Go subscribe) vs 35–45% (bash polling). Binaries are statically linked; logic core weighs ~10 MB.

## -- WM Compatibility Layer --:
WM abstraction is implemented via three pairs of scripts:
- `active_window-{sway,hypr,niri}.sh`
- `kb_layout-{sway,hypr,niri}.sh`
- `workspace-{sway,hypr,niri}.sh`

Quickshell detects the current WM via `$XDG_CURRENT_DESKTOP`, routing calls to the appropriate script. To port to a new tiling WM, simply implement output in the same JSON format and add the mapping.

## -- How to Extend --:
1. **New Widget:** Create `widget_name/` directory → QML component + backend (Go/sh) → register in `shell.qml`.
2. **Theme Change:** Edit `wallust` config → regenerate palette → restart Quickshell.
3. **Add WM Support:** Implement IPC parser matching existing script output spec → add to routing.
4. **Optimization:** Replace polling script with Go binary using `subscribe` → update QML invocation.

## -- Misc --:
- **UI Layer (QML):** GPL-3.0
- **Scripts & Binaries:** GPL-3.0
- Continuous output from scripts/binaries is preferred for performance optimization.
- **Assets** (shaders, Go sources, empty stub scripts for other WMs): see `for-quickshell/`
