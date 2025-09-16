# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ config, pkgs, lib, ... }:

let
  # Define GPU type here (change to "amd" or "nvidia" depending on your GPU)
  gpuType = "nvidia";  # ÆNDRET: Fra intel til nvidia
in
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
    "quiet"           # Reduce boot noise
    "splash"          # Show splash screen
    "nvidia-drm.modeset=1"  # Tilføjet: NVIDIA DRM modesetting
    "nowatchdog"      # Disable hardware watchdog
    "tsc=reliable"    # Reliable Time Stamp Counter
    "nohibernate"     # Disable hibernation
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

  # ==================== NVIDIA KONFIGURATION ====================
  hardware.nvidia = {
    # Modesetting er påkrævet for Wayland og bedre integration
    modesetting.enable = true;
    # Power Management (forbrugervenlig på bærbare, kan nogle gange forårsage issues - deaktiver hvis nødvendigt)
    powerManagement.enable = true;
    # Brug de open-source kernel-moduler (NOUVEAU)? Sæt til false for at bruge de proprietære NVIDIA-drivere.
    open = false;
    # Tillad at bruge NVIDIA Settings værktøjet til at justere indstillinger
    nvidiaSettings = true;
  };

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
  # Aktiver X11 vinduessystemet (nødvendigt for de fleste desktop-miljøer)
  services.xserver.enable = true;
  xdg.mime.enable = true;

  # Aktiver KDE Plasma Desktop Environment
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true; # Wayland support
  };

  services.desktopManager.plasma6.enable = true;

  # ==================== HARDWARE-STØTTE ====================
  # Modern hardware acceleration
  hardware.graphics = {
    enable = true;
    enable32Bit = true;  # Renamed from driSupport32Bit
    extraPackages = with pkgs; [
      vaapiVdpau
      libvdpau-va-gl
      mesa
    ] ++ lib.optionals (gpuType == "nvidia") [  # ÆNDRET: Tilføjet NVIDIA-pakker
      nvidia-vaapi-driver
    ];

    extraPackages32 = with pkgs.pkgsi686Linux; [
      libva
      mesa
    ] ++ lib.optionals (gpuType == "nvidia") [  # ÆNDRET: Tilføjet 32-bit NVIDIA-pakker
      nvidia-vaapi-driver
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
    jack.enable = true;         # Aktiver for JACK-applikationer (lydproduktion)
  };

  # Bluetooth-konfiguration
  hardware.bluetooth.enable = true;     # Aktiver Bluetooth
  services.blueman.enable = true;       # Bluetooth GUI-manager
  hardware.bluetooth.powerOnBoot = true; # Tænd Bluetooth ved opstart

  # ==================== SECURITY & POLKIT ====================
  # Polkit authentication (nødvendigt for KDE og system administration)
  security.polkit.enable = true;

  # Pam configuration for better security
  security.pam.services = {
    login.enableKwallet = true;
    swaylock = {}; # Tilføj hvis du bruger swaylock
  };

  # ==================== BRUGERKONFIGURATION ====================
  # Aktiver Zsh shell (kraftigt og konfigurerbart shell)
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

  # ==================== XDG DESKTOP PORTAL ====================
  # XDG Desktop Portal integration (nødvendigt för Wayland og app integration)
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      kdePackages.xdg-desktop-portal-kde  # Qt6-version (anbefalet)
      xdg-desktop-portal-gtk
    ];
  };

  # Dconf support (nødvendigt for GNOME/GTK apps i KDE)
  programs.dconf.enable = true;

  # ==================== NIX-PAKKEKONFIGURATION ====================
  # Tillad ikke-frie (proprietære) pakker
  nixpkgs.config.allowUnfree = true;

  # Nix optimization settings - consolidated into a single definition
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

  # Automatisk oprydning af gamle pakker
  nix.gc = {
    automatic = true;           # Kør automatisk
    dates = "weekly";           # Kør en gang om ugen
    options = "--delete-older-than 7d"; # Slet pakker ældre end 7 dage
  };

  # Liste over pakker installeret i systemprofilen
  environment.systemPackages = with pkgs; [

  # -------------------------------
  # Systemværktøjer
  # -------------------------------
  bat          # Forbedret 'cat' med syntaksfremhævning
  btop         # Avanceret interaktiv ressourceovervågning
  bottom       # Alternativ ressourceovervågning til terminalen
  curl         # Overfør data via URL'er (HTTP, FTP osv.)
  duf          # Diskbrugsovervågning med flot output
  fd           # Hurtig og moderne erstatning for 'find'
  file         # Viser filtypeinformation
  git          # Versionskontrolsystem til kode og filer
  htop         # Interaktiv system- og procesovervågning
  jq           # JSON processor og manipulationsværktøj
  neofetch     # Vis systeminformation og OS-banner
  rsync        # Fil synkronisering mellem systemer
  tmux         # Terminal multiplexer til sessioner og vinduer
  unzip        # Udpakning af .zip arkiver
  vim          # Kraftfuld teksteditor
  wget         # Hent filer via HTTP/FTP
  xdg-utils    # Standard desktop utilities (åbn filer, URL'er osv.)

  # -------------------------------
  # Hardware diagnosticering
  # -------------------------------
  clinfo             # OpenCL info tool til GPU compute info
  dmidecode          # Hent hardwareinformation fra BIOS
  glxinfo            # OpenGL information og GPU-support
  inxi               # Udskriv detaljeret systeminformation
  lm_sensors         # Temperatur og sensorovervågning
  nvtopPackages.full # GPU monitor til NVIDIA-kort
  pciutils           # Vis information om PCI-enheder
  smartmontools      # Disk health og S.M.A.R.T. overvågning
  vulkan-loader      # Loader til Vulkan API
  vulkan-tools       # Vulkan værktøjer og demos

  # -------------------------------
  # Desktop / GUI support
  # -------------------------------
  kdePackages.dolphin # KDE filhåndtering
  kdePackages.konsole # KDE terminalemulator
  libnotify           # Desktop notifikationer
  libva-utils         # VA-API værktøjer til video acceleration
  ntfs3g              # NTFS filsystem-understøttelse
  micro               # Brugervenlig og minimalistisk teksteditor

  # -------------------------------
  # Development / Programming
  # -------------------------------
  gcc       # C/C++ compiler
  nodejs    # JavaScript runtime og udviklingsværktøj
  python3   # Python interpreter
  rustup    # Rust toolchain installer
  fzf       # Fuzzy finder til hurtig filsøgning i terminal

  # -------------------------------
  # Gaming og optimering
  # -------------------------------
  gamemode      # Game optimization tool for Linux
  gamescope     # Steam Deck-lignende scaling og compositor
  lutris        # Game manager til Linux
  mangohud      # Performance overlay til spil
  protonup-qt   # Administrer Proton versioner til Steam
  wine          # Windows compatibility layer for Linux

  # -------------------------------
  # Virtualisering og containerization
  # -------------------------------
  docker-compose # Docker container management
  distrobox      # Containerized development environments
  virt-manager   # GUI til libvirt og VM management
  appimage-run   # Kør AppImage filer direkte

  # -------------------------------
  # Netværksværktøjer
  # -------------------------------
  iperf3 # Netværks-performance måling
  nmap   # Netværks scanning og sikkerhedsværktøj

  # -------------------------------
  # NVIDIA-specifikke værktøjer
  # -------------------------------
  linuxPackages.nvidia_x11  # NVIDIA X11 driver til GPU
  nvidia-vaapi-driver       # NVIDIA VA-API driver til hardware acceleration

  # -------------------------------
  # Pakkeadministration og Nix-udvidelser
  # -------------------------------
  cachix    # Nix binary cache client
  nix-index # Find hurtigt pakker i NixOS
];


  # ==================== YDERLIGERE SYSTEMKONFIGURATION ====================
  # Aktiver TRIM for SSD-drev (forbedrer ydelse og levetid)
  services.fstrim.enable = true;

  # Aktiver early OOM daemon (håndterer hukommelsesmangel tidligt)
  services.earlyoom.enable = true;

  # Flatpak-understøttelse (til installation af apps från Flathub)
  services.flatpak.enable = true;

  # Strømstyring (især nyttigt til bærbare)
  services.power-profiles-daemon.enable = true; # Anbefalet til KDE
  services.auto-cpufreq.enable = false;
  services.tlp.enable = false;

  # Steam gaming support
  programs.steam = {
    enable = true;                      # Aktiver Steam
    remotePlay.openFirewall = true;     # Åbn firewall for Remote Play
    dedicatedServer.openFirewall = true; # Åbn firewall for dedicated servers
  };

  # Gaming optimering
  programs.gamemode.enable = true;

  # Hardware monitoring
  services.hardware.bolt.enable = true; # Thunderbolt

  # Virtualization support
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

  # Additional services
  services = {
    avahi = { # Network service discovery
      enable = true;
      nssmdns4 = true;
    };
    fwupd.enable = true; # Firmware updates
    thermald.enable = true; # Thermal management
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
      monospace = [ "JetBrainsMono Nerd Font" "Noto Sans Mono" ];
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
    allowedTCPPorts = [
      22 80 443
      27036 27037 # Steam
    ];
    allowedUDPPorts = [
      27031 27036 # Steam
      3659 # Lunar Client
    ];
  };

  # Additional security measures
  security = {
    sudo = {
      wheelNeedsPassword = true; # Require password for sudo
      execWheelOnly = true;      # Only wheel group can use sudo
    };
    protectKernelImage = true; # Protect kernel from modification
    auditd.enable = true;      # System auditing
  };

  # Denne værdi bestemmer NixOS-udgivelsen som standardindstillingerne er taget fra
  system.stateVersion = "25.05"; # Behold denne værdi som den er
}
