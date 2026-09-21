# *JES* Architecture and Module Structure

## Architectural principles
- **Separation of UI and logic**: QML (Quickshell) is only responsible for rendering and input. All data processing, IPC parsing and system calls are moved into separate modules.
- **Purpose-based modularity**: Each UI component (bar, launcher, notifications, etc.) is isolated in its own folder with minimal cross-dependencies.
- **Event-driven model (subscribe)**: Instead of polling in bash loops, long-lived connections are used via Go binaries that subscribe to WM/MPD/system events.
- **Stable shell layer**: Scripts are written in POSIX sh/bash. No dependency on fish/zsh runtime, plugins or interactive features.
- **Dynamic theme**: `base16.json` uses the zenburn palette. `colors.json` handles gradient backgrounds, text and accent colors; everything is extracted from the wallpaper thanks to `matugen`.

## -- Project working tree and module purposes --:
```
./quickshell/
├── shell.qml                 # Quickshell entry point. Registers and positions modules.
├── bar/                      # Panel.
│   ├── components/           # Panel popups + workspace buttons.
│   └── images/               # Static icons, assets.
├── launcher/                 # Application launcher: search, categories, background shader, Go backend.
├── wallpaper/                # Wallpaper selection and rendering: previews, applying, TOML config, wallpaper rendering.
├── notifications/            # Notification daemon.
├── popSysInf/                # System information popup (Brightness, Volume).
├── power/                    # Session menu: shutdown, reboot, sleep, logout, lock.
├── helpers/                  # QML helpers.
├── screenpicker/             # Screenshot tool.
├── lockScreen/             # Lock screen.
└── scripts/                  # Logic core: compiled Go binaries + bash scripts.
```

## -- Data flow and IPC --:
1. **Initialization**: `shell.qml` starts the module. Each module calls the corresponding script from `scripts/` on startup.
2. **Data collection**:
   - Go binaries (`music`, `Cava-internal`, `cal`) handle logic with large data volumes that need processing.
   - Bash scripts (`brightness.sh`, `vol.sh`, `workspace-*.sh`, ...) are the main logic, made for system portability and readability.
3. **Delivery to UI**: Data is passed via `stdout` (JSON, or just a plain string for visual programs like cava) → parsed in QML via `JsonListen`/`JsonPoll` → updates widget properties.
4. **Feedback loop**: User actions (click, hotkey) → script/binary call → command sent to WM/MPD/pipewire → event updates the UI.

## -- Stack and optimization --:
| Layer | Technology | Role |
|------|------------|------|
| WM | swayfx (primary), DriftWM (primary), Hyprland, Niri (WIP) | Tiling, effects, IPC |
| UI | Quickshell (Qt Quick / QML) | Rendering, animations, input |
| Backend | Go 1.21+ | Logic processing large data volumes |
| Shell | Bash 5.x / POSIX sh | Main logic |
| Theme | base16 + matugen | Static palette + dynamic theme |
| Audio | PipeWire + pavucontrol-qt | Mixing, MPRIS, Cava |

**Metrics**: CPU idle ~1–2% (Go subscribe) vs 35–45% (bash polling). Binaries are statically linked, logic size ~3.5–4.5 MB.

## -- WM compatibility layer --:
Tiling abstraction is implemented via three pairs of scripts and one file for connecting to shell.qml:
- `active_window-{sway,hypr,niri,driftwm,zwwm}.sh`
- `kb_layout-{sway,hypr,niri,driftwm,zwwm}.sh`
- `workspace-{sway,hypr,niri,zwwm}.sh`
- `camera-{driftwm,zwwm}.sh`
- `{Sway,Hypr,niri,driftwm,zwwm}Bar.qml` in the quickshell/bar/ subdirectory

Quickshell detects the current WM via `$XDG_CURRENT_DESKTOP`, routing calls to the required script. Porting to a new tiling WM only requires implementing output in the same JSON format and adding a mapping.

## -- How to extend --:
1. **New widget**: Create a `widget_name/` folder → QML component + backend (Go/sh) → register in `shell.qml`.
2. **Theme change**: Edit the `matugen` config (you can also rewrite `base16.json`, but it barely affects the visual part of *JES*) → regenerate the palette.
3. **Adding a WM**: Implement an IPC parser following the output spec of existing scripts → add to routing.
4. **Optimization**: Replace a polling script with a Go binary using `subscribe` → update the call in QML.

## -- Other --:
- UI layer (QML): **BSD 3-Clause Licence**
- Scripts and binaries: **BSD 3-Clause Licence**
- Persistent output from scripts/binaries is preferred to improve performance
- Assets (shaders, Go sources, empty script stubs and a QML stub file for connecting another tiling WM): see `for-quickshell/`

## -- Plugins --:
### Installation
```
1. open ~/.config/JES/
2. drop the plugin folder in
3. open config.toml
4. add these lines:
   [[plugin]]
   name = "plugin name" # data in property name from manifest.json
   active = true
```

### [Detailed plugin creation guide](./plugins_eng.md)
