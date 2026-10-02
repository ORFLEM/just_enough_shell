{
  description = "Just Enough Shell (JES) — WM-agnostic rolling release desktop shell";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable }:
    let
      lib = nixpkgs.lib;
      forAllSystems = lib.genAttrs [ "x86_64-linux" "aarch64-linux" ];

      mkJesGoTools = pkgsU:
        let
          tools = pkgsU.buildGoModule {
            pname = "jes-go-tools";
            version = "1.0.0";
            src = ./for-quickshell/go;
            vendorHash = null;
            buildPhase = ''
              runHook preBuild
              go build -o cal ./cmd/cal
              go build -o Cava-internal ./cmd/cava-internal
              go build -o launch ./cmd/launch
              go build -o screenpicker ./cmd/screenpicker
              go build -o music ./cmd/music
              go build -o audio ./cmd/audio
              go build -o network ./cmd/network
              go build -o bluetooth ./cmd/bluetooth
              runHook postBuild
            '';
            installPhase = ''
              runHook preInstall
              mkdir -p $out/bin
              install -Dm755 cal Cava-internal launch screenpicker music audio network bluetooth -t $out/bin
              runHook postInstall
            '';
          };
          wallpaper-picker = pkgsU.buildGoModule {
            pname = "wallpaper-picker";
            version = "1.0.0";
            src = ./for-quickshell/go/wallpaper;
            vendorHash = null;
          };
          coreaura = pkgsU.buildGoModule {
            pname = "coreaura";
            version = "1.0.0";
            src = ./for-quickshell/go/coreaura;
            vendorHash = null;
            postInstall = ''
              mv $out/bin/coreaura $out/bin/CoreAura
            '';
          };
        in
        { inherit tools wallpaper-picker coreaura; };

      mkJes = pkgsU:
        let
          go = mkJesGoTools pkgsU;
          quickshell = pkgsU.quickshell;
          storeShell = "$out/JES/quickshell";
        in
        pkgsU.stdenvNoCC.mkDerivation {
          pname = "jes";
          version = "02.10.2026";
          src = ./.;

          dontConfigure = true;
          dontBuild = true;

          installPhase = ''
            runHook preInstall

            mkdir -p $out/bin \
                     $out/share/jes/quickshell \
                     $out/share/jes/config \
                     $out/share/jes/matugen \
                     $out/share/fonts/truetype \
                     $out/lib/systemd/user \
                     $out/share/bash-completion/completions

            cp -r .local/JES/quickshell/* $out/share/jes/quickshell/
            chmod 755 $out/share/jes/quickshell/scripts/* || true

            for b in cal Cava-internal music audio network bluetooth; do
              install -Dm755 ${go.tools}/bin/$b \
                $out/share/jes/quickshell/scripts/$b
            done
            install -Dm755 ${go.tools}/bin/launch \
              $out/share/jes/quickshell/launcher/launch
            install -Dm755 ${go.tools}/bin/screenpicker \
              $out/share/jes/quickshell/screenpicker/screenpicker
            for b in wallpaper-picker; do
              install -Dm755 ${go.wallpaper-picker}/bin/$b \
                $out/share/jes/quickshell/wallpaper/$b
            done
            install -Dm755 ${go.coreaura}/bin/CoreAura \
              $out/share/jes/quickshell/CoreAura/CoreAura

            install -Dm755 .local/bin/jes-cli $out/bin/jes-cli

            ln -sfn share/jes $out/JES

            cp -r .config/JES/* $out/share/jes/config/
            cp -r .local/JES/matugen/* $out/share/jes/matugen/
            cp .local/share/fonts/ttf/FauxHanamin.ttf \
               $out/share/fonts/truetype/

            cat > $out/lib/systemd/user/jes.service <<EOF
            [Unit]
            Description=Just Enough Shell
            PartOf=graphical-session.target
            After=graphical-session.target
            Requisite=graphical-session.target

            [Service]
            ExecStart=${quickshell}/bin/qs -c ${storeShell}
            Restart=on-failure
            RestartSec=2

            [Install]
            WantedBy=graphical-session.target
            EOF

            mkdir -p $out/share/zsh/site-functions $out/share/fish/vendor_completions.d
            if [ -d ./completions ]; then
              install -Dm644 completions/jes-cli.bash $out/share/bash-completion/completions/jes-cli
              install -Dm644 completions/_jes-cli   $out/share/zsh/site-functions/_jes-cli
              install -Dm644 completions/jes-cli.fish $out/share/fish/vendor_completions.d/jes-cli.fish

            else
              cat << 'EOF' > $out/share/bash-completion/completions/jes-cli
              _jes_cli_completion() {
                  local cur opts
                  COMPREPLY=()
                  cur="''${COMP_WORDS[COMP_CWORD]}"
                  opts="start-daemon reload-daemon stop-daemon wallShader toggleWallPicker wallType togglePlayer toggleCal togglePower toggleLaunch toggleMap toggleJwindow screenpicker getPlugin getLog editConf brightness-up brightness-down brightness-set brightness-get play-pause next prev next-player prev-player initPlugin makePlugin debuildPlugin pluginBuild pluginCache pluginClearCache blacklistAdd blacklistRemove blacklistList blacklistClear ping --help -h --version -v"
                  if [[ ''${COMP_CWORD} -eq 1 ]]; then
                      COMPREPLY=( $(compgen -W "''${opts}" -- "''${cur}") )
                      return 0
                  fi
              }
              complete -F _jes_cli_completion jes-cli
            EOF
            fi

            runHook postInstall
          '';

          meta.mainProgram = "jes-cli";
        };
    in
    {
      packages = forAllSystems (system:
        let
          pkgsU = import nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true;
          };
        in
        rec {
          jes = mkJes pkgsU;
          tomlFmt =
            if builtins.typeOf pkgs.formats.toml == "set"
            then pkgs.formats.toml
            else pkgs.formats.toml { };
          default = jes;
        });

      nixosModules.default = { config, lib, pkgs, ... }:
        let
          cfg = config.programs.jes;
          pkgsU = import nixpkgs-unstable {
            system = pkgs.system;
            config.allowUnfree = true;
          };
          jes = mkJes pkgsU;
        in
        {
          options.programs.jes = {
            enable = lib.mkEnableOption "Just Enough Shell";
            package = lib.mkOption {
              type = lib.types.package;
              default = jes;
            };
            autoStart = lib.mkOption {
              type = lib.types.bool;
              default = false;
            };

            coreAura = {
              enable = lib.mkEnableOption "CoreAura system monitoring daemon";

              package = lib.mkOption {
                type = lib.types.package;
                default = cfg.package;
                defaultText = lib.literalExpression "config.programs.jes.package";
                description = "Package providing the CoreAura binary.";
              };

              settings = lib.mkOption {
                type = tomlFmt.type;;
                default = {
                  CoreAura = {
                    enabled = true;
                    kernel_priority_max = 3;
                    services = [ ];
                    log_tail_lines = 300;
                    resource_poll_interval_sec = 5;
                    cpu_threshold_percent = 85;
                    gpu_threshold_percent = 85;
                    dedup_window_sec = 30;
                  };
                };
                description = ''
                  CoreAura TOML config. Written to /etc/jes/coreaura.toml.
                  Matches the structure expected by main.go (top-level [CoreAura] table).
                '';
              };
            };
          };

          config = lib.mkIf cfg.enable {
            hardware.i2c.enable = lib.mkDefault true;
            hardware.bluetooth.enable = lib.mkDefault true;

            services.udev.extraRules = lib.mkIf config.hardware.i2c.enable ''
              SUBSYSTEM=="i2c", KERNEL=="i2c-[0-9]*", TAG+="uaccess"
            '';

            systemd.user.tmpfiles.rules = [
              "d %h/.cache/JES                    0755 - - -"
              "d %h/.cache/JES/walls              0755 - - -"
              "d %h/.cache/JES/wall_prevs         0755 - - -"
              "d %h/.cache/JES/jes_music_art      0755 - - -"
              "d %h/.local/state                  0755 - - -"

              "C %h/.config/JES                   0755 - - - ${cfg.package}/share/jes/config"
            ];

            fonts.packages = with pkgs; [
              nerd-fonts.mononoki
              cfg.package
            ];

            environment.systemPackages = [ cfg.package ] ++ (with pkgs; [
              jq ddcutil brightnessctl pamixer i2c-tools cava
              libnotify dbus pciutils ffmpeg cliphist
              wl-clipboard grim taplo python314 zip unzip
              kdePackages.kdeconnect-kde micro qt6.qtbase
              qt6.qtdeclarative qt6.qtmultimedia
              qt6.qtshadertools qt6.qtwayland
              qt6.qtimageformats
            ]) ++ (with pkgsU; [ matugen quickshell ]);

            systemd.user.services.jes = lib.mkIf cfg.autoStart {
              description = "Just Enough Shell";
              wantedBy = [ "graphical-session.target" ];
              partOf = [ "graphical-session.target" ];
              after = [
                "graphical-session.target"
                "systemd-tmpfiles-setup.service"
              ];
              wants = [ "systemd-tmpfiles-setup.service" ];
              serviceConfig = {
                ExecStart = "${pkgsU.quickshell}/bin/qs -c ${cfg.package}/JES/quickshell";
                Restart = "on-failure";
                RestartSec = 2;
              };
            };

            # ── CoreAura daemon ────────────────────────────────────────

            environment.etc."jes/coreaura.toml" = lib.mkIf cfg.coreAura.enable {
              source = tomlFmt.generate "coreaura.toml" cfg.coreAura.settings;
            };

            services.dbus.packages = lib.mkIf cfg.coreAura.enable [
              (pkgs.writeTextDir "share/dbus-1/system.d/org.jes.CoreAura.conf" ''
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
              '')
            ];

            systemd.services.coreaura = lib.mkIf cfg.coreAura.enable {
              description = "CoreAura — JES monitoring daemon";
              wantedBy = [ "multi-user.target" ];
              wants = [ "dbus.service" ];
              after = [ "dbus.service" "systemd-journald.service" ];

              path = with pkgs; [ systemd coreutils ];

              serviceConfig = {
                Type = "simple";
                ExecStart = "${cfg.coreAura.package}/share/jes/quickshell/CoreAura/CoreAura -config /etc/jes/coreaura.toml";
                Restart = "on-failure";
                RestartSec = 2;

                User = "root";
                Group = "root";

                NoNewPrivileges = true;
                ProtectSystem = "full";
                ProtectHome = false;
                ProtectKernelTunables = true;
                ProtectKernelModules = true;
                ProtectControlGroups = true;
                ProtectClock = true;
                ProtectHostname = true;
                PrivateTmp = true;
                RestrictSUIDSGID = true;
              };
            };
          };
        };
    };
}
