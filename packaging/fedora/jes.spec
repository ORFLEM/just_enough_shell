Name:           jes-shell
Version:        02.10.2026
Release:        1%{?dist}
Summary:        Fast & minimal desktop shell for Wayland WMs
License:        BSD-3-Clause
URL:            https://github.com/ORFLEM/just_enough_shell
Vcs:            https://github.com/ORFLEM/just_enough_shell

Source0:        %{name}-%{version}.tar.gz

%global debug_package %{nil}

BuildRequires:  golang
BuildRequires:  systemd-rpm-macros

# runtime (сверено с systemPackages в flake.nix)
Requires:       quickshell
Requires:       matugen
Requires:       jq ddcutil i2c-tools brightnessctl pamixer
Requires:       cava libnotify dbus pciutils ffmpeg cliphist
Requires:       wl-clipboard grim taplo python3
Requires:       zip unzip
Requires:       kdeconnectd
Requires:       micro
Requires:       pipewire wireplumber upower
Recommends:     bluez

# Qt-модули, которые qs сам не подтягивает (media!)
Requires:       qt6-qtbase qt6-qtdeclarative qt6-qtmultimedia
Requires:       qt6-qtshadertools qt6-qtwayland qt6-qtimageformats qt6-qtsvg

# шрифт: FauxHanamin едет в пакете; мононоки ищи как google-nerd-fonts-mononoki

%description
WM-agnostic desktop shell built on Quickshell. Ships compiled Go tools
(launcher, wallpaper picker, player bridge, calendar, cava wrapper,
screen picker, audio/network/bluetooth helpers), CoreAura monitoring
daemon, plugin system, systemd units and udev rules.

%prep
%autosetup

%build
cd for-quickshell/go
export GOFLAGS="-mod=vendor"
ldflags="-s -w -B gobuildid"
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

%install
install -d %{buildroot}%{_datadir}/jes/quickshell
cp -r .local/JES/quickshell/* %{buildroot}%{_datadir}/jes/quickshell/

# внутренние симлинки QML (в тарболе их нет — transform ломал таргеты)
install -d %{buildroot}%{_datadir}/jes/quickshell/JES
ln -s ../bar     %{buildroot}%{_datadir}/jes/quickshell/JES/Bar
ln -s ../helpers %{buildroot}%{_datadir}/jes/quickshell/JES/Helpers

install -Dm755 for-quickshell/go/launch           %{buildroot}%{_datadir}/jes/quickshell/launcher/launch
install -Dm755 for-quickshell/go/wallpaper/wallpaper-picker %{buildroot}%{_datadir}/jes/quickshell/wallpaper/wallpaper-picker
install -Dm755 for-quickshell/go/music            %{buildroot}%{_datadir}/jes/quickshell/scripts/music
install -Dm755 for-quickshell/go/cal              %{buildroot}%{_datadir}/jes/quickshell/scripts/cal
install -Dm755 for-quickshell/go/Cava-internal    %{buildroot}%{_datadir}/jes/quickshell/scripts/Cava-internal
install -Dm755 for-quickshell/go/screenpicker     %{buildroot}%{_datadir}/jes/quickshell/screenpicker/screenpicker
install -Dm755 for-quickshell/go/audio            %{buildroot}%{_datadir}/jes/quickshell/scripts/audio
install -Dm755 for-quickshell/go/network          %{buildroot}%{_datadir}/jes/quickshell/scripts/network
install -Dm755 for-quickshell/go/bluetooth        %{buildroot}%{_datadir}/jes/quickshell/scripts/bluetooth

install -Dm755 for-quickshell/go/coreaura/CoreAura %{buildroot}%{_datadir}/jes/quickshell/CoreAura/CoreAura

# CoreAura: дефолтный конфиг + system unit + dbus policy
install -d %{buildroot}%{_sysconfdir}/jes
cat > %{buildroot}%{_sysconfdir}/jes/coreaura.toml <<EOF
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

install -d %{buildroot}%{_unitdir}
cat > %{buildroot}%{_unitdir}/coreaura.service <<EOF
[Unit]
Description=CoreAura — JES monitoring daemon
Wants=dbus.service
After=dbus.service systemd-journald.service

[Service]
Type=simple
ExecStart=%{_datadir}/jes/quickshell/CoreAura/CoreAura -config %{_sysconfdir}/jes/coreaura.toml
Restart=on-failure
RestartSec=2

User=root
Group=root

NoNewPrivileges=true
ProtectSystem=full
ProtectHome=false
ProtectKernelTunables=true
ProtectKernelModules=true
ProtectControlGroups=true
ProtectClock=true
ProtectHostname=true
PrivateTmp=true
RestrictSUIDSGID=true

[Install]
WantedBy=multi-user.target
EOF

install -Dm644 /dev/stdin %{buildroot}%{_datadir}/dbus-1/system.d/org.jes.CoreAura.conf <<EOF
<!DOCTYPE busconfig PUBLIC
  "-//freedesktop//DTD D-BUS Bus Configuration 1.0//EN"
  "http://www.freedesktop.org/standards/dbus/1.0/busconfig.dtd">
<busconfig>
  <policy user="root">
    <allow own="org.jes.CoreAura"/>
    <allow send_destination="org.jes.CoreAura"/>
    <allow receive_sender="org.jes.CoreAura"/>
  </policy>

  <policy context="default">
    <allow send_destination="org.jes.CoreAura"/>
    <allow receive_sender="org.jes.CoreAura"/>
  </policy>
</busconfig>
EOF

install -d %{buildroot}%{_datadir}/jes/config
cp -r .config/JES/* %{buildroot}%{_datadir}/jes/config/
install -d %{buildroot}%{_datadir}/jes/matugen
cp -r .local/JES/matugen/* %{buildroot}%{_datadir}/jes/matugen/
install -Dm755 .local/bin/jes-cli %{buildroot}%{_bindir}/jes-cli

install -Dm644 completions/jes-cli.bash %{buildroot}%{_datadir}/bash-completion/completions/jes-cli
install -Dm644 completions/_jes-cli     %{buildroot}%{_datadir}/zsh/site-functions/_jes-cli
install -Dm644 completions/jes-cli.fish %{buildroot}%{_datadir}/fish/vendor_completions.d/jes-cli.fish

install -Dm644 .local/share/fonts/ttf/FauxHanamin.ttf %{buildroot}%{_datadir}/fonts/TTF/FauxHanamin.ttf

install -d %{buildroot}%{_userunitdir}
cat > %{buildroot}%{_userunitdir}/jes.service <<EOF
[Unit]
Description=Just Enough Shell
PartOf=graphical-session.target
After=graphical-session.target
Requisite=graphical-session.target

[Service]
ExecStart=%{_bindir}/qs -c %{_datadir}/jes/quickshell
Restart=on-failure
RestartSec=2

[Install]
WantedBy=graphical-session.target
EOF

install -Dm644 /dev/stdin %{buildroot}%{_udevrulesdir}/99-jes-i2c.rules <<EOF
SUBSYSTEM=="i2c", KERNEL=="i2c-[0-9]*", TAG+="uaccess"
EOF
install -Dm644 /dev/stdin %{buildroot}%{_prefix}/lib/tmpfiles.d/jes.conf <<EOF
d %%h/.cache/JES               0755 - - -
d %%h/.cache/JES/walls         0755 - - -
d %%h/.cache/JES/wall_prevs    0755 - - -
d %%h/.cache/JES/jes_music_art 0755 - - -
d %%h/.local/state             0755 - - -
C %%h/.config/JES              0755 - - - %{_datadir}/jes/config
EOF

%post
%systemd_post coreaura.service

%preun
%systemd_preun coreaura.service

%postun
%systemd_postun_with_restart coreaura.service

%files
%{_bindir}/jes-cli
%{_datadir}/jes
%{_userunitdir}/jes.service
%{_unitdir}/coreaura.service
%{_sysconfdir}/jes/coreaura.toml
%{_datadir}/dbus-1/system.d/org.jes.CoreAura.conf
%{_udevrulesdir}/99-jes-i2c.rules
%{_prefix}/lib/tmpfiles.d/jes.conf
%{_datadir}/fonts/TTF/FauxHanamin.ttf

%{_datadir}/bash-completion/completions/jes-cli
%{_datadir}/zsh/site-functions/_jes-cli
%{_datadir}/fish/vendor_completions.d/jes-cli.fish
%changelog
* Fri Oct 02 2026 _ORFLEM_ <zenkinzahar@gmail.com> - 0.4.0-1
- Add audio/network/bluetooth Go tools.
- Add CoreAura monitoring daemon (system unit, dbus policy, /etc config).

* Tue Sep 29 2026 _ORFLEM_ <zenkinzahar@gmail.com> - 0.3.0-1
- Initial package.