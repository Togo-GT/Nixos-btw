{ config, pkgs, ... }:

{
  security.rtkit.enable = true;
  security.polkit.enable = true;
  
  security.pam.services = {
    login.enableKwallet = true;
    swaylock = {};
  };

  security.sudo = {
    wheelNeedsPassword = true;
    execWheelOnly = true;
  };
}
