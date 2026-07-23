{
  description = "NixOS flake для ORFLEMPC";

  inputs = {
    # --- Nixpkgs ---
    # В офлайн режиме: url переключается на path:/mnt/nixpkgs
    # Сейчас онлайн — тянем с github, flake.lock фиксирует ревизию
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    nur.url = "github:nix-community/NUR";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix.url = "github:nix-community/stylix/release-26.05";

    driftwm.url = "github:malbiruk/driftwm";

    persway.url = "github:saylesss88/persway";
    jes.url = "github:ORFLEM/just_enough_shell";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, nur, home-manager, stylix, driftwm, jes, ... }@inputs:
  let
    system = "x86_64-linux";
    userConfig = builtins.fromTOML (builtins.readFile ./user-config.toml);

    specialArgs = { inherit inputs system userConfig; };

    unstablePkgs = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
      overlays = [
        (final: prev: {
        })
      ];
    };

  in {
    nixosConfigurations.${userConfig.hostname} = nixpkgs.lib.nixosSystem {
      inherit system specialArgs;

      modules = [
        ./configuration.nix

        { _module.args = { inherit unstablePkgs; }; }

        # NUR overlay
        { nixpkgs.overlays = [ nur.overlays.default ]; }

        # Сторонние модули
        stylix.nixosModules.stylix
        home-manager.nixosModules.home-manager
        driftwm.nixosModules.default
        jes.nixosModules.default

        # Hyprland из unstable
        {
          programs.hyprland = {
            package = unstablePkgs.hyprland;
            portalPackage = unstablePkgs.xdg-desktop-portal-hyprland;
          };
        }

        # Substituters живут в nix-cache-hdd.nix — здесь не дублируем
      ];
    };
  };
}
