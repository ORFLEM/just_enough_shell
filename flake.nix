{
  description = "NixOS flake для ORFLEMPC";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
  };
  
  outputs = { self, nixpkgs, nixpkgs-unstable, nur, chaotic, ... }: let
    system = "x86_64-linux";
  in {
    nixosConfigurations.ORFLEMPC = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ./configuration.nix
        chaotic.nixosModules.default  # Добавляем Chaotic
        ({ config, pkgs, ... }: {
          _module.args.unstablePkgs = import nixpkgs-unstable { 
            inherit system; 
            config.allowUnfree = true;
          };
          
          nixpkgs.overlays = [
            nur.overlays.default
          ];
          
          programs.hyprland = {
            package = config._module.args.unstablePkgs.hyprland;
            portalPackage = config._module.args.unstablePkgs.xdg-desktop-portal-hyprland;
          };
        })
      ];
    };
  };
}
