#!/bin/bash

# NixOS Modular Configuration Setup Script
# This script creates a modular structure for your NixOS configuration

set -e  # Exit on any error

# Define the base directory (run from /etc/nixos)
BASE_DIR="/etc/nixos"
BACKUP_DIR="$BASE_DIR/backup-$(date +%Y%m%d-%H%M%S)"

echo "Creating modular NixOS configuration structure..."
echo "Backing up existing files to $BACKUP_DIR"

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Backup existing files
if [ -f "$BASE_DIR/configuration.nix" ]; then
  cp "$BASE_DIR/configuration.nix" "$BACKUP_DIR/"
fi

if [ -f "$BASE_DIR/hardware-configuration.nix" ]; then
  cp "$BASE_DIR/hardware-configuration.nix" "$BACKUP_DIR/"
fi

# Create directory structure
mkdir -p "$BASE_DIR/system"
mkdir -p "$BASE_DIR/hardware"
mkdir -p "$BASE_DIR/users"
mkdir -p "$BASE_DIR/desktop"
mkdir -p "$BASE_DIR/packages"

# Create main configuration.nix
cat > "$BASE_DIR/configuration.nix" << 'EOF'
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
EOF

# Create system configuration files

# boot.nix
cat > "$BASE_DIR/system/boot.nix" << 'EOF'
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
EOF

# networking.nix
cat > "$BASE_DIR/system/networking.nix" << 'EOF'
{ config, pkgs, ... }:

{
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  
  networking.firewall = {
    allowedTCPPorts = [ 22 80 443 27036 27037 ];
    allowedUDPPorts = [ 27031 27036 3659 ];
  };

  services.openssh.enable = true;
}
EOF

# security.nix
cat > "$BASE_DIR/system/security.nix" << 'EOF'
{ config, pkgs, ... }:

{
  security.rtkit.enable = true;
  security.polkit.enable = true;
  
  security.pam.services = {
    login.enableKwallet = true;
    swaylock = {};
  };

  security.sudo = {
    wheelNeedsPassword = true;
    execWheelOnly = true;
  };
}
EOF

# Create hardware configuration files

# hardware/default.nix
cat > "$BASE_DIR/hardware/default.nix" << 'EOF'
{ config, pkgs, ... }:

{
  imports = [
    ./audio.nix
    ./graphics.nix
    ./bluetooth.nix
  ];
}
EOF

# hardware/graphics.nix
cat > "$BASE_DIR/hardware/graphics.nix" << 'EOF'
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
EOF

# hardware/audio.nix
cat > "$BASE_DIR/hardware/audio.nix" << 'EOF'
{ config, pkgs, ... }:

{
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };
}
EOF

# hardware/bluetooth.nix
cat > "$BASE_DIR/hardware/bluetooth.nix" << 'EOF'
{ config, pkgs, ... }:

{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  
  services.blueman.enable = true;
}
EOF

# Create users configuration
cat > "$BASE_DIR/users/default.nix" << 'EOF'
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
EOF

# Create desktop configuration files

# desktop/default.nix
cat > "$BASE_DIR/desktop/default.nix" << 'EOF'
{ config, pkgs, ... }:

{
  imports = [ ./plasma.nix ];
  
  xdg.mime.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      kdePackages.xdg-desktop-portal-kde
      xdg-desktop-portal-gtk
    ];
  };
  
  programs.dconf.enable = true;
  programs.firefox.enable = true;
  
  services.displayManager.autoLogin.enable = false;
}
EOF

# desktop/plasma.nix
cat > "$BASE_DIR/desktop/plasma.nix" << 'EOF'
{ config, pkgs, ... }:

{
  services.xserver.enable = true;
  
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  
  services.desktopManager.plasma6.enable = true;
  
  services.xserver.xkb = {
    layout = "dk";
    variant = "";
  };
}
EOF

# Create packages configuration

# packages/default.nix
cat > "$BASE_DIR/packages/default.nix" << 'EOF'
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
EOF

# packages/cli-tools.nix
cat > "$BASE_DIR/packages/cli-tools.nix" << 'EOF'
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
EOF

# packages/dev-tools.nix
cat > "$BASE_DIR/packages/dev-tools.nix" << 'EOF'
{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Infrastructure as Code
    ansible packer terraform
    
    # Containerization
    docker docker-compose podman
    
    # Programming Languages
    go nodejs perl python3 python3Packages.pip pipx rustup
    
    # Build Tools
    cmake gcc
  ];
}
EOF

# packages/gui-apps.nix
cat > "$BASE_DIR/packages/gui-apps.nix" << 'EOF'
{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Browsers & Communication
    chromium firefox signal-desktop telegram-desktop thunderbird
    
    # Multimedia
    audacity handbrake mpv spotify vlc
    
    # Graphics & Design
    gimp inkscape krita kdePackages.okular zathura
  ];
}
EOF

echo "Modular configuration structure created successfully!"
echo "Your original files have been backed up to: $BACKUP_DIR"
echo ""
echo "Next steps:"
echo "1. Review the generated files to ensure they match your requirements"
echo "2. Run: sudo nixos-rebuild dry-activate to test the configuration"
echo "3. Run: sudo nixos-rebuild switch to apply the new configuration"
echo ""
echo "Note: You may need to adjust the GPU type in hardware/graphics.nix if needed"
