{ config, pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
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
    options = "--delete-older-than 10d";
  };

  boot.kernelPackages = pkgs.linuxPackages_lqx;
  boot.kernelModules = [ "i2c-dev" "i2c-piix4" ];
  
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
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd sway";
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

  programs.sway = {
      enable = true;
      package = unstablePkgs.swayfx;
      wrapperFeatures.gtk = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
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

  # AMD ROCm
  environment.variables = {
    HSA_OVERRIDE_GFX_VERSION = "11.0.0";
  };

  # ============================================================
  # HARDWARE - I2C & RGB
  # ============================================================
  hardware.i2c.enable = true;
  
  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
  };
  
  # ============================================================
  # USER
  # ============================================================
  # Раскомментируй и настрой под себя:
  # users.users.<username> = {
  #   isNormalUser = true;
  #   description = "<Your Name>";
  #   extraGroups = [ "networkmanager" "wheel" "input" "plugdev" "storage" "i2c" ];
  #   packages = with pkgs; [];
  # };

  # ============================================================
  # FILESYSTEMS
  # ============================================================

  # Automount все диски
  services.udisks2.enable = true;
  services.udisks2.settings = {
    "udisks2.conf" = {
      udisks2 = {
        modules = ["*"];
        modules_load_preference = "ondemand";
      };
      defaults = {
        encryption = "luks2";
      };
    };
  };

  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id == "org.freedesktop.udisks2.filesystem-mount" ||
          action.id == "org.freedesktop.udisks2.filesystem-mount-system" ||
          action.id == "org.freedesktop.udisks2.erase-device" ||
          action.id == "org.freedesktop.udisks2.modify-device" ||
          action.id == "org.freedesktop.udisks2.filesystem-unmount" ||
          action.id == "org.freedesktop.udisks2.filesystem-unmount-others") {
        return polkit.Result.YES;
      }
    });
    
    // Права для Flatpak management (Boxflat)
    polkit.addRule(function(action, subject) {
      if (action.id == "org.freedesktop.Flatpak.app-install" ||
          action.id == "org.freedesktop.Flatpak.runtime-install" ||
          action.id == "org.freedesktop.Flatpak.app-uninstall" ||
          action.id == "org.freedesktop.Flatpak.runtime-uninstall" ||
          action.id == "org.freedesktop.Flatpak.modify-repo") {
        if (subject.isInGroup("wheel")) {
          return polkit.Result.YES;
        }
      }
    });
  '';

  systemd.user.services.udiskie = {
    description = "Automount all drives";
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.udiskie}/bin/udiskie --all -a -n -t -f btrfs -f ext4 -f ext3 -f ext2 -f ntfs -f vfat -f exfat -f xfs -f f2fs";
      Restart = "on-failure";
    };
  };


  # ============================================================
  # SYSTEM SERVICES
  # ============================================================
  services.dbus.enable = true;
  services.tumbler.enable = true;
  services.flatpak.enable = true;
  services.gvfs.enable = true;
  
  # Flatpak permissions для Boxflat
  xdg.portal.config.common.default = "*";

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
    nerd-fonts.mononoki
  ];
  fonts.fontconfig.enable = true;

  # ============================================================
  # PACKAGES
  # ============================================================
  nixpkgs.config.allowUnfree = true;
  
  environment.systemPackages = 
      # STABLE пакеты
      (with pkgs; [
        # === GUI Applications ===
        blueman
        gnome-calculator
        greetd.tuigreet
        hyprlock
        kitty
        libreoffice-qt6-fresh
        mpv
        mpvpaper
        pavucontrol
        rofi
        rose-pine-hyprcursor
        shotwell
        steam
        swww
        firefox
        xarchiver
        vscodium
  
        # === CLI Tools ===
        btop
        browsh
        blesh
        cava
        cliphist
        clinfo
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
        mdr
        micro
        neovim
        nnn
        pamixer
        p7zip
        playerctl
        (python312.withPackages (ps: with ps; [
          dbus-python
          pygobject3
          jedi-language-server
        ]))
        pywal
        ranger
        slurp
        unzip
        wget
        wireguard-tools
        wl-clipboard
        w3m
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
  
        # ROCm
        rocmPackages.rocminfo
        rocmPackages.rocm-smi
        rocmPackages.rocm-runtime
        rocmPackages.hipcc
        rocmPackages.hipblas
        rocmPackages.rocm-device-libs
  
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
        kdePackages.qtstyleplugin-kvantum
  
        # === Unity3D ===
        unityhub
        libsecret
        seahorse
  
        # === Disk Utils ===
        kbd
        udisks2
        udiskie
        ntfs3g
        exfat
  
        # === Wayland Compositor ===
        eww
      ]) 
      
      # UNSTABLE пакеты
      ++ (with unstablePkgs; [
        # linux-wallpaperengine
        bastet
        moon-buggy
        nsnake
        hyprlandPlugins.hy3
        hyprlandPlugins.hyprspace
        hyprlandPlugins.hypr-dynamic-cursors
        hyprpicker

        #wm пакеты
        swayfx
        hyprland
      ])
  
  	# NUR пакеты
      ++ (with pkgs.nur.repos; [
      ]);

   # Hyprland plugins config
     environment.etc."hypr/plugins.conf".text = ''
       plugin = ${unstablePkgs.hyprlandPlugins.hy3}/lib/libhy3.so
       plugin = ${unstablePkgs.hyprlandPlugins.hyprspace}/lib/libhyprspace.so
       plugin = ${unstablePkgs.hyprlandPlugins.hypr-dynamic-cursors}/lib/libhypr-dynamic-cursors.so
     '';

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
  # HARDWARE QUIRKS
  # ============================================================
  services.udev.extraRules = ''
    # Moza Racing devices
    SUBSYSTEM=="usb", ATTRS{idVendor}=="346e", MODE="0666", GROUP="plugdev"
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="346e", MODE="0666", GROUP="plugdev"
    KERNEL=="hidraw*", ATTRS{idVendor}=="346e", MODE="0666", GROUP="plugdev"
    
    # i2c devices для ddcutil
    KERNEL=="i2c-[0-9]*", GROUP="i2c", MODE="0660"
    
    # OpenRGB - hidraw для клавиатур и периферии
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0666", TAG+="uaccess"
    
    # OpenRGB - USB устройства
    SUBSYSTEM=="usb", MODE="0666", TAG+="uaccess"
  '';

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
