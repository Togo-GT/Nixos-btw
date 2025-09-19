{ config, pkgs, lib, ... }:

let
  kernelAvailable = lib.hasAttr "linuxPackages_6_17" pkgs;
in
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  boot.kernelPackages = if kernelAvailable 
    then pkgs.linuxPackages_6_17 
    else pkgs.linuxPackages_latest;
  
  boot.kernelParams = [
    "quiet"
    "splash" 
    "nowatchdog"
    "tsc=reliable"
    "nohibernate"
  ];

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "ahci"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];

  boot.kernelModules = [
    "fuse"
    "v4l2loopback"
    "snd-aloop"
  ];
}
