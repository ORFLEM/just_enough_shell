{
  description = "Just Enough Shell (JES) - Desktop Shell for wayland WMs";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable }:
    let
      lib = nixpkgs.lib;
      forAllSystems = lib.genAttrs [ "x86_64-linux" "aarch64-linux" ];

      # ── Сборка всех Go-бинарников JES из for-quickshell/go ──────────────
      # Тулчейн из pkgs-unstable: go.mod модулей требуют go >= 1.25.x
      # (тот же источник, что и `go` в environment.systemPackages).
      #
      # Зависимости ВЕНДОРЯТСЯ в репо (go mod vendor, каталог vendor/ в
      # каждом модуле) и vendorHash = null. Это значит:
      #   - сборка полностью герметична, НИКАКОЙ сети в sandbox не нужно
      #     (иначе go-modules-фетчер лезет на proxy.golang.org и падает
      #     по DNS, если в sandbox недоступен резолвер хоста);
      #   - не нужно вычислять/поддерживать vendorHash при апдейтах
      #     зависимостей — достаточно перегенерить vendor/.
      # Порядок при изменении зависимостей:
      #   go mod tidy && go mod vendor && git add vendor go.mod go.sum
      mkJesPackages = pkgsU:
        let
          # Корневой модуль. Стандартная раскладка cmd/<имя>/main.go:
          #   cmd/cal            ← бывший calendar.go        → бинарник cal
          #   cmd/cava-internal  ← бывший cava-processor.go  → Cava-internal
          #   cmd/launch         ← бывший launch.go          → launch
          #   cmd/screenpicker   ← бывший screenpicker.go    → screenpicker
          #   cmd/music          ← бывший music/music.go     → music
          jes-go-tools = pkgsU.buildGoModule {
            pname = "jes-go-tools";
            version = "1.0.0";
            src = ./for-quickshell/go;

            vendorHash = null; # vendor/ лежит в репо

            # GOFLAGS (-mod=vendor -trimpath) и GOCACHE/GOPATH buildGoModule
            # выставляет сам
            buildPhase = ''
              runHook preBuild
              go build -o cal ./cmd/cal
              go build -o Cava-internal ./cmd/cava-internal
              go build -o launch ./cmd/launch
              go build -o screenpicker ./cmd/screenpicker
              go build -o music ./cmd/music
              runHook postBuild
            '';

            installPhase = ''
              runHook preInstall
              mkdir -p $out/bin
              install -Dm755 cal Cava-internal launch screenpicker music -t $out/bin
              runHook postInstall
            '';
          };

          # Отдельный модуль wallpaper-picker (cmd-раскладка не нужна —
          # один main-пакет в корне). vendor/ тоже в репо.
          jes-wallpaper-picker = pkgsU.buildGoModule {
            pname = "wallpaper-picker";
            version = "1.0.0";
            src = ./for-quickshell/go/wallpaper;

            vendorHash = null; # vendor/ лежит в репо
            # один main-пакет в корне модуля — стандартная сборка,
            # бинарник получит имя модуля: wallpaper-picker
          };

          # coreaura НЕ собираем: в рантайме JES не используется
          # (import "CoreAura" в shell.qml закомментирован, собранного
          # бинарника в репо нет). Если понадобится — аналогично:
          # go mod vendor в for-quickshell/go/coreaura + buildGoModule.
        in
        {
          inherit jes-go-tools jes-wallpaper-picker;
          default = jes-go-tools;
        };
    in
    {
      # Удобная точка входа для проверки сборки бинарников без пересборки
      # всей системы:  nix build .#jes-go-tools .#jes-wallpaper-picker
      packages = forAllSystems (system:
        mkJesPackages (import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        }));

      nixosModules.default = { config, lib, pkgs, ... }:
        let
          cfg = config.services.jes;

          pkgs-unstable = import nixpkgs-unstable {
            system = pkgs.system;
            config.allowUnfree = true;
          };

          jesPkgs = mkJesPackages pkgs-unstable;

          # Сборка ассетов JES. Закоммиченные в репо бинарники
          # (.local/JES/quickshell/scripts/* и др.) перезаписываются
          # свежесобранными из Go-исходников.
          jes-assets = pkgs.stdenv.mkDerivation {
            pname = "jes-assets";
            version = "1.0.0";
            src = ./.;

            installPhase = ''
              mkdir -p $out/local-folder $out/config-jes

              cp -r .local/* $out/local-folder/ 2>/dev/null || true
              cp -r .config/JES/* $out/config-jes/ 2>/dev/null || true

              # ── Заменяем бинарники собранными из for-quickshell/go ──
              SCRIPTS=$out/local-folder/JES/quickshell/scripts
              install -Dm755 ${jesPkgs.jes-go-tools}/bin/cal           -t $SCRIPTS
              install -Dm755 ${jesPkgs.jes-go-tools}/bin/Cava-internal -t $SCRIPTS
              install -Dm755 ${jesPkgs.jes-go-tools}/bin/music         -t $SCRIPTS
              install -Dm755 ${jesPkgs.jes-go-tools}/bin/screenpicker  -t $SCRIPTS
              install -Dm755 ${jesPkgs.jes-wallpaper-picker}/bin/wallpaper-picker -t $SCRIPTS

              # launch.go → launcher/launch
              install -Dm755 ${jesPkgs.jes-go-tools}/bin/launch \
                $out/local-folder/JES/quickshell/launcher/launch

              # второй экземпляр wallpaper-picker рядом с Walls.qml
              install -Dm755 ${jesPkgs.jes-wallpaper-picker}/bin/wallpaper-picker \
                $out/local-folder/JES/quickshell/wallpaper/wallpaper-picker
            '';
          };

          # Отдельная derivation для установки шрифта
          jes-fonts = pkgs.stdenv.mkDerivation {
            pname = "jes-fonts";
            version = "1.0.0";
            src = ./.;
            installPhase = ''
              mkdir -p $out/share/fonts/truetype
              cp .local/share/fonts/ttf/FauxHanamin.ttf $out/share/fonts/truetype/
            '';
          };

          # bash-автодополнение
          jes-completions = pkgs.stdenv.mkDerivation {
            pname = "jes-completions";
            version = "1.0.0";
            phases = [ "installPhase" ];
            installPhase = ''
              mkdir -p $out/share/bash-completion/completions

              cat << 'EOF' > $out/share/bash-completion/completions/jes-cli
              _jes_cli_completion() {
                  local cur prev opts
                  COMPREPLY=()
                  cur="''${COMP_WORDS[COMP_CWORD]}"
                  prev="''${COMP_WORDS[COMP_CWORD-1]}"

                  opts="start-daemon
                  reload-daemon
                  stop-daemon
                  wallShader
                  toggleWallPicker
                  wallType
                  togglePlayer
                  toggleCal
                  togglePower
                  toggleLaunch
                  toggleMap
                  toggleJwindow
                  screenpicker
                  getPlugin
                  getLog
                  editConf
                  brightness-up
                  brightness-down
                  brightness-set
                  brightness-get
                  play-pause
                  next
                  prev
                  next-player
                  prev-player
                  initPlugin
                  makePlugin
                  debuildPlugin
                  pluginBuild
                  pluginCache
                  pluginClearCache
                  blacklistAdd
                  blacklistRemove
                  blacklistList
                  blacklistClear
                  --help -h"

                  if [[ ''${COMP_CWORD} -eq 1 ]]; then
                      COMPREPLY=( $(compgen -W "''${opts}" -- "''${cur}") )
                      return 0
                  fi
              }
              complete -F _jes_cli_completion jes-cli
              EOF
            '';
          };
        in
        {
          options.services.jes = {
            enable = lib.mkEnableOption "Just Enough Shell";

            users = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = "Список пользователей, для которых устанавливается Just Enough Shell";
            };
          };

          config = lib.mkIf cfg.enable {
            hardware.i2c.enable = true;

            users.users = lib.genAttrs cfg.users (name: {
              extraGroups = [ "i2c" "networkmanager" ];
            });

            fonts = {
              packages = with pkgs; [
                nerd-fonts.mononoki
                jes-fonts
              ];
            };

            environment.systemPackages =
              # STABLE
              (with pkgs; [
                # Libs
                qt6.qtbase
                qt6.qtdeclarative
                qt6.qtmultimedia
                qt6.qtshadertools
                qt6.qtwayland
                qt6.qtimageformats
                jq
                playerctl
                ddcutil
                brightnessctl
                pamixer
                i2c-tools
                cava
                libnotify
                inotify-tools
                dbus
                pciutils
                ffmpeg
                cliphist
                wl-clipboard
                slurp
                grim
                taplo
                python314
                zip
                unzip

                # gui & tui
                foot
                lxqt.pavucontrol-qt
                kdePackages.kdeconnect-kde
                quickshell
                tela-icon-theme
                micro

                # logic
                bash

                # jes helper
                jes-completions
              ])
              # UNSTABLE
              ++ (with pkgs-unstable; [
                matugen
                go
              ]);

            environment.shellInit = ''
              export PATH="$HOME/.local/bin:$PATH"
            '';

            system.activationScripts.installJesFiles = {
              deps = [ "users" ];
              text = ''
                SRC_LOCAL="${jes-assets}/local-folder"
                SRC_CONFIG="${jes-assets}/config-jes"

                for USER_NAME in ${lib.concatStringsSep " " cfg.users}; do
                  USER_HOME="/home/$USER_NAME"

                  if [ -d "$USER_HOME" ]; then
                    DST_LOCAL="$USER_HOME/.local"
                    DST_STATE="$USER_HOME/.local/state"
                    DST_CONFIG="$USER_HOME/.config/JES"
                    DST_CACHE="$USER_HOME/.cache/JES"

                    mkdir -p "$DST_CACHE/walls"
                    mkdir -p "$DST_CACHE/wall_prevs"
                    mkdir -p "$DST_CACHE/jes_music_art"
                    mkdir -p "$DST_LOCAL/bin"
                    mkdir -p "$DST_LOCAL/share"
                    mkdir -p "$DST_STATE"

                    chown -R "$USER_NAME":users "$DST_CACHE"

                    # Симлинк на каталог JES
                    rm -rf "$DST_LOCAL/JES"
                    ln -sfn "$SRC_LOCAL/JES" "$DST_LOCAL/JES"
                    chown -h "$USER_NAME":users "$DST_LOCAL/JES"

                    # Симлинк на бинарник
                    rm -f "$DST_LOCAL/bin/jes-cli"
                    if [ -f "$SRC_LOCAL/bin/jes-cli" ]; then
                      ln -sfn "$SRC_LOCAL/bin/jes-cli" "$DST_LOCAL/bin/jes-cli"
                      chown -h "$USER_NAME":users "$DST_LOCAL/bin/jes-cli"
                    fi

                    # Копируем файл состояния (тему)
                    if [ -f "$SRC_LOCAL/state/JES_colors.json" ]; then
                      cp -f "$SRC_LOCAL/state/JES_colors.json" "$DST_STATE/JES_colors.json"
                    fi

                    # Настройка прав для состояния
                    if [ -f "$DST_STATE/JES_colors.json" ]; then
                      chown "$USER_NAME":users "$DST_STATE/JES_colors.json"
                      chmod u+rw "$DST_STATE/JES_colors.json"
                    fi

                    # Копирование конфига, если его нет
                    if [ ! -d "$DST_CONFIG" ]; then
                      mkdir -p "$DST_CONFIG"
                      cp -r "$SRC_CONFIG"/* "$DST_CONFIG"/
                      chown -R "$USER_NAME":users "$DST_CONFIG"
                      chmod -R u+rwX "$DST_CONFIG"
                    fi
                  fi
                done
              '';
            };
          };
        };
    };
}
