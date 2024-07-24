{ self
, nixpkgs
, inputs
, outputs
, nixos-hardware
, nix
, ...
}:
let
  nixosSystem = nixpkgs.lib.makeOverridable nixpkgs.lib.nixosSystem;
  baseModules = [
    {
      imports = [
        ({ pkgs, ... }: {
          nix = {
            settings = {
              # Enable flakes and new 'nix' command
              experimental-features = "nix-command flakes";
              # Opinionated: disable global registry
              flake-registry = "";
              # Workaround for https://github.com/NixOS/nix/issues/9574
              nix-path = [
                config.nix.nixPath;
                "nixpkgs=${pkgs.path}"
              ];
            };
            # Opinionated: disable channels
            channel.enable = false;

            package = nixpkgs.lib.mkForce nix.packages.x86_64-linux.nix;

            extraOptions = ''
              experimental-features = nix-command flakes
            '';

            # Opinionated: make flake registry and nix path match flake inputs
            registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
            nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
          };
        })
        sops-nix.nixosModules.sops
        inputs.home-manager.nixosModules.home-manager
      ];
      home-manager = {
        extraSpecialArgs = { inherit inputs outputs; };
        users = import ../home-manager/users.nix;
      };
    }
  ];
in {
  homelab01 = nixosSystem {
    system = "x86_64-linux";
    modules = baseModules ++ [
      ./homelab01/configuration.nix
    ];
    specialArgs = { inherit inputs outputs; };
  };
}

