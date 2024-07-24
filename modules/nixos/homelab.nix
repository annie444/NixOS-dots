{ config, lib, pkgs, meta, ... }:

with lib;

{
  config = {
    # Fixes for longhorn
    systemd.tmpfiles.rules = [
      "L+ /usr/local/bin - - - - /run/current-system/sw/bin/"
    ];
    virtualisation.docker.logDriver = "json-file";

    services.k3s = {
      enable = true;
      role = "server";
      tokenFile = /var/lib/rancher/k3s/server/token;
      extraFlags = toString ([
	      "--write-kubeconfig-mode \"0644\""
	      "--cluster-init"
	      "--disable servicelb"
	      "--disable traefik"
	      "--disable local-storage"
      ] ++ (if meta.hostname == "homelab01" then [] else [
	        "--server https://homelab01:6443"
      ]));
      clusterInit = (meta.hostname == "homelab01");
    };

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
       k3s
       cifs-utils
       nfs-utils
    ];
  };

}
