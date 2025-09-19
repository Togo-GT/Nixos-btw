# home.nix
{ config, pkgs, ... }:

{
  home.username = "togo-gt";
  home.homeDirectory = "/home/togo-gt";
  home.stateVersion = "23.11";

  programs.home-manager.enable = true;

  # Add your home-manager specific configurations here
  programs.git = {
    enable = true;
    userName = "togo-gt";
    userEmail = "michael.kaare.nielsen@gmail.com";
  };

  home.packages = with pkgs; [
    # User-specific packages
  ];

  # Example: Configure shell
  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "sudo" "systemd" "docker" "kubectl" ];
      theme = "agnoster";
    };
  };
}
