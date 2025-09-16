# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;




  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Enable useful kernel modules
  boot.initrd.kernelModules = [ "amdgpu" ];  # Fjern hvis du ikke har AMD GPU
  boot.kernelModules = [
  "fuse"
  "v4l2loopback"
  "snd-aloop"
  ];

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;


  # Set time zone to Copenhagen (Central European Time)
  time.timeZone = "Europe/Copenhagen";

i18n = {
  # Default system locale (language + character encoding)
  # This is the locale your system will use by default.
  defaultLocale = "en_US.UTF-8";

  # List of locales that should be generated on the system
  # Here we only generate English UTF-8
  supportedLocales = [
    "en_US.UTF-8/UTF-8"  # English (United States) with UTF-8 encoding
  ];

  # Additional environment variables for finer locale control
  # These LC_* variables control specific aspects of formatting:
  extraLocaleSettings = {
    LANG = "en_US.UTF-8";        # Default language for all applications
    LC_CTYPE = "en_US.UTF-8";    # Character classification (letters, case)
    LC_NUMERIC = "en_US.UTF-8";  # Number formatting (decimal point, thousands separator)
    LC_TIME = "en_US.UTF-8";     # Date and time format
    LC_MONETARY = "en_US.UTF-8"; # Currency format
    LC_ADDRESS = "en_US.UTF-8";  # Address formatting
    LC_IDENTIFICATION = "en_US.UTF-8"; # Metadata about the locale
    LC_MEASUREMENT = "en_US.UTF-8";    # Measurement units (metric/imperial)
    LC_PAPER = "en_US.UTF-8";          # Paper size (A4 or Letter)
    LC_TELEPHONE = "en_US.UTF-8";      # Telephone number formatting
    LC_NAME = "en_US.UTF-8";           # Name formatting
    # Note: LC_ALL is intentionally not set; it would override all the above LC_* settings
  };
};

  # Keyboard configuration for X11 (graphical interface)
  services.xserver.xkb = {
    layout = "dk";    # Danish keyboard layout
    variant = "";     # No special variant
  };

  # Keyboard configuration for virtual console (TTY)
  console.keyMap = "dk-latin1";  # Danish keyboard layout with Latin-1 encoding

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;


  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Enable Zsh shell
  programs.zsh.enable = true;

  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.togo-gt = {
    isNormalUser = true;
    description = "Togo-GT";
    extraGroups = [ "networkmanager" "wheel" "input" ];
    shell = pkgs.zsh;
    packages = with pkgs; [
      kdePackages.kate
    #  thunderbird
    ];
  };

  # Enable automatic login for the user.
  # Sikkerhedsforbedring: deaktiveret automatisk login
  services.displayManager.autoLogin.enable = false;
  # services.displayManager.autoLogin.user = "togo-gt";

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Automatic garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget

 environment.systemPackages = with pkgs; [

  git          # Versionskontrolsystem
  vim          # Teksteditor
  wget         # Kommando-linje værktøj til at hente filer via HTTP/FTP
  curl         # Kommando-linje værktøj til at hente/fremføre data over URL'er
  htop         # Interaktiv systemmonitor
  file         # Viser filtypeinformation
  unzip        # Udpakning af .zip filer
  p7zip        # Udpakning af .7z filer
  pciutils
 # KDE applications

  kdePackages.dolphin   # KDE filhåndtering
  kdePackages.konsole   # KDE terminal

 # Useful utilities

  ripgrep      # Hurtig søgning i filer
  fd           # Moderne og hurtig erstatning for 'find'
  eza          # Forbedret 'ls'-kommando med farver og kolonner

 # Additional useful tools

  neofetch     # Viser systeminformation i terminalen
  bottom       # Ressourcemonitor (som htop, men med mere info)
  duf          # Diskbrugsoversigt i terminalen
  bat          # Forbedret 'cat' med syntax highlighting
  fzf          # Fuzzy finder til terminal

 # Nyttige tilføjelser

  ntfs3g       # NTFS filsystem support
  micro        # Brugervenlig teksteditor, nemmere end vim
];


  # Enable TRIM for SSDs
  services.fstrim.enable = true;

  # Enable early OOM daemon to handle low memory situations
  services.earlyoom.enable = true;

  # Enable Bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Bluetooth power management
  hardware.bluetooth.powerOnBoot = true;  # Tilføjet Bluetooth power management

  # Bluetooth audio support
  hardware.bluetooth.settings = {
    General = {
      Enable = "Source,Sink,Media,Socket";
    };
  };

  # Enable Flatpak support
  services.flatpak.enable = true;


  # Configure power management (uncomment if on laptop)
  services.power-profiles-daemon.enable = true;
  # services.tlp.enable = true;  # For better battery life

  # Enable Steam gaming support (uncomment if wanted)
  programs.steam = {
     enable = true;
     remotePlay.openFirewall = true;
     dedicatedServer.openFirewall = true;
  };





  # For AMD:
  # hardware.opengl.extraPackages = with pkgs; [
  #   amdvlk
  # ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 22 80 443 ];
  networking.firewall.allowedUDPPorts = [  ];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
