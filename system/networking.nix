{ config, pkgs, ... }:

{
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  
  networking.firewall = {
    allowedTCPPorts = [ 22 80 443 27036 27037 ];
    allowedUDPPorts = [ 27031 27036 3659 ];
  };

  services.openssh.enable = true;
}
