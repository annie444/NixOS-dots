{ self
, nixpkgs
, sops-nix
, inputs
, nixos-hardware
, nix
, ...
}:
let
  nixosSystem = nixpkgs.lib.makeOverridable nixpkgs.lib.nixosSystem;
  customModules = import ../modules/modules-list.nix;
  baseModules = [
    # make flake inputs accessiable in NixOS
    { _module.args.inputs = inputs; }
    {
      imports = [
        ({ pkgs, ... }: {
          nix.nixPath = [
            "nixpkgs=${pkgs.path}"
          ];
          # TODO: remove when switching to 22.05
          nix.package = nixpkgs.lib.mkForce nix.packages.x86_64-linux.nix;
          nix.extraOptions = ''
            experimental-features = nix-command flakes
          '';
          documentation.info.enable = true;
        })
        sops-nix.nixosModules.sops
      ];
    }
  ];
  defaultModules = baseModules ++ customModules;
in
{
  homelab01 = nixosSystem {
    system = "x86_64-linux";
    modules = defaultModules ++ [
      ./homelab01/configuration.nix
    ];
  };
  homelab02 = nixosSystem {
    system = "x86_64-linux";
    modules = defaultModules ++ [
      ./homelab02/configuration.nix
    ];
  };
}

