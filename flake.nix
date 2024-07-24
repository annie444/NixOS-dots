{
  description = "Homelab NixOS Flake";

  inputs = {
    # nix-index-database
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    # You can access packages and modules from different nixpkgs revs
    # at the same time. Here's an working example:
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # Also see the 'unstable-packages' overlay at 'overlays/default.nix'.

    # sops secret provisioning
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.inputs.nixpkgs-stable.follows = "";

    # Home manager
    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # disko
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    # nixos hardware
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    # flake registry
    flake-registry.url = "github:NixOS/flake-registry";
    flake-registry.flake = false;

    # Special linker for nix
    nix-ld-rs.url = "github:nix-community/nix-ld-rs";
    nix-ld-rs.inputs.nixpkgs.follows = "nixpkgs";
    nix-ld-rs.inputs.flake-utils.follows = "flake-utils";

    # Flake formatter
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";

    # Extra flake utilities
    flake-utils.url = "github:numtide/flake-utils";

    # NixOS wikis
    nixos-wiki.url = "github:Mic92/nixos-wiki-infra";
    nixos-wiki.inputs.nixpkgs.follows = "nixpkgs";
    nixos-wiki.inputs.treefmt-nix.follows = "treefmt-nix";
    nixos-wiki.inputs.disko.follows = "disko";
    nixos-wiki.inputs.sops-nix.follows = "sops-nix";

  };

  outputs = { 
    self,
    flake-utils,
    nixpkgs,
    sops-nix,
    deploy,
    , ...
  } @ inputs:
  (flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages."${system}";
    in
    {
      devShell = pkgs.callPackage ./shell.nix {
        inherit (sops-nix.packages."${pkgs.system}") sops-import-keys-hook ssh-to-pgp sops-init-gpg-key;
        inherit (deploy.packages."${pkgs.system}") deploy-rs;
      };
  })) // {
    nixosConfigurations = import ./nixos/configurations.nix (inputs // {
      inherit inputs;
    });
    deploy = import ./nixos/deploy.nix (inputs // {
      inherit inputs;
    });
    homeConfigurations = import ./home-manager/home.nix (inputs // {
      inherit inputs;
    });
    
    hydraJobs = nixpkgs.lib.mapAttrs' (name: config: nixpkgs.lib.nameValuePair "nixos-${name}" config.config.system.build.toplevel) self.nixosConfigurations;
    checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy.lib;
  };
}
