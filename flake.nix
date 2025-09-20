{
  description = "NixOS configuration with flakes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
  let
    system = "x86_64-linux";

    # List of packages that require unfree licensing
    unfreePackages = [
      "nvidia-x11"
      "nvidia-settings"
      "steam"
      "steam-run"
      "spotify"
      "vscode"
      "discord"
      "zoom"
      "slack"
      "skype"
      "teamviewer"
      "anydesk"
      "onedrive"
      "dropbox"
      "google-chrome"
      "google-chrome-dev"
      "microsoft-edge"
      "opera"
      "brave"
      "signal-desktop"
      "telegram-desktop"
      "thunderbird"
      "vlc"
      "gimp"
      "inkscape"
      "krita"
      "okular"
      "obs-studio"
      "lutris"
      "wine"
      "gamemode"
      "mangohud"
      "protonup-qt"
      "transmission"
    ];

    # Import nixpkgs with unfree packages allowed
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) unfreePackages;
    };

    lib = nixpkgs.lib;
  in {
    # NixOS system configuration
    nixosConfigurations.nixos-btw = lib.nixosSystem {
      inherit system pkgs;

      modules = [
        # System configuration module
        ({ config, lib, modulesPath, ... }:
        let
          gpuType = "optimus";
        in
        {
          # Allow unfree packages in system configuration
          nixpkgs.config.allowUnfree = true;
          nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) unfreePackages;

          # =============================================================================
          # USER CONFIGURATION
          # =============================================================================
          users.users.togo-gt = {
            isNormalUser = true;
            description = "Togo-GT";
            extraGroups = [ "networkmanager" "wheel" "input" "docker" "libvirtd" ];
            shell = pkgs.zsh;
            packages = with pkgs; [ kdePackages.kate ];
          };

          # Enable Z shell system-wide
          programs.zsh.enable = true;

          # =============================================================================
          # HARDWARE CONFIGURATION
          # =============================================================================
          boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" "sdhci_pci" ];
          boot.initrd.kernelModules = [ ];
          boot.kernelModules = [ "kvm-intel" "fuse" "v4l2loopback" "snd-aloop" "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" "acpi_call" ];
          boot.extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];

          fileSystems."/" = {
            device = "/dev/disk/by-uuid/e022ad77-03e6-4ec3-8cf6-5c770fc84bcf";
            fsType = "ext4";
          };

          fileSystems."/boot" = {
            device = "/dev/disk/by-uuid/6F34-E01A";
            fsType = "vfat";
            options = [ "fmask=0077" "dmask=0077" ];
          };

          swapDevices = [
            { device = "/dev/disk/by-uuid/650b55d0-c9c0-4f03-9458-a34990ab9d36"; }
          ];

          networking.useDHCP = lib.mkDefault true;
          nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
          hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
          hardware.enableRedistributableFirmware = true;

          # =============================================================================
          # SYSTEM CONFIGURATION
          # =============================================================================
          boot = {
            loader.systemd-boot = {
              enable = true;
              configurationLimit = 10;
            };
            loader.efi.canTouchEfiVariables = true;
            kernelPackages = pkgs.linuxPackages_latest;
            kernelParams = [
              "quiet" "splash" "nvidia-drm.modeset=1" "nowatchdog" "tsc=reliable"
              "nohibernate" "nvreg_EnableMSI=1"
            ];
          };

          # Optimus setup for NVIDIA GPU
          services.xserver.displayManager.setupCommands = ''
            ${pkgs.xorg.xrandr}/bin/xrandr --setprovideroutputsource modesetting NVIDIA-0
            ${pkgs.xorg.xrandr}/bin/xrandr --auto
          '';

          # NVIDIA graphics configuration
          hardware.nvidia = {
            modesetting.enable = true;
            powerManagement.enable = true;
            open = false;
            nvidiaSettings = true;
            package = config.boot.kernelPackages.nvidiaPackages.stable;
            prime = {
              sync.enable = true;
              intelBusId = "PCI:0:2:0";
              nvidiaBusId = "PCI:1:0:0";
            };
          };

          # Printing services
          services.printing.enable = true;

          # Audio services
          security.rtkit.enable = true;
          services.pipewire = {
            enable = true;
            alsa.enable = true;
            alsa.support32Bit = true;
            pulse.enable = true;
            jack.enable = true;
          };

          # Bluetooth configuration
          hardware.bluetooth = {
            enable = true;
            powerOnBoot = true;
          };
          services.blueman.enable = true;

          # Networking configuration
          networking = {
            hostName = "nixos-btw";
            networkmanager.enable = true;
          };

          # Time and localization
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
            supportedLocales = [
              "en_DK.UTF-8/UTF-8"
              "da_DK.UTF-8/UTF-8"
            ];
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

          services.xserver.xkb = {
            layout = "dk";
            variant = "";
          };

          console.keyMap = "dk-latin1";

          # Desktop environment (Plasma 6)
          services.xserver = {
            enable = true;
            videoDrivers = [ "nvidia" ];
          };

          xdg.mime.enable = true;

          services.displayManager.sddm = {
            enable = true;
            wayland.enable = true;
          };

          services.desktopManager.plasma6.enable = true;

          xdg.portal = {
            enable = true;
            extraPortals = with pkgs; [
              kdePackages.xdg-desktop-portal-kde
              xdg-desktop-portal-gtk
            ];
          };

          programs.dconf.enable = true;

          users.defaultUserShell = pkgs.zsh;
          services.displayManager.autoLogin.enable = false;

          # Browser
          programs.firefox.enable = true;

          # Nix configuration
          nix.settings = {
            experimental-features = [ "nix-command" "flakes" ];
            auto-optimise-store = true;
            keep-outputs = true;
            keep-derivations = true;
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

          # System packages (minimal set, most packages are in home.nix)
          environment.systemPackages = with pkgs; [
            # Essential system tools
            gitFull
            curl
            wget
            vim
            neovim
            tmux
            htop
            btop
            nix-index
            home-manager

            # Hardware-specific tools
            nvidia-vaapi-driver
            dmidecode
            inxi
            pciutils
            smartmontools
            ntfs3g
            clinfo
            glxinfo
            vulkan-loader
            vulkan-tools
          ];

          # System services
          services.fstrim.enable = true;
          services.earlyoom.enable = true;
          services.flatpak.enable = true;

          # Power management
          services.power-profiles-daemon.enable = lib.mkForce false;
          systemd.user.services."power-profiles-daemon" = {
            enable = false;
            wantedBy = lib.mkForce [];
          };

          services.tlp = {
            enable = true;
            settings = {
              CPU_SCALING_GOVERNOR_ON_AC = "performance";
              CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
            };
          };

          # Gaming
          programs.steam = {
            enable = true;
            remotePlay.openFirewall = true;
            dedicatedServer.openFirewall = true;
          };
          programs.gamescope.enable = true;
          programs.gamemode.enable = true;

          # Hardware support
          services.hardware.bolt.enable = true;

          # Virtualization
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
            avahi = {
              enable = true;
              nssmdns4 = true;
            };
            fwupd.enable = true;
            thermald.enable = true;
          };

          # Fonts
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

          # Security
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
        })

        # Home Manager integration
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "backup";
            users.togo-gt = import ./home.nix;
          };
        }
      ];
    };

    # Home Manager standalone configuration
    homeConfigurations."togo-gt@nixos-btw" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [ ./home.nix ];
    };
  };
}
