{ config, pkgs, lib, ... }:

with lib;

{
  config = {
    profiles.tmux.enable = true;
    profiles.neovim.enable = true;
    profiles.fish.enable = true;

    time.timeZone = mkDefault "America/Los_Angeles";

    # clean tmp on boot
    boot.cleanTmpDir = mkDefault true;

    programs = {
      ssh.forwardX11 = false;
      ssh.startAgent = true;
      neovim.defaultEditor = true;
    };

    i18n.defaultLocale = "en_US.UTF-8";
    console = {
      font = "Lat2-Terminus16";
      keyMap = "us";
    };

    networking = {
      networkmanager.enable = true;
      firewall.enable = false;
    };

    # sane dnsmasq defaults
    services = {
      dnsmasq.extraConfig = ''
        strict-order
      '';

      # sane journald defaults
      journald.extraConfig = ''
        SystemMaxUse=256M
      '';
      locate.enable = true;
      openssh = {
        enable = true;
        passwordAuthentication = false;
        permitRootLogin = "without-password";
      };
    };

    boot.kernelModules = [ "tun" "fuse" ];
    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.extraUsers.root.shell = mkOverride 50 "${pkgs.bashInteractive}/bin/bash";

    environment.systemPackages = (with pkgs; [
      screen
      wget
      git
      vim
      openssh
      openssl
      fasd
      bind
    ]) ++ [ inputs.home-manager.packages.${pkgs.system}.default ];
  };
}
