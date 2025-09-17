Excellent! Let's break this configuration down into a modular structure. This will make it much easier to manage, understand, and update.

I'll provide a step-by-step guide to reorganizing your configuration.

Step 1: Create the Directory Structure

Create these files in your /etc/nixos/ directory:

```
/etc/nixos/
├── configuration.nix          # Main file that imports everything
├── hardware-configuration.nix # (Already exists)
├── system/
│   ├── boot.nix
│   ├── networking.nix
│   └── security.nix
├── hardware/
│   ├── default.nix
│   ├── audio.nix
│   ├── graphics.nix
│   └── bluetooth.nix
├── users/
│   └── default.nix
├── desktop/
│   ├── default.nix
│   └── plasma.nix
└── packages/
    ├── default.nix
    ├── cli-tools.nix
    ├── dev-tools.nix
    └── gui-apps.nix
```

Step 2: Main Configuration File (configuration.nix)

/etc/nixos/configuration.nix:

```nix
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
```

Step 3: System Configuration Files

/etc/nixos/system/boot.nix:

```nix
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
```

/etc/nixos/system/networking.nix:

```nix
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
```

/etc/nixos/system/security.nix:

```nix
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
```

Step 4: Hardware Configuration Files

/etc/nixos/hardware/default.nix:

```nix
{ config, pkgs, ... }:

{
  imports = [
    ./audio.nix
    ./graphics.nix
    ./bluetooth.nix
  ];
}
```

/etc/nixos/hardware/graphics.nix:

```nix
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
```

/etc/nixos/hardware/audio.nix:

```nix
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
```

/etc/nixos/hardware/bluetooth.nix:

```nix
{ config, pkgs, ... }:

{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  
  services.blueman.enable = true;
}
```

Step 5: User Configuration

/etc/nixos/users/default.nix:

```nix
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
```

Step 6: Desktop Environment

/etc/nixos/desktop/default.nix:

```nix
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
```

/etc/nixos/desktop/plasma.nix:

```nix
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
```

Step 7: Package Management

/etc/nixos/packages/default.nix:

```nix
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
```

/etc/nixos/packages/cli-tools.nix:

```nix
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
```

Continue this pattern for dev-tools.nix and gui-apps.nix with the respective packages.

Benefits of This Structure:

1. Modularity: Each component is separated and manageable
2. Maintainability: Easier to update specific sections
3. Readability: Clear organization makes the config more understandable
4. Reusability: Easy to share or reuse configuration parts
5. Debugging: Isolates issues to specific modules

Final Steps:

1. Create the directory structure
2. Copy the content to each file
3. Test with sudo nixos-rebuild dry-activate
4. Apply with sudo nixos-rebuild switch

Would you like me to help you create any specific module in more detail?
