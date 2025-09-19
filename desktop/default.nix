{ config, pkgs, ... }:

{
  imports = [ ./plasma.nix ];
  
  xdg.mime.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      kdePackages.xdg-desktop-portal-kde
      xdg-desktop-portal-gtk
    ];
  };
  
  programs.dconf.enable = true;
  programs.firefox.enable = true;
  
  services.displayManager.autoLogin.enable = false;
}
