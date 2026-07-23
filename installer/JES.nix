{ config, pkgs, lib, ... }:

let
  cfg = config.services.jes;
  
  # Автоматически находим имена всех реальных пользователей, зарегистрированных в NixOS
  normalUsers = lib.attrNames (lib.filterAttrs (name: u: u.isNormalUser) config.users.users);
in
{
  options.services.jes.enable = pkgs.lib.mkEnableOption "Install dependencies for Just Enough Shell";

  config = lib.mkIf cfg.enable {
    
    # 1. ПАРАМЕТРЫ ДЛЯ ЯДРА: Активируем доступ к шине i2c (для ddcutil и управления монитором)
    hardware.i2c.enable = true;

    # 2. ПАРАМЕТРЫ НА ЮЗЕРА: Автоматически добавляем всех реальных пользователей в нужные группы
    users.users = lib.genAttrs normalUsers (name: {
      extraGroups = [ "i2c" "networkmanager" ];
    });

    # 3. ОБНОВЛЕННЫЕ СИСТЕМНЫЕ ЗАВИСИМОСТИ (Строго по категориям, как вам нравится)
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
      libinotify
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
      nmtui
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

    # Проброс путей для бинарников
    environment.shellInit = ''
      export PATH="$HOME/.local/bin:$PATH"
    '';
  };
}
