{ config, pkgs, lib, ... }:

with lib;

{
  config = {
    profiles.tmux.enable = true;
    profiles.neovim.enable = true;
    time.timeZone = mkDefault "America/Los_Angeles";

    # clean tmp on boot
    boot.cleanTmpDir = mkDefault true;

    programs = {
      fish.enableCompletion = mkDefault true;
      ssh.forwardX11 = false;
      ssh.startAgent = true;
      neovim.defaultEditor = true;
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

    environment.systemPackages = with pkgs; [
      screen
      wget
      git
      vim
      openssh
      openssl
      fasd
      bind
    ];
  };
}
