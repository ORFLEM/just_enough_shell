{ config, pkgs, unstablePkgs, inputs, host, username, lib, ... }:
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

  # ============================================================
  # SYSTEM PACKAGES (minimal set)
  # ============================================================
  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    auto-optimise-store = true;
    experimental-features = [ "nix-command" "flakes" ];
  };

  environment.systemPackages =
    # STABLE
    (with pkgs; [
      # Core
      blueman
      foot
      micro
      helix
      git
      wget
      curl
      fastfetch
      ddcutil
      btop
      yazi
      (mpv.override { scripts = with pkgs.mpvScripts; [ mpris ]; })
      ffmpeg
      kbd
      udisks2
      udiskie
      ntfs3g
      exfat
      grim
      slurp
      wl-clipboard
      cliphist
      pavucontrol
      file-roller
      qalculate-qt
      quickshell
      hyprlock
      wayland
      mesa
      gsettings-desktop-schemas
      gnome-themes-extra
      rose-pine-cursor
      rose-pine-hyprcursor
      tela-icon-theme
      dbus
      glib
      gobject-introspection
      libnotify
      playerctl
      cava
      ffmpeg
      ldacbt
      pamixer
      playerctl
      tuigreet
      pamixer
      wireguard-tools
      unzip
      zip
      bat
      lsd
      jq
      chafa
      cmatrix
      pipes
      zellij
      kdePackages.kdenlive
      kdePackages.gwenview
      kdePackages.okular
      kdePackages.dolphin
      kdePackages.ffmpegthumbs
      tela-icon-theme
      rose-pine-cursor
      stylix
    ])
  
    # UNSTABLE
    ++ (with unstablePkgs; [
      wallust

      swayfx

      go

      bastet
      moon-buggy
      nsnake

      hyprpicker

      inputs.persway.packages.${pkgs.stdenv.hostPlatform.system}.default
    ])

    # NUR
    ++ (with pkgs.nur.repos; [
      # lonerOrz.linux-wallpaperengine
    ]);

  # ============================================================
  # DISPLAY MANAGER & GREETD
  # ============================================================
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd sway";
    };
  };
  systemd.services.greetd.serviceConfig.ExecStartPre = [ "${pkgs.kbd}/bin/setfont ter-v32n" ];

  # ============================================================
  # WINDOW MANAGER (SwayFX)
  # ============================================================
  programs.sway = {
    enable = true;
    package = pkgs.swayfx;
    wrapperFeatures.gtk = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr
    ];
  };

  # ============================================================
  # THEMING (stylix)
  # ============================================================
  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/zenburn.yaml";
    targets.qt.enable = true;
    targets.gtk.enable = true;
    targets.grub.enable = false;
    polarity = "dark";
  };

  # ============================================================
  # USER ACCOUNT
  # ============================================================
  users.users.user = {
    isNormalUser = true;
    description = "Example User";
    extraGroups = [ "networkmanager" "wheel" "input" "plugdev" "storage" "i2c" "usbmux" ];
    packages = with pkgs; [];
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs username host; };
    users.user = {
      home = {
        username = "user";
        homeDirectory = "/home/user";
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
  # FILESYSTEMS (examples, adjust to your hardware)
  # ============================================================
  # fileSystems."/mnt/data" = {
  #   device = "/dev/disk/by-uuid/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx";
  #   fsType = "ext4";
  # };

  services.udisks2.enable = true;

  # ============================================================
  # NETWORK
  # ============================================================
  networking.hostName = "nixos";
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
  time.timeZone = "Europe/London";   # change to your zone
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

  system.stateVersion = "25.11";
}
