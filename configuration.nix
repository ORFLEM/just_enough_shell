{ config, pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  boot.loader = {
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      useOSProber = true;
    };
    efi.canTouchEfiVariables = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 20d";
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;
  networking.hostName = "NixOS_PC";
  networking.networkmanager.enable = true;
  time.timeZone = "Asia/Tomsk";

  i18n.defaultLocale = "ru_RU.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ru_RU.UTF-8";
    LC_IDENTIFICATION = "ru_RU.UTF-8";
    LC_MEASUREMENT = "ru_RU.UTF-8";
    LC_MONETARY = "ru_RU.UTF-8";
    LC_NAME = "ru_RU.UTF-8";
    LC_NUMERIC = "ru_RU.UTF-8";
    LC_PAPER = "ru_RU.UTF-8";
    LC_TELEPHONE = "ru_RU.UTF-8";
    LC_TIME = "ru_RU.UTF-8";
  };

  services.xserver.xkb = {
    layout = "ru";
    variant = "";
  };

  services.xserver.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "astronaut-theme";
  };
  services.displayManager.defaultSession = "hyprland";
  programs.hyprland.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
    wireplumber.extraConfig."50-bluez-config" = {
      "monitor.bluez.properties" = {
        "bluez5.enable-msbc" = true;
        "bluez5.enable-sbc-xq" = true;
        "bluez5.enable-hw-volume" = true;
        "bluez5.codecs" = [ "sbc" "aac" "ldac" ];
        "bluez5.ldac-quality" = "high";
      };
    };
  };

  hardware.graphics.enable = true;
  
  # Это пример настроек пользователя | this is example for user settigns:
  # users.users.<юзер | username> = {
  #   isNormalUser = true;
  #   description = "<ник | nikname>";
  #   extraGroups = [ "networkmanager" "wheel" ];
  #   packages = with pkgs; [];
  # };

  nixpkgs.config.allowUnfree = true;

  fonts.packages = with pkgs; [
    iosevka-bin
    texlivePackages.cjk
    texlivePackages.cjkutils
    noto-fonts-cjk-sans
    nerd-fonts._3270
    nerd-fonts.mononoki
  ];
  fonts.fontconfig.enable = true;

  services.dbus.enable = true;
  services.tumbler.enable = true;
  services.flatpak.enable = true;

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
  };

  services.gvfs.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
      };
    };
  };
  services.blueman.enable = true;

  programs.dconf.enable = true;
  services.dbus.packages = with pkgs; [ dconf gnome2.GConf gcr libnotify glib gtk3 ];

  services.gnome.gnome-keyring.enable = true;
  programs.seahorse.enable = true;
  security.pam.services.sddm.enableGnomeKeyring = true;

  environment.systemPackages = with pkgs; [
    # GUI
    blueman
    eww
    file-roller
    gnome-calculator
    hyprland
    hyprlock
    hyprpaper
    kitty
    mpv
    mpvpaper
    pavucontrol
    pdfarranger
    rofi
    rose-pine-hyprcursor
    shotwell
    (sddm-astronaut.override { embeddedTheme = "pixel_sakura"; })
    vscodium

    # Console
    btop
    browsh
    cava
    cliphist
    coreutils-full
    dbus
    fastfetch
    fish
    ffmpeg
    git
    glib
    glibc
    gobject-introspection
    grim
    helix
    jq
    kew
    ldacbt
    libnotify
    lsd
    micro
    neofetch
    pamixer
    p7zip
    playerctl
    (python312.withPackages (ps: with ps; [
      dbus-python
      pygobject3
      jedi-language-server
    ]))
    ranger
    slurp
    unzip
    vlc
    wget
    wireguard-tools
    wl-clipboard
    yazi
    zip

    # AMD Card (Drivers)
    amdvlk
    libdrm
    libGL
    libpulseaudio
    libva
    libvdpau
    mesa
    mesa-demos
    vulkan-loader
    vulkan-validation-layers
    virtualgl
    virtualglLib
    wayland

    # Thunar
    ffmpegthumbnailer
    libgsf
    poppler
    xfce.thunar
    xfce.thunar-archive-plugin
    xfce.tumbler

    # GTK
    gnome-themes-extra
    gtk3
    (papirus-icon-theme.override { color = "yaru"; })
    gruvbox-gtk-theme
    kanagawa-gtk-theme
    rose-pine-cursor
  ];

  environment.sessionVariables = {
    GTK_THEME = "Kanagawa-B";
    ICON_THEME = "Papirus-Dark";
    QT_STYLE_OVERRIDE = "gtk4";
    QT_QPA_PLATFORM = "wayland";
    GDK_BACKEND = "wayland";
    NIXOS_OZONE_WL = "1";
  };
    
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    glib
    glibc
    gobject-introspection
    (python312.withPackages (ps: with ps; [
      dbus-python
      pygobject3
      jedi-language-server
    ]))
    dbus
  ];

  programs.hyprland = {
    xwayland.enable = true;
  };

  programs.steam.enable = true;
  programs.steam.package = pkgs.steam.override {
    extraPkgs = pkgs: with pkgs; [ libdrm wayland ];
  };

  console = {
      # ЛУЧШИЙ ВЫБОР: Spleen с Box Drawing + Block Elements
      font = "ter-v32n";  # или spleen-16x32 для меньших экранов
      
      packages = with pkgs; [
        spleen           # Box Drawing, Block Elements, Braille Patterns
        unifont          # Unifont PSF версия - максимум Unicode символов
        terminus_font    # Запасной вариант
      ];
    };
  systemd.services.set-tty-colors = {
    description = "Apply custom TTY color scheme at boot";
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      for tty in /dev/tty{1..6}; do
        echo -en "\e]P01d2021" > "$tty"  # black
        echo -en "\e]P1cc241d" > "$tty"  # red
        echo -en "\e]P298971a" > "$tty"  # green
        echo -en "\e]P3d79921" > "$tty"  # yellow
        echo -en "\e]P4458588" > "$tty"  # blue
        echo -en "\e]P5b16286" > "$tty"  # magenta
        echo -en "\e]P6689d6a" > "$tty"  # cyan
        echo -en "\e]P7a89984" > "$tty"  # white
        echo -en "\e]P8928374" > "$tty"  # bright black
        echo -en "\e]P9fb4934" > "$tty"  # bright red
        echo -en "\e]PAb8bb26" > "$tty"  # bright green
        echo -en "\e]PBfabd2f" > "$tty"  # bright yellow
        echo -en "\e]PC83a598" > "$tty"  # bright blue
        echo -en "\e]PDd3869b" > "$tty"  # bright magenta
        echo -en "\e]PE8ec07c" > "$tty"  # bright cyan
        echo -en "\e]PFebdbb2" > "$tty"  # bright white
      done
    '';
  };

  system.stateVersion = "25.05";
}
