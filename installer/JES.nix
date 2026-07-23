{ config, pkgs, lib, ... }:

let
  cfg = config.services.jes;
in
{
  options.services.jes = {
    enable = lib.mkEnableOption "Install dependencies for Just Enough Shell";
    
    users = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Список пользователей, для которых настраиваются группы и окружение JES";
    };
  };

  config = lib.mkIf cfg.enable {
    
    hardware.i2c.enable = true;

    users.users = lib.genAttrs cfg.users (name: {
      extraGroups = [ "i2c" "networkmanager" ];
    });

    environment.systemPackages = with pkgs; [
      # libs & system tools
      qt6.qtbase
      qt6.qtdeclarative
      qt6.qtmultimedia
      qt6.qtshadertools
      qt6.qtwayland
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

      # logic & languages
      bash
      go
      matugen
    ];

    environment.shellInit = ''
      export PATH="$HOME/.local/bin:$PATH"
    '';
  };
}
