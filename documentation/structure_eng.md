# Architecture and Modular Structure of *JES*

## Architectural principles
- **Separation of UI and logic**: QML (Quickshell) is responsible only for rendering and input. All data processing, IPC parsing, and system calls are handled in separate modules.
- **Modularity by purpose**: Each interface component (bar, launcher, notifications, etc.) is isolated in its own folder. Cross-dependencies are kept to a minimum.
- **Event-driven model (subscribe)**: Instead of polling in bash loops, long-lived connections are used via Go binaries that subscribe to WM/MPD/system events.
- **Stable shell layer**: Scripts are written in POSIX sh/bash. No dependencies on fish/zsh runtimes, plugins, or interactive features.
- **Dynamic theming**: `base16.json` uses the zenburn palette. `colors.json` handles gradient backgrounds, text, and accent colors — all extracted from the wallpaper via `matugen`.

## -- Project working tree and module descriptions -- :
```
.
├── shell.qml                 # Quickshell entry point. Registers and positions modules.
├── colors.json               # Main interface theme.
├── base16.json               # Secondary interface theme.
├── bar/                      # The bar panel.
├── launcher/                 # App launcher: search, categories, background shader, Go backend.
├── wallpaper/                # Wallpaper selection and rendering: preview, apply, TOML config, rendering.
├── notifications/            # Notification daemon.
├── popSysInf/                # System info popup (Brightness, Volume).
├── power/                    # Session menu: shutdown, reboot, sleep, logout, lock.
├── helpers/                  # QML helpers.
├── scripts/                  # Logic core: compiled Go binaries + bash scripts.
└── images/                   # Static icons and assets. (currently nested inside bar/; will be fixed later)
```

## -- Data flow and IPC -- :
1. **Initialization**: `shell.qml` launches modules. Each module, on startup, calls its corresponding script from `scripts/`.
2. **Data collection**:
   - Go binaries (`music`, `Cava-internal`, `cal`) handle logic involving large volumes of data that need processing.
   - Bash scripts (`brightness.sh`, `vol.sh`, `workspace-*.sh`) provide the main logic and are written this way for portability and readability.
3. **Delivery to UI**: Data is passed via `stdout` (JSON, or a plain string for visual programs like cava) → parsed in QML via `JsonListen`/`JsonPoll` → updates widget properties.
4. **User feedback**: User actions (click, hotkey) → script/binary call → command sent to WM/MPD/PipeWire → event updates the UI.

## -- Stack and optimization -- :
| Layer | Technology | Role |
|-------|------------|------|
| WM | swayfx (primary), Hyprland, Niri (WIP) | Tiling, effects, IPC |
| UI | Quickshell (Qt Quick / QML) | Rendering, animations, input |
| Backend | Go 1.21+ | Logic for processing large data volumes |
| Shell | Bash 5.x / POSIX sh | Main logic |
| Theme | base16 + matugen | Static palette + dynamic theming |
| Lock | Hyprlock | Lock screen |
| Audio | PipeWire + wpctl/pavucontrol | Mixing, MPRIS, Cava |

**Metrics**: CPU idle ~5–10% (Go subscribe) vs 35–45% (bash polling). Binaries are statically compiled; total logic weight ~3.5-4.5 MB.

## -- WM compatibility layer -- :
Abstraction from the tiling WM is implemented via three pairs of scripts and one file for connecting to shell.qml:
- `active_window-{sway,hypr,niri}.sh`
- `kb_layout-{sway,hypr,niri}.sh`
- `workspace-{sway,hypr,niri}.sh`
- `{Sway,Hypr,niri}Bar.qml` in the `bar/` subdirectory

Quickshell detects the current WM via `$XDG_CURRENT_DESKTOP` and routes calls to the appropriate script. To port to a new tiling WM, implement output in the same JSON format and add the mapping.

## -- How to extend -- :
1. **New widget**: Create a `widget_name/` folder → QML component + backend (Go/sh) → register in `shell.qml`.
2. **Change theme**: Edit the `matugen` config (you can also rewrite `base16.json`, but it has minimal effect on *JES*'s visuals) → regenerate the palette.
3. **Add a WM**: Implement an IPC parser matching the output spec of existing scripts → add it to the routing.
4. **Optimization**: Replace a polling script with a Go binary using `subscribe` → update the call in QML.

## -- Miscellaneous -- :
- UI layer (QML): GPL-3.0
- Scripts and binaries: GPL-3.0
- Continuous output from scripts/binaries is preferred for better performance.
- Assets (shaders, Go sources, blank script stubs, and a blank QML file for connecting other tiling WMs): see `for-quickshell/`.

## -- Plugins -- :
### Installation
```
1. Open ~/.config/quickshell/
2. Drop the plugin folder there
3. Open config.toml
4. Add the following lines:
   [plugin.plugin-name]
   source = "plugin folder/Main plugin file.qml"
   active = true
```

### [Detailed plugin creation guide](./plugins_eng.md)
