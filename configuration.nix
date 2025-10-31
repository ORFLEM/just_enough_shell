{ config, pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  # ============================================================
  # NIX SETTINGS
  # ============================================================
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 20d";
  };

  nixpkgs.config.allowUnfree = true;

  # ============================================================
  # BOOT
  # ============================================================
  boot.loader = {
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      useOSProber = true;
    };
    efi.canTouchEfiVariables = true;
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # ============================================================
  # CONSOLE & TTY (Kanagawa theme)
  # ============================================================
  console = {
    font = "ter-v32n";
    packages = with pkgs; [
      terminus_font
      spleen
      unifont
    ];
    earlySetup = true;
  };
  
  boot.kernelParams = [
    "fbcon=font:ter-v32n"
    "vt.default_utf8=1"
    "consoleblank=0"
    
    # Kanagawa colors
    "vt.default_red=22,195,118,192,126,149,106,200,114,232,152,230,127,147,122,220"
    "vt.default_grn=22,64,148,163,156,127,149,192,115,36,187,195,180,138,168,215"
    "vt.default_blu=29,67,106,110,216,184,137,147,105,36,108,132,202,169,159,186"
  ];
  
  systemd.services.set-tty-colors = {
    description = "Apply Kanagawa TTY colors and font";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-vconsole-setup.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${pkgs.kbd}/bin/setfont ter-v32n
      
      for tty in /dev/tty{1..6}; do
        ${pkgs.kbd}/bin/setfont -C "$tty" ter-v32n
        echo -en "\e]P016161d" > "$tty"
        echo -en "\e]P1c34043" > "$tty"
        echo -en "\e]P276946a" > "$tty"
        echo -en "\e]P3c0a36e" > "$tty"
        echo -en "\e]P47e9cd8" > "$tty"
        echo -en "\e]P5957fb8" > "$tty"
        echo -en "\e]P66a9589" > "$tty"
        echo -en "\e]P7c8c093" > "$tty"
        echo -en "\e]P8727169" > "$tty"
        echo -en "\e]P9e82424" > "$tty"
        echo -en "\e]PA98bb6c" > "$tty"
        echo -en "\e]PBe6c384" > "$tty"
        echo -en "\e]PC7fb4ca" > "$tty"
        echo -en "\e]PD938aa9" > "$tty"
        echo -en "\e]PE7aa89f" > "$tty"
        echo -en "\e]PFdcd7ba" > "$tty"
      done
    '';
  };

  # ============================================================
  # NETWORK & LOCALIZATION
  # ============================================================
  networking.hostName = "NixOS_PC";
  networking.networkmanager.enable = true;
  time.timeZone = "Europe/Amsterdam";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # ============================================================
  # DISPLAY & DESKTOP
  # ============================================================
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd Hyprland";
        user = "greeter";
      };
    };
  };
  
  systemd.services.greetd.serviceConfig.ExecStartPre = [
    "${pkgs.kbd}/bin/setfont ter-v32n"
  ];
  
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
  };

  # ============================================================
  # AUDIO & BLUETOOTH
  # ============================================================
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

  # ============================================================
  # GRAPHICS
  # ============================================================
  hardware.graphics.enable = true;

  # ============================================================
  # USER CONFIGURATION
  # ============================================================
  # Раскомментируй и настрой под себя:
  # users.users.<username> = {
  #   isNormalUser = true;
  #   description = "<Your Name>";
  #   extraGroups = [ "networkmanager" "wheel" ];
  #   packages = with pkgs; [];
  # };

  # ============================================================
  # SYSTEM SERVICES
  # ============================================================
  services.dbus.enable = true;
  services.tumbler.enable = true;
  services.flatpak.enable = true;
  services.gvfs.enable = true;

  programs.dconf.enable = true;
  services.dbus.packages = with pkgs; [ dconf libnotify glib gtk3 ];

  services.gnome.gnome-keyring.enable = true;
  programs.seahorse.enable = true;

  # ============================================================
  # FONTS
  # ============================================================
  fonts.packages = with pkgs; [
    iosevka-bin
    noto-fonts-cjk-sans
    nerd-fonts._3270
    nerd-fonts.mononoki
  ];
  fonts.fontconfig.enable = true;

  # ============================================================
  # PACKAGES
  # ============================================================
  environment.systemPackages = with pkgs; [
    # === Hyprland Stack ===
    hyprland
    hyprlock
    hyprpaper
    eww
    rofi
    greetd.tuigreet
    
    # === GUI Applications ===
    blueman
    file-roller
    gnome-calculator
    kitty
    mpv
    mpvpaper
    pavucontrol
    pdfarranger
    shotwell
    vscodium

    # === CLI Tools ===
    btop
    browsh
    cava
    cliphist
    coreutils-full
    cmatrix
    dbus
    ddcutil
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
    wget
    wireguard-tools
    wl-clipboard
    yazi
    zip

    # === AMD Graphics Stack ===
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
    wayland

    # === File Manager (Thunar) ===
    ffmpegthumbnailer
    libgsf
    poppler
    xfce.thunar
    xfce.thunar-archive-plugin
    xfce.tumbler

    # === Themes ===
    gnome-themes-extra
    gtk3
    (papirus-icon-theme.override { color = "yaru"; })
    gruvbox-gtk-theme
    kanagawa-gtk-theme
    rose-pine-cursor
    rose-pine-hyprcursor
    libsForQt5.qt5ct
    qt6Packages.qt6ct
  ];

  # ============================================================
  # ENVIRONMENT
  # ============================================================
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
  ];

  # ============================================================
  # GAMING
  # ============================================================
  programs.steam = {
    enable = true;
    package = pkgs.steam.override {
      extraPkgs = pkgs: with pkgs; [ libdrm wayland ];
    };
  };

  system.stateVersion = "25.05";
}
