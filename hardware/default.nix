{ config, pkgs, ... }:

{
  imports = [
    ./audio.nix
    ./graphics.nix
    ./bluetooth.nix
  ];
}
