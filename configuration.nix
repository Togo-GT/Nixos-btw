# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix  # Importerer hardware-specifik konfiguration genereret af systemet
    ];

  # ==================== BOOTLOADER KONFIGURATION ====================
  # Bootloader konfiguration for UEFI-systemer
  boot.loader.systemd-boot.enable = true;      # Bruger systemd-boot som bootloader (modern og simpel)
  boot.loader.efi.canTouchEfiVariables = true; # Tillader at opdatere EFI-bootvariabler (nødvendigt for UEFI)

  # Brug den nyeste Linux kernel
  boot.kernelPackages = pkgs.linuxPackages_latest; # Får de nyeste kernedrivere og sikkerhedsopdateringer

  # Kernel parameters for better performance
  boot.kernelParams = [
    "mitigations=off" # Disable security mitigations for performance
    "quiet"           # Reduce boot noise
    "splash"          # Show splash screen
  ];

  # Common hardware kernel modules
  boot.initrd.availableKernelModules = [
    "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod"
  ];

  # Aktiver nyttige kernel moduler
  boot.kernelModules = [
    "fuse"          # Understøttelse for FUSE-filsystemer (bruges af bl.a. SSHFS, NTFS-3G)
    "v4l2loopback"  # Virtual video device - god til skærmoptagelse og virtual cameras
    "snd-aloop"     # Virtual lyd-enhed - god til lydoptagelse og routing
  ];

  # ==================== NETVÆRKSKONFIGURATION ====================
  networking.hostName = "nixos"; # Definerer dit systemets navn på netværket

  # Aktivér NetworkManager (anbefalet til både kablet og trådløst netværk)
  networking.networkmanager.enable = true;

  # ==================== INTERNATIONALISERING ====================
  # Sæt tidszone til København (Central European Time)
  time.timeZone = "Europe/Copenhagen";

  # Sprog- og lokalitetsindstillinger
  i18n = {
    # Standardsprog for systemet (engelsk med UTF-8 tegnsæt)
    defaultLocale = "en_US.UTF-8";

    # Liste over sprog der skal understøttes på systemet
    supportedLocales = [
      "en_US.UTF-8/UTF-8"  # Engelsk (USA) med UTF-8 tegnkodning
      "da_DK.UTF-8/UTF-8"  # Dansk tilføjet
    ];

    # Ekstra miljøvariabler for finjustering af lokalitetsindstillinger
    extraLocaleSettings = {
      LANG = "en_US.UTF-8";        # Standardsprog for alle applikationer
      LC_CTYPE = "en_US.UTF-8";    # Tegnklassifikation (bogstaver, cases)
      LC_NUMERIC = "en_US.UTF-8";  # Talformatering (decimalseparator, tusindseparator)
      LC_TIME = "en_US.UTF-8";     # Dato- og tidsformat
      LC_MONETARY = "en_US.UTF-8"; # Valutaformat
      LC_ADDRESS = "en_US.UTF-8";  # Adresseformatering
      LC_IDENTIFICATION = "en_US.UTF-8"; # Metadata om lokaliteten
      LC_MEASUREMENT = "en_US.UTF-8";    # Måleenheder (metrisk/imperial)
      LC_PAPER = "en_US.UTF-8";          # Papirstørrelse (A4 eller Letter)
      LC_TELEPHONE = "en_US.UTF-8";      # Telefonnummerformatering
      LC_NAME = "en_US.UTF-8";           # Navneformatering
    };
  };

  # Tastaturkonfiguration til X11 (grafisk interface)
  services.xserver.xkb = {
    layout = "dk";    # Dansk tastaturlayout
    variant = "";     # Ingen speciel variant
  };

  # Tastaturkonfiguration til virtuel konsol (TTY)
  console.keyMap = "dk-latin1";  # Dansk tastaturlayout med Latin-1 tegnkodning

  # ==================== GRAFISK MILJØ ====================
  # Aktiver X11 vinduesystemet (nødvendigt for de fleste desktop-miljøer)
  services.xserver.enable = true;

  # Aktiver KDE Plasma Desktop Environment
  services.displayManager.sddm.enable = true;      # SDDM som login-manager
  services.desktopManager.plasma6.enable = true;   # KDE Plasma 6 som desktop-miljø

  # ==================== HARDWARE-STØTTE ====================
  # Enable hardware acceleration (updated for NixOS 25.05)
  hardware.graphics = {
  enable = true;
  extraPackages = with pkgs; [
    vaapiVdpau
    libvdpau-va-gl
  ];
  extraPackages32 = with pkgs.pkgsi686Linux; [
    libva
  ];
};

  # Aktiver CUPS til udskrivning
  services.printing.enable = true;

  # Aktiver lyd med PipeWire (modern erstatning for PulseAudio)
  security.rtkit.enable = true;  # Realtime kit til prioritet af lydprocesser
  services.pipewire = {
    enable = true;
    alsa.enable = true;         # ALSA-understøttelse (Advanced Linux Sound Architecture)
    alsa.support32Bit = true;   # Understøttelse af 32-bit applikationer
    pulse.enable = true;        # PulseAudio-kompatibilitet
    # jack.enable = true;       # Aktiver for JACK-applikationer (lydproduktion)
  };

  # Bluetooth-konfiguration
  hardware.bluetooth.enable = true;     # Aktiver Bluetooth
  services.blueman.enable = true;       # Bluetooth GUI-manager
  hardware.bluetooth.powerOnBoot = true; # Tænd Bluetooth ved opstart

  # Bluetooth lydunderstøttelse
  hardware.bluetooth.settings = {
    General = {
      Enable = "Source,Sink,Media,Socket"; # Aktiver alle Bluetooth-funktioner
    };
  };

  # ==================== BRUGERKONFIGURATION ====================
  # Aktiver Zsh shell (kraftigt og konfigurerbart shell)
  programs.zsh.enable = true;

  # Definér en brugerkonto
  users.users.togo-gt = {
    isNormalUser = true;       # Definerer som normal bruger (ikke systembruger)
    description = "Togo-GT";   # Beskrivelse af brugeren
    extraGroups = [
      "networkmanager"         # Tillader netværkskonfiguration
      "wheel"                  # Tillader sudo-adgang (administrative rettigheder)
      "input"                  # Tillader adgang til input-enheder (mus/tastatur)
      "docker"                 # Tillader Docker-adgang
      "libvirtd"               # Tillader virtualisering
    ];
    shell = pkgs.zsh;          # Sætter Zsh som standard shell
    packages = with pkgs; [
      kdePackages.kate         # Kraftig teksteditor fra KDE
      # thunderbird           # Email-klient (fjern kommentar for at aktivere)
    ];
  };

  # Sikkerhedsforbedring: Deaktiveret automatisk login
  services.displayManager.autoLogin.enable = false;
  # services.displayManager.autoLogin.user = "togo-gt";

  # Installer Firefox webbrowser
  programs.firefox.enable = true;

  # ==================== NIX-PAKKEKONFIGURATION ====================
  # Tillad ikke-frie (proprietære) pakker
  nixpkgs.config.allowUnfree = true;

  # Aktiver flakes og nix-command (moderne Nix-funktioner)
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Automatisk oprydning af gamle pakker
  nix.gc = {
    automatic = true;           # Kør automatisk
    dates = "weekly";           # Kør en gang om ugen
    options = "--delete-older-than 7d"; # Slet pakker ældre end 7 dage
  };

  # Liste over pakker installeret i systemprofilen
  environment.systemPackages = with pkgs; [
    # Versionskontrol og systemværktøjer
    git          # Versionskontrolsystem
    vim          # Teksteditor
    wget         # Hent filer via HTTP/FTP
    curl         # Overfør data via URL'er
    htop         # Interaktiv systemovervågning
    file         # Vis filtypeinformation

    # Arkivværktøjer
    unzip        # Udpak .zip-filer
    p7zip        # Udpak .7z-filer

    # Hardware diagnosticering
    pciutils     # Viser PCI-enhedsinformation
    inxi         # System information tool

    # KDE-applikationer
    kdePackages.dolphin   # Filhåndtering
    kdePackages.konsole   # Terminalemulator

    # Terminalværktøjer
    ripgrep      # Hurtig filsøgning
    fd           # Modern erstatning for 'find'
    eza          # Forbedret 'ls' med farver og metadata

    # Systemovervågning
    neofetch     # Vis systeminformation
    bottom       # Ressourceovervågning
    duf          # Diskbrugsoversigt

    # Tekstbehandling
    bat          # Forbedret 'cat' med syntaksfremhævning
    fzf          # Fuzzy finder til terminalen

    # Filsystemstøtte
    ntfs3g       # NTFS filsystem-understøttelse
    micro        # Brugervenlig teksteditor

    # Udviklingsværktøjer
    nodejs       # JavaScript runtime
    python3      # Python interpreter
    gcc          # C/C++ compiler
    rustup       # Rust toolchain installer

    # Gaming værktøjer
    gamemode     # Game optimization tool
    mangohud     # Performance overlay
    wine         # Windows compatibility layer
    lutris       # Game manager

    # Virtualisering
    docker-compose # Docker container management

    # Netværksværktøjer
    nmap         # Network exploration tool
    iperf3       # Network performance measurement
  ];

  # ==================== YDERLIGERE SYSTEMKONFIGURATION ====================
  # Aktiver TRIM for SSD-drev (forbedrer ydelse og levetid)
  services.fstrim.enable = true;

  # Aktiver early OOM daemon (håndterer hukommelsesmangel tidligt)
  services.earlyoom.enable = true;

  # Flatpak-understøttelse (til installation af apps från Flathub)
  services.flatpak.enable = true;

  # Strømstyring (især nyttigt til bærbare)
  services.power-profiles-daemon.enable = true;
  # services.tlp.enable = true;  # Bedre batterilevetid (aktivér hvis nødvendigt)

  # Steam gaming support
  programs.steam = {
    enable = true;                      # Aktiver Steam
    remotePlay.openFirewall = true;     # Åbn firewall for Remote Play
    dedicatedServer.openFirewall = true; # Åbn firewall for dedicated servers
  };

  # Virtualization support
  virtualisation = {
    docker.enable = true;
    libvirtd.enable = true;
  };

  # Better font rendering
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
      monospace = [ "JetBrains Mono Nerd Font" ];
      sansSerif = [ "Noto Sans" ];
      serif = [ "Noto Serif" ];
    };
  };
};

  # ==================== SIKKERHEDSKONFIGURATION ====================
  # Aktiver OpenSSH daemon (fjernadgang via SSH)
  services.openssh.enable = true;

  # Firewall-konfiguration
  networking.firewall = {
    enable = true;  # Aktiver firewall
    allowedTCPPorts = [ 22 80 443 ];  # Tillad SSH (22), HTTP (80), HTTPS (443)
    allowedUDPPorts = [ ];             # Ingen UDP-porte tilladt som standard
  };

  # Additional security measures
  security = {
    sudo.wheelNeedsPassword = true; # Require password for sudo
    protectKernelImage = true; # Protect kernel from modification
  };

  # Denne værdi bestemmer NixOS-udgivelsen som standardindstillingerne er taget fra
  system.stateVersion = "25.05"; # Behold denne værdi som den er
}
