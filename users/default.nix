{ config, pkgs, ... }:

{
  users.users.togo-gt = {
    isNormalUser = true;
    description = "Togo-GT";
    extraGroups = [ "networkmanager" "wheel" "input" "docker" "libvirtd" ];
    shell = pkgs.zsh;
  };

  programs.zsh = {
    enable = true;
    ohMyZsh = {
      enable = true;
      plugins = [ "git" "sudo" "systemd" "docker" "kubectl" ];
      theme = "agnoster";
    };
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
  };
}
