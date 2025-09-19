{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # File Management
    broot dust duf fselect ncdu zoxide
    
    # Text Processing
    bat micro neovim ripgrep ripgrep-all
    
    # System Monitoring
    btop bottom htop glances iotop nethogs
    
    # Networking
    iperf3 nmap masscan tcpdump tcpflow traceroute
    
    # Utilities
    gitFull curl curlie fzf starship taskwarrior3
    tldr tmux tmuxp watch zsh zsh-autosuggestions
    zsh-syntax-highlighting
    
    # Security
    aircrack-ng ettercap openvpn wireguard-tools
  ];
}
