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
      # базовые библиотеки и системные утилиты
      qt6.qtbase
      qt6.qtdeclarative
      qt6.qtmultimedia
      qt6.qtshadertools
      qt6.qtwayland
      qt6.qtimageformats   # добавлено для поддержки форматов изображений
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

      # дополнительные утилиты (были в flake.nix)
      brightnessctl       # управление яркостью
      pciutils            # информация о PCI-устройствах

      # gui & tui
      foot
      lxqt.pavucontrol-qt
      kdePackages.kdeconnect-kde
      quickshell
      tela-icon-theme
      hyprlock

      # логика и языки
      bash
      go
      matugen
    ];

    environment.shellInit = ''
      export PATH="$HOME/.local/bin:$PATH"
      # Пути для QML-импортов (JES использует свои библиотеки в ~/.local/JES/quickshell)
      export QML_IMPORT_PATH="$HOME/.local/JES/quickshell:/run/current-system/sw/lib/qt-6/qml:$QML_IMPORT_PATH"
      export QML2_IMPORT_PATH="/run/current-system/sw/lib/qt-6/qml:$HOME/.local/JES/quickshell/:$QML2_IMPORT_PATH"
    '';
  };
}
