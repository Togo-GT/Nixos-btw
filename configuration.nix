{ config, pkgs, lib, ... }:

let
  gpuType = "amd";
  kernelAvailable = lib.hasAttr "linuxPackages_6_17" pkgs;
in
{
  imports = [
    ./hardware-configuration.nix
    ./system/boot.nix
    ./system/networking.nix
    ./system/security.nix
    ./hardware/default.nix
    ./users/default.nix
    ./desktop/default.nix
    ./packages/default.nix
  ];

  # System-wide settings
  time.timeZone = "Europe/Copenhagen";
  i18n.defaultLocale = "en_DK.UTF-8";
  console.keyMap = "dk-latin1";

  # Nix settings
  nixpkgs.config.allowUnfree = true;
  nix.settings.auto-optimise-store = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  system.stateVersion = "25.05";
}
