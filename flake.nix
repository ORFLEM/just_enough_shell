{
  description = "NixOS flake для ORFLEMPC";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    nur.url = "github:nix-community/NUR";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix.url = "github:nix-community/stylix/release-25.11";

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    persway.url = "github:saylesss88/persway";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, nur, chaotic, home-manager, stylix, zen-browser, ... }@inputs:
  let
    system = "x86_64-linux";
    host = "nixos";
    username = "user";

    specialArgs = { inherit inputs system host username; };

    unstablePkgs = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
      overlays = [
        (final: prev: {
          zen-browser = zen-browser.packages.${system}.default;
        })
      ];
    };

  in {
    nixosConfigurations.${host} = nixpkgs.lib.nixosSystem {
      inherit system specialArgs;

      modules = [
        ./configuration.nix

        { _module.args = { inherit unstablePkgs; }; }

        # NUR overlay
        { nixpkgs.overlays = [ nur.overlays.default ]; }

        # Сторонние модули
        chaotic.nixosModules.default
        stylix.nixosModules.stylix
        home-manager.nixosModules.home-manager

        # Hyprland из unstable
        {
          programs.hyprland = {
            package = unstablePkgs.hyprland;
            portalPackage = unstablePkgs.xdg-desktop-portal-hyprland;
          };
        }
      ];
    };
  };
}
