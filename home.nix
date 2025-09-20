# home.nix
{ config, pkgs, lib, ... }:

{
  home.username = "togo-gt";
  home.homeDirectory = "/home/togo-gt";
  home.stateVersion = "25.05";
  home.extraOutputsToInstall = ["doc" "devdoc"];

  programs.home-manager.enable = true;

  # Git configuration
  programs.git = {
    enable = true;
    userName = "togo-gt";
    userEmail = "michael.kaare.nielsen@gmail.com";
  };

  home.packages = with pkgs; [
    # User-specific packages
    broot
    dust
    duf
    fselect
    ncdu
    zoxide
    bat
    bat-extras.batdiff
    bat-extras.batgrep
    bat-extras.batman
    bat-extras.batpipe
    micro
    ripgrep
    ripgrep-all
    bottom
    glances
    iotop
    nethogs
    powertop
    borgbackup
    rsnapshot
    rsync
    curlie
    fzf
    starship
    taskwarrior
    tldr
    tmuxp
    watch
    zsh-autosuggestions
    zsh-syntax-highlighting
    aircrack-ng
    cmatrix
    file
    fortune
    openssl
    iperf3
    nmap
    masscan
    tcpdump
    tcpflow
    traceroute
    ettercap
    openvpn
    wireguard-tools
    podman
    ansible
    # packer removed due to unfree license issues
    terraform
    docker-compose
    go
    nodejs
    perl
    python3
    python3Packages.pip
    pipx
    rustup
    cmake
    gcc
    chromium
    signal-desktop
    telegram-desktop
    thunderbird
    audacity
    handbrake
    mpv
    spotify
    vlc
    gimp
    inkscape
    krita
    kdePackages.okular
    zathura
    distrobox
    kdePackages.dolphin
    evince
    feh
    gparted
    kdePackages.konsole
    obs-studio
    paprefs
    protonup-qt
    transmission-gtk
    lutris
    wine
    gamemode
    mangohud
    libnotify
    libva-utils
  ];

  # Configure shell
  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "sudo" "systemd" "docker" "kubectl" ];
      theme = "agnoster";
    };
    initExtra = ''
      # Custom aliases or settings
      alias ll='ls -l'
      alias nix-update='sudo nixos-rebuild switch --flake .#'
    '';
  };
}
