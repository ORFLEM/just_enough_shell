{
  description = "Just Enough Shell (JES) - Desktop Shell for wayland WMs";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05"; 
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable }: {

    nixosModules.default = { config, lib, pkgs, ... }:
      let
        cfg = config.services.jes;

        pkgs-unstable = import nixpkgs-unstable {
          system = pkgs.system;
          config.allowUnfree = true;
        };
        
        jes-assets = pkgs.stdenv.mkDerivation {
          pname = "jes-assets";
          version = "1.0.0";
          src = ./.;
          
          installPhase = ''
            mkdir -p $out/local-folder $out/config-jes
            
            cp -r .local/* $out/local-folder/ 2>/dev/null || true
            cp -r .config/JES/* $out/config-jes/ 2>/dev/null || true
          '';
        };

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
                
                opts="start-daemon reload-daemon stop-daemon wallShader toggleWallPicker wallType togglePlayer toggleCal togglePower toggleLaunch toggleMap screenpicker getPlugin getLog editConf --help -h"

                if [[ ''${COMP_CWORD} -eq 1 ]]; then
                    COMPREPLY=( $(compgen -W "''${opts}" -- "''${cur}") )
                    return 0
                fi
            }
            complete -F _jes_cli_completion jes-cli
            EOF
          '';
        };
      in {
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

          environment.systemPackages =
          # STABLE
          (with pkgs; [
            qt6.qtbase
            qt6.qtdeclarative
            qt6.qtmultimedia
            qt6.qtshadertools
            pkgs.qt6.qtwayland
            jq
            playerctl
            ddcutil
            pamixer
            i2c-tools
            cava
            libnotify
            inotify-tools
            dbus
            ffmpeg
            cliphist
            wl-clipboard
            slurp
            grim
            taplo
            python314

            # gui & tui
            foot
            lxqt.pavucontrol-qt
            kdePackages.kdeconnect-kde
            quickshell
            tela-icon-theme
            hyprlock

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
                  mkdir -p "$DST_STATE"

                  chown -R "$USER_NAME":users "$DST_CACHE"

                  rm -rf "$DST_LOCAL/JES"
                  ln -sfn "$SRC_LOCAL/JES" "$DST_LOCAL/JES"
                  chown -h "$USER_NAME":users "$DST_LOCAL/JES"

                  rm -f "$DST_LOCAL/bin/jes-cli"
                  if [ -f "$SRC_LOCAL/bin/jes-cli" ]; then
                    ln -sfn "$SRC_LOCAL/bin/jes-cli" "$DST_LOCAL/bin/jes-cli"
                    chown -h "$USER_NAME":users "$DST_LOCAL/bin/jes-cli"
                  fi

                  if [ ! -d "$DST_CONFIG" ]; then
                    mkdir -p "$DST_CONFIG"
                    cp -r "$SRC_CONFIG"/* "$DST_CONFIG"/
                    chown -R "$USER_NAME":users "$DST_CONFIG"
                    chmod -R u+rwX "$DST_CONFIG"
                  fi

                  if [ ! -f "$DST_STATE/JES_colors.json" ]; then
                    cat << 'EOF' > "$DST_STATE/JES_colors.json"
{
  "background1": "#808080",
  "background2": "#6f6f6f",
  "background3": "#606060",
  "backgroundAlt1": "#383838",
  "backgroundAlt2": "#404040",
  "font": "#dcdccc",
  "fontDark": "#383838",
  "accent": "#ffffff",
  "accent2": "#808080"
}
EOF
                    chown "$USER_NAME":users "$DST_STATE/JES_colors.json"
                    chmod u+rw "$DST_STATE/JES_colors.json"
                  fi
                fi
              done
            '';
          };
        };
      };
  };
}
