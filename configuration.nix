# Edit this configuration file to define what should be installed on your system.
# Help is available in the configuration.nix(5) man page and in the NixOS manual.

{ config, pkgs, lib, ... }:

let
  # Define GPU type here (change to "amd" or "nvidia" depending on your GPU)
  gpuType = "nvidia";

  # Check if kernel 6.17 exists
  kernelAvailable = lib.hasAttr "linuxPackages_6_17" pkgs;
in
{
  imports = [
    ./hardware-configuration.nix
  ];

  # ==================== BOOTLOADER & KERNEL CONFIGURATION ====================
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Conditional kernel: use 6.17 if available, otherwise latest
  boot.kernelPackages = if kernelAvailable
    then pkgs.linuxPackages_6_17
    else pkgs.linuxPackages_latest;

  # Warn if kernel 6.17 is missing
  environment.etc."kernel-6-17-check".text = lib.optionalString (not kernelAvailable)
    ''
      WARNING: linuxPackages_6_17 not found in this channel.
      Using linuxPackages_latest instead.
      Consider updating your channels or switching to nixos-unstable.
    '';

  boot.kernelParams = [
    "quiet"
    "splash"
    "nvidia-drm.modeset=1"
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

  # ==================== NVIDIA CONFIGURATION ====================
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    open = false;
    nvidiaSettings = true;
  };

  # ==================== NETWORK CONFIGURATION ====================
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # ==================== INTERNATIONALIZATION ====================
  time.timeZone = "Europe/Copenhagen";

  services.timesyncd = {
    enable = true;
    servers = [
      "0.dk.pool.ntp.org"
      "1.dk.pool.ntp.org"
      "2.dk.pool.ntp.org"
      "3.dk.pool.ntp.org"
    ];
  };

  i18n = {
    defaultLocale = "en_DK.UTF-8";
    supportedLocales = [ "en_DK.UTF-8/UTF-8" "da_DK.UTF-8/UTF-8" ];
    extraLocaleSettings = {
      LANG = "en_DK.UTF-8";
      LC_CTYPE = "en_DK.UTF-8";
      LC_NUMERIC = "da_DK.UTF-8";
      LC_TIME = "da_DK.UTF-8";
      LC_MONETARY = "da_DK.UTF-8";
      LC_ADDRESS = "da_DK.UTF-8";
      LC_IDENTIFICATION = "da_DK.UTF-8";
      LC_MEASUREMENT = "da_DK.UTF-8";
      LC_PAPER = "da_DK.UTF-8";
      LC_TELEPHONE = "da_DK.UTF-8";
      LC_NAME = "da_DK.UTF-8";
    };
  };

  console.keyMap = "dk-latin1";

  # ==================== GRAPHICAL ENVIRONMENT ====================
  services.xserver.enable = true;
  xdg.mime.enable = true;

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  services.desktopManager.plasma6.enable = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      vaapiVdpau
      libvdpau-va-gl
      mesa
    ] ++ lib.optionals (gpuType == "nvidia") [
      nvidia-vaapi-driver
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      libva
      mesa
    ] ++ lib.optionals (gpuType == "nvidia") [
      nvidia-vaapi-driver
    ];
  };

  services.printing.enable = true;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  security.polkit.enable = true;
  security.pam.services = {
    login.enableKwallet = true;
    swaylock = {};
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

  users.users.togo-gt = {
    isNormalUser = true;
    description = "Togo-GT";
    extraGroups = [ "networkmanager" "wheel" "input" "docker" "libvirtd" ];
    shell = pkgs.zsh;
    packages = with pkgs; [
      kdePackages.kate
    ];
  };

  services.displayManager.autoLogin.enable = false;
  programs.firefox.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      kdePackages.xdg-desktop-portal-kde
      xdg-desktop-portal-gtk
    ];
  };

  programs.dconf.enable = true;

  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  environment.systemPackages = with pkgs; [
    # (Your full package list remains here as in original)
  ];

  # ==================== ADDITIONAL SYSTEM CONFIGURATION ====================
  services.fstrim.enable = true;
  services.earlyoom.enable = true;
  services.flatpak.enable = true;
  services.power-profiles-daemon.enable = true;
  services.auto-cpufreq.enable = false;
  services.tlp.enable = false;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  programs.gamemode.enable = true;
  services.hardware.bolt.enable = true;

  virtualisation = {
    docker = {
      enable = true;
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };
    libvirtd = {
      enable = true;
      qemu = {
        runAsRoot = true;
        swtpm.enable = true;
      };
    };
  };

  services = {
    avahi = {
      enable = true;
      nssmdns4 = true;
    };
    fwupd.enable = true;
    thermald.enable = true;
  };

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
    ];
    fontconfig = {
      defaultFonts = {
        monospace = [ "JetBrainsMono Nerd Font" "Noto Sans Mono" ];
        sansSerif = [ "Noto Sans" ];
        serif = [ "Noto Serif" ];
      };
    };
  };

  services.openssh.enable = true;

  networking.firewall = {
    allowedTCPPorts = [ 22 80 443 27036 27037 ];
    allowedUDPPorts = [ 27031 27036 3659 ];
  };

  security = {
    sudo = {
      wheelNeedsPassword = true;
      execWheelOnly = true;
    };
    protectKernelImage = true;
    auditd.enable = true;
  };

  system.stateVersion = "25.05";
}
