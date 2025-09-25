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
    cmatrix
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
    libsForQt5.qt5ct
    qt6Packages.qt6ct
    
  ];

  environment.sessionVariables = {
    GTK_THEME = "Kanagawa-B";
    ICON_THEME = "Papirus-Dark";
    QT_QPA_PLATFORMTHEME = "qt6ct";
    QT_STYLE_OVERRIDE = "qt6ct";
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
      font = "ter-v32n";
      packages = with pkgs; [
       terminus_font
       spleen
       unifont
       ];
      earlySetup = true;  # Загружает шрифт в initrd
    };
    
    # Оригинальные Kanagawa цвета на уровне ядра (применяются при загрузке)
    boot.kernelParams = [
      "fbcon=font:TER16x32"
      "vt.default_utf8=1"
      "consoleblank=0"
      
      # Оригинальные Kanagawa RGB цвета:
      # 0=black, 1=red, 2=green, 3=yellow, 4=blue, 5=magenta, 6=cyan, 7=white
      # 8=br_black, 9=br_red, 10=br_green, 11=br_yellow, 12=br_blue, 13=br_magenta, 14=br_cyan, 15=br_white
      "vt.default_red=22,195,118,192,126,149,106,200,114,232,152,230,127,147,122,220"
      "vt.default_grn=22,64,148,163,156,127,149,192,115,36,187,195,180,138,168,215"
      "vt.default_blu=29,67,106,110,216,184,137,147,105,36,108,132,202,169,159,186"
    ];
    
    # Systemd сервис для закрепления цветов после загрузки
    systemd.services.set-tty-colors = {
      description = "Apply Kanagawa TTY colors";
      wantedBy = [ "multi-user.target" ];
      after = [ "systemd-vconsole-setup.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        for tty in /dev/tty{1..6}; do
          # Оригинальные Kanagawa цвета
          echo -en "\e]P016161d" > "$tty"  # black
          echo -en "\e]P1c34043" > "$tty"  # red
          echo -en "\e]P276946a" > "$tty"  # green
          echo -en "\e]P3c0a36e" > "$tty"  # yellow
          echo -en "\e]P47e9cd8" > "$tty"  # blue
          echo -en "\e]P5957fb8" > "$tty"  # magenta
          echo -en "\e]P66a9589" > "$tty"  # cyan
          echo -en "\e]P7c8c093" > "$tty"  # white
          echo -en "\e]P8727169" > "$tty"  # bright black
          echo -en "\e]P9e82424" > "$tty"  # bright red
          echo -en "\e]PA98bb6c" > "$tty"  # bright green
          echo -en "\e]PBe6c384" > "$tty"  # bright yellow
          echo -en "\e]PC7fb4ca" > "$tty"  # bright blue
          echo -en "\e]PD938aa9" > "$tty"  # bright magenta
          echo -en "\e]PE7aa89f" > "$tty"  # bright cyan
          echo -en "\e]PFdcd7ba" > "$tty"  # bright white
        done
      '';
    };

  system.stateVersion = "25.05";
}
