Name: jes-shell
Version: 02.10.2026
Release: alt1
Summary: Fast & minimal desktop shell for Wayland WMs
License: BSD-3-Clause
Group: Graphical desktop/Other
Url: https://github.com/ORFLEM/just_enough_shell
Vcs: https://github.com/ORFLEM/just_enough_shell

BuildRequires: golang

Source0: %name-%version.tar.gz

Requires: quickshell
Requires: matugen
Requires: jq ddcutil i2c-tools brightnessctl pamixer
Requires: cava libnotify dbus pciutils ffmpeg cliphist
Requires: wl-clipboard grim taplo python3
Requires: zip unzip
Requires: kdeconnect
Requires: micro
Requires: inotify-tools
Requires: pipewire wireplumber upower

Requires: qt6-base qt6-declarative qt6-multimedia
Requires: qt6-shadertools qt6-wayland qt6-imageformats qt6-svg

%description
WM-agnostic desktop shell built on Quickshell. Ships compiled Go tools
(launcher, wallpaper picker, player bridge, calendar, cava wrapper,
screen picker, audio/network/bluetooth helpers), CoreAura monitoring
daemon, plugin system, systemd units and udev rules.

%prep
%setup

%build
cd for-quickshell/go
export GOFLAGS="-mod=vendor"
ldflags="-s -w -buildid="
go build -buildvcs=false -trimpath -ldflags="$ldflags" -o launch         ./cmd/launch
go build -buildvcs=false -trimpath -ldflags="$ldflags" -o music          ./cmd/music
go build -buildvcs=false -trimpath -ldflags="$ldflags" -o cal            ./cmd/cal
go build -buildvcs=false -trimpath -ldflags="$ldflags" -o Cava-internal  ./cmd/cava-internal
go build -buildvcs=false -trimpath -ldflags="$ldflags" -o screenpicker   ./cmd/screenpicker
go build -buildvcs=false -trimpath -ldflags="$ldflags" -o audio          ./cmd/audio
go build -buildvcs=false -trimpath -ldflags="$ldflags" -o network        ./cmd/network
go build -buildvcs=false -trimpath -ldflags="$ldflags" -o bluetooth      ./cmd/bluetooth
cd wallpaper
go build -buildvcs=false -trimpath -ldflags="$ldflags" -o wallpaper-picker .
cd ../coreaura
go build -buildvcs=false -trimpath -ldflags="$ldflags" -o CoreAura .
cd ../notifyd
go build -buildvcs=false -trimpath -ldflags="$ldflags" -o jes-notifyd .

%install
install -d %buildroot%_datadir/jes/quickshell
cp -r .local/JES/quickshell/* %buildroot%_datadir/jes/quickshell/

install -d %buildroot%_datadir/jes/quickshell/JES
ln -s ../bar     %buildroot%_datadir/jes/quickshell/JES/Bar
ln -s ../helpers %buildroot%_datadir/jes/quickshell/JES/Helpers

install -d %buildroot%_libdir/jes
install -Dm755 for-quickshell/go/launch                    %buildroot%_libdir/jes/launch
install -Dm755 for-quickshell/go/music                     %buildroot%_libdir/jes/music
install -Dm755 for-quickshell/go/cal                       %buildroot%_libdir/jes/cal
install -Dm755 for-quickshell/go/Cava-internal             %buildroot%_libdir/jes/Cava-internal
install -Dm755 for-quickshell/go/screenpicker              %buildroot%_libdir/jes/screenpicker
install -Dm755 for-quickshell/go/audio                     %buildroot%_libdir/jes/audio
install -Dm755 for-quickshell/go/network                   %buildroot%_libdir/jes/network
install -Dm755 for-quickshell/go/bluetooth                 %buildroot%_libdir/jes/bluetooth
install -Dm755 for-quickshell/go/wallpaper/wallpaper-picker %buildroot%_libdir/jes/wallpaper-picker
install -Dm755 for-quickshell/go/coreaura/CoreAura         %buildroot%_libdir/jes/CoreAura
install -Dm755 for-quickshell/go/notifyd/jes-notifyd       %buildroot%_libdir/jes/jes-notifyd

for b in music cal Cava-internal audio network bluetooth; do
  ln -s %_libdir/jes/$b %buildroot%_datadir/jes/quickshell/scripts/$b
done
ln -s %_libdir/jes/launch           %buildroot%_datadir/jes/quickshell/launcher/launch
ln -s %_libdir/jes/screenpicker     %buildroot%_datadir/jes/quickshell/screenpicker/screenpicker
ln -s %_libdir/jes/wallpaper-picker %buildroot%_datadir/jes/quickshell/wallpaper/wallpaper-picker
ln -s %_libdir/jes/CoreAura         %buildroot%_datadir/jes/quickshell/CoreAura/CoreAura
ln -s %_libdir/jes/jes-notifyd      %buildroot%_datadir/jes/quickshell/notifications/jes-notifyd

install -d %buildroot%_datadir/jes/config
cp -r .config/JES/* %buildroot%_datadir/jes/config/
cat > %buildroot%_datadir/jes/config/coreaura.toml <<EOF
[CoreAura]
enabled = true
kernel_priority_max = 3
services = []
log_tail_lines = 300
resource_poll_interval_sec = 5
cpu_threshold_percent = 85
gpu_threshold_percent = 85
dedup_window_sec = 30
EOF

install -d %buildroot%_datadir/jes/matugen
cp -r .local/JES/matugen/* %buildroot%_datadir/jes/matugen/
install -Dm755 .local/bin/jes-cli %buildroot%_bindir/jes-cli

install -Dm644 completions/jes-cli.bash %buildroot%_datadir/bash-completion/completions/jes-cli
install -Dm644 completions/_jes-cli     %buildroot%_datadir/zsh/site-functions/_jes-cli
install -Dm644 completions/jes-cli.fish %buildroot%_datadir/fish/vendor_completions.d/jes-cli.fish

install -Dm644 .local/share/fonts/ttf/FauxHanamin.ttf %buildroot%_datadir/fonts/ttf/FauxHanamin.ttf

install -d %buildroot%_userunitdir
cat > %buildroot%_userunitdir/jes.service <<EOF
[Unit]
Description=Just Enough Shell
PartOf=graphical-session.target
After=graphical-session.target
Requisite=graphical-session.target

[Service]
ExecStart=%_bindir/qs -c %_datadir/jes/quickshell
Restart=on-failure
RestartSec=2

[Install]
WantedBy=graphical-session.target
EOF

install -Dm644 /dev/stdin %buildroot%_udevrulesdir/99-jes-i2c.rules <<EOF
SUBSYSTEM=="i2c", KERNEL=="i2c-[0-9]*", TAG+="uaccess"
EOF
install -Dm644 /dev/stdin %buildroot%_prefix/lib/tmpfiles.d/jes.conf <<EOF
d %%h/.cache/JES               0755 - - -
d %%h/.cache/JES/walls         0755 - - -
d %%h/.cache/JES/wall_prevs    0755 - - -
d %%h/.cache/JES/jes_music_art 0755 - - -
d %%h/.local/state             0755 - - -
C %%h/.config/JES              0755 - - - %_datadir/jes/config
EOF

%files
%_bindir/jes-cli
%_libdir/jes
%_datadir/jes
%_userunitdir/jes.service
%_udevrulesdir/99-jes-i2c.rules
%_prefix/lib/tmpfiles.d/jes.conf
%_datadir/fonts/ttf/FauxHanamin.ttf

%_datadir/bash-completion/completions/jes-cli
%_datadir/zsh/site-functions/_jes-cli
%_datadir/fish/vendor_completions.d/jes-cli.fish
%changelog
* Fri Oct 02 2026 _ORFLEM_ <zenkinzahar@gmail.com> 0.4.0-alt1
- Add audio/network/bluetooth Go tools.
- Add CoreAura monitoring daemon.

* Tue Sep 29 2026 _ORFLEM_ <zenkinzahar@gmail.com> 0.3.0-alt1
- Initial build for Sisyphus.
