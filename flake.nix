{
  description = "NixOS flake для ORFLEMPC";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";  # ← Добавляем NUR
  };
  
  outputs = { self, nixpkgs, nixpkgs-unstable, nur }: let
    system = "x86_64-linux";
  in {
    nixosConfigurations.ORFLEMPC = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ./configuration.nix
        ({ config, pkgs, lib, ... }: {
          _module.args.unstablePkgs = import nixpkgs-unstable { 
            inherit system; 
            config.allowUnfree = true;
          };
          
          # Подключаем NUR
          nixpkgs.overlays = [
            nur.overlays.default
          ];
          
          programs.hyprland = {
            package = config._module.args.unstablePkgs.hyprland;
            portalPackage = config._module.args.unstablePkgs.xdg-desktop-portal-hyprland;
          };
          
          environment.systemPackages = (with config._module.args.unstablePkgs; [
            telegram-desktop
            hyprland
            hyprlandPlugins.hy3
            hyprlandPlugins.hyprspace
            hyprlandPlugins.hypr-dynamic-cursors
          ]) ++ (with pkgs.nur.repos; [
            # Примеры пакетов из NUR:
            # rycee.firefox-addons.ublock-origin
            # или любой другой репо из NUR
          ]);
        })
      ];
    };
  };
}
