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

  # User packages
  home.packages = with pkgs; [
    # File utilities
    broot
    dust
    duf
    fselect
    ncdu
    zoxide

    # Text processing and viewing
    bat
    bat-extras.batdiff
    bat-extras.batgrep
    bat-extras.batman
    bat-extras.batpipe
    micro
    ripgrep
    ripgrep-all

    # System monitoring
    bottom
    glances
    iotop
    nethogs
    powertop

    # Backup and sync
    borgbackup
    rsnapshot
    rsync

    # Network utilities
    curlie
    fzf

    # Shell enhancements
    starship
    zsh-autosuggestions
    zsh-syntax-highlighting

    # Task management
    taskwarrior
    tldr
    tmuxp
    watch

    # Security and networking tools
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

    # Development and containers
    podman
    ansible
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

    # Web browsers
    chromium

    # Communication
    signal-desktop
    telegram-desktop
    thunderbird

    # Multimedia
    audacity
    handbrake
    mpv
    spotify
    vlc

    # Graphics
    gimp
    inkscape
    krita
    kdePackages.okular
    zathura

    # Utilities
    distrobox
    kdePackages.dolphin
    evince
    feh
    gparted
    kdePackages.konsole
    obs-studio
    paprefs
    protonup-qt
    transmission_4-gtk

    # Gaming
    lutris
    wine
    gamemode
    mangohud

    # System utilities
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
