{ config, pkgs, unstablePkgs, inputs, userConfig, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  # ============================================================
  # BASIC ENVIRONMENT
  # ============================================================
  environment.sessionVariables = {
    GI_TYPELIB_PATH = "/run/current-system/sw/lib/girepository-1.0";
    ICON_THEME = "Tela-nord";
    QS_ICON_THEME = "Tela-nord";
    GDK_BACKEND = "wayland";
    NIXOS_OZONE_WL = "1";
    GTK_BACKEND = "wayland";
    TERMINAL = "foot";
  };

  # boxflat fix
  services.udev.packages = [
    (pkgs.writeTextFile {
      name = "moza-boxflat-udev-rules";
      text = ''
        # Moza Racing
        SUBSYSTEM=="usb", ATTRS{idVendor}=="346e", MODE="0666", GROUP="plugdev"
        SUBSYSTEM=="hidraw", ATTRS{idVendor}=="346e", MODE="0666", GROUP="plugdev"
        KERNEL=="hidraw*", ATTRS{idVendor}=="346e", MODE="0666", GROUP="plugdev"
        KERNEL=="ttyACM*", ATTRS{idVendor}=="346e", MODE="0666", GROUP="plugdev"
      '';
      destination = "/lib/udev/rules.d/99-boxflat.rules";
    })
  ];

  environment.etc."xdg/menus/applications.menu".source = 
    "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";

  # ============================================================
  # SYSTEM PACKAGES (minimal set)
  # ============================================================
  nixpkgs.config = {
    allowUnfree = true;
    # Включаем поддержку ROCm только для AMD, CUDA для NVIDIA
    rocmSupport = (userConfig.gpu == "amd");
    cudaSupport = (userConfig.gpu == "nvidia");
  };

  nix.settings = {
    auto-optimise-store = true;
    max-jobs = "auto";
  };

  environment.systemPackages =
    # STABLE
    (with pkgs; [
      # GUI
      krita
      obs-studio
      (mpv.override { scripts = with pkgs.mpvScripts; [ mpris ]; })

      # KDE utils
      kdePackages.kdenlive
      kdePackages.gwenview
      kdePackages.okular
      kdePackages.dolphin
      kdePackages.ffmpegthumbs
      kdePackages.kdeconnect-kde
      kdePackages.kwallet
      kdePackages.kwallet-pam
      kdePackages.kwalletmanager
      kdePackages.ksshaskpass

      # office
      libreoffice-qt6-fresh

      # Games & Moza racing
      prismlauncher
      protonplus
      steam
      boxflat

      # System utils
      authenticator
      adwsteamgtk
      blueman
      bottles
      corectrl
      file-roller
      qalculate-qt
      quickshell
      tuigreet
      nmgui
      hyprlock
      pavucontrol
      pcmanfm-qt
      nh
      krusader
      firefox

      # CLI
      helix
      micro

      # Multimedia
      cava
      ffmpeg
      ldacbt
      mpd-mpris
      pamixer
      playerctl
      rmpc

      # System libs
      dbus
      glib
      glibc
      gobject-introspection
      libnotify
      wtype
      inotify-tools
      xwayland-satellite

      # Qt6 libs
      qt6.qtbase
      qt6.qtdeclarative
      qt6.qtmultimedia
      qt6.qtshadertools
      qt6.qtwayland

      # Python
      (python313.withPackages (ps: with ps; [ tkinter-gl ]))

      # files & archives
      coreutils-full
      dust
      p7zip
      poppler
      unzip
      wget
      zip

      # Wayland — screenshots / clipboard
      cliphist
      grim
      slurp
      wl-clipboard

      # Daily utils
      appimage-run
      bat
      btop-rocm
      browsh
      chafa
      clinfo
      cmatrix
      ddcutil
      fastfetch
      jq
      lsd
      mdcat
      mdr
      pipes
      w3m
      yazi
      zellij

      taplo

      # Disks & file systems
      kbd
      udisks2
      udiskie
      ntfs3g
      exfat

      # Themes & icons
      gsettings-desktop-schemas
      gnome-themes-extra
      rose-pine-cursor
      rose-pine-hyprcursor
      tela-icon-theme

      inputs.driftwm.packages.${pkgs.stdenv.hostPlatform.system}.default

    ])
    # UNSTABLE
    ++ (with unstablePkgs; [
      matugen
      go
      bastet
      moon-buggy
      nsnake
      zen-browser
      hyprpicker
      inputs.persway.packages.${pkgs.stdenv.hostPlatform.system}.default
    ])

    # NUR (пусто)
    ++ (with pkgs.nur.repos; [
      # lonerOrz.linux-wallpaperengine
    ])
    # Добавляем пакеты в зависимости от GPU
    # Добавляем пакеты в зависимости от GPU
    ++ (lib.optionals (lib.attrByPath [ "rocm" ] false userConfig) (with pkgs; [
      rocmPackages.rocminfo
      rocmPackages.rocm-smi
    ]))
    ++ (lib.optionals (userConfig.gpu == "nvidia") (with pkgs; [
      nvtopPackages.full
      vulkan-tools
    ]))
    ++ (lib.optionals (userConfig.gpu == "intel") (with pkgs; [
      intel-gpu-tools
    ]));
     
  # ============================================================
  # DISPLAY MANAGER & GREETD
  # ============================================================
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd ${userConfig.preferred_wm}";
    };
  };
  systemd.services.greetd.serviceConfig.ExecStartPre = [ "${pkgs.kbd}/bin/setfont ter-v32n" ];

  # ============================================================
  # WINDOW MANAGERS
  # ============================================================
  programs.sway = {
    enable = true;
    package = unstablePkgs.swayfx;
    wrapperFeatures.gtk = true;
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    package = lib.mkForce unstablePkgs.hyprland;
  };

  programs.niri = {
    enable = true;
    package = unstablePkgs.niri;
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr
    ];
  };

  services.displayManager.sessionPackages = [
    inputs.driftwm.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  # ============================================================
  # THEMING (stylix)
  # ============================================================
  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/${userConfig.theme}.yaml";
    targets.qt.enable = true;
    targets.gtk.enable = true;
    targets.grub.enable = false;
    polarity = "dark";
  };

  # ============================================================
  # HARDWARE – GPU (условные блоки)
  # ============================================================
  # Общие настройки графики
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Важно для Steam и 32-битных игр
    
    extraPackages = with pkgs; [
      # Для Intel: VA-API драйвер (современный qsv для процессоров 8-го поколения и новее)
      (lib.mkIf (userConfig.gpu == "intel") intel-media-driver)
      
      # Для AMD: встроен в Mesa, но можно добавить для старых приложений vdpau
      (lib.mkIf (userConfig.gpu == "amd") vaapiVdpau)
      
      # Для Nvidia: интеграция VA-API с проприетарным драйвером
      (lib.mkIf (userConfig.gpu == "nvidia") nvidia-vaapi-driver)
    ];
  };

  # AMD
  hardware.amdgpu = lib.mkIf (userConfig.gpu == "amd") {
    initrd.enable = true; # Корректная опция вместо закомментированного enable
    overdrive.enable = true; 
  };

  # NVIDIA
  # Использован lib.mkMerge, чтобы не ломать структуру Nix при ложном условии
  hardware.nvidia = lib.mkIf (userConfig.gpu == "nvidia") {
    modesetting.enable = true;
    powerManagement.enable = true;
    nvidiaSettings = true; 
    open = false; # Обязательный параметр в новых версиях NixOS (true для open-source, false для закрытого драйвера)
  };

  # Переменные окружения для GPU
  environment.variables = lib.mkMerge [
    (lib.mkIf (userConfig.gpu == "amd") {
      HSA_OVERRIDE_GFX_VERSION = userConfig.rocm_version or "11.0.0";
    })
    (lib.mkIf (userConfig.gpu == "nvidia") {
      # Переменные для корректной работы Nvidia + Wayland
      LIBVA_DRIVER_NAME = "nvidia";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    })
  ];

  # ============================================================
  # USER ACCOUNT – динамический
  # ============================================================
  users.users.${userConfig.username} = {
    isNormalUser = true;
    description = userConfig.description;
    extraGroups = [ "networkmanager" "wheel" "input" "plugdev" "storage" "i2c" "usbmux" ];
    packages = with pkgs; [];
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs userConfig; };
    users.${userConfig.username} = {
      home = {
        username = userConfig.username;
        homeDirectory = "/home/${userConfig.username}";
        inherit (config.system) stateVersion;
      };

      stylix.targets.kde.enable = true;
      stylix.targets.foot.enable = true;
      programs.foot = {
        enable = true;
        settings = {
          main = {
            shell = "bash";
            term = "foot";
            font = lib.mkForce "Mononoki Nerd Font Propo:size=13";
            pad = "5x5";
          };
          cursor.style = "block";
          key-bindings = {
            clipboard-copy = "Control+Shift+c";
            clipboard-paste = "Control+Shift+v";
          };
        };
      };
    };
    backupFileExtension = "backup";
  };

  # ============================================================
  # AUDIO & BLUETOOTH
  # ============================================================
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # ============================================================
  # FONTS
  # ============================================================
  fonts.packages = with pkgs; [
    source-han-sans
    nerd-fonts.mononoki
    liberation_ttf
  ];

  # ============================================================
  # FILESYSTEMS (пример)
  # ============================================================
  # fileSystems."/mnt/data" = {
  #   device = "/dev/disk/by-uuid/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx";
  #   fsType = "ext4";
  # };

  services.udisks2.enable = true;

  # ============================================================
  # NETWORK
  # ============================================================
  networking.hostName = userConfig.hostname;
  networking.networkmanager.enable = true;
  hardware.enableRedistributableFirmware = true;

  # Optional: enable IP forwarding
  # boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  # ============================================================
  # BOOTLOADER
  # ============================================================
  boot.loader = {
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      useOSProber = false;   # set to true if dual-booting
    };
    efi.canTouchEfiVariables = true;
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelModules = [ "tun" "wireguard" ];

  # ============================================================
  # CONSOLE & KEYBOARD
  # ============================================================
  console = {
    font = "ter-v32n";
    packages = with pkgs; [ terminus_font kbd ];
    useXkbConfig = true;
  };
  services.xserver.xkb = {
    layout = "us,ru";
    options = "grp:caps_toggle,caps:shiftlock";
  };

  # ============================================================
  # LOCALISATION
  # ============================================================
  time.timeZone = userConfig.timezone;
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
  # NIX CONFIGURATION
  # ============================================================
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 10d";
  };

  system.stateVersion = "26.05";
}
