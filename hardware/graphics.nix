{ config, pkgs, lib, ... }:

let
  gpuType = "amd";
in
{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      vaapiVdpau
      libvdpau-va-gl
      mesa
    ] ++ lib.optional (gpuType == "amd") pkgs.amdvlk;
    
    extraPackages32 = with pkgs.pkgsi686Linux; [
      libva
      mesa
    ] ++ lib.optional (gpuType == "amd") pkgs.driversi686Linux.amdvlk;
  };
}
