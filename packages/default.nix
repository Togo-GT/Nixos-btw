{ config, pkgs, ... }:

{
  imports = [
    ./cli-tools.nix
    ./dev-tools.nix
    ./gui-apps.nix
  ];
  
  environment.systemPackages = with pkgs; [
    # Global packages that don't fit categories
  ];
}
