{
  description = "NixOS configuration with flakes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    # Home Manager for user-specific configuration
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations.nixos-btw = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      modules = [
        ({ config, pkgs, lib, modulesPath, ... }:
        let
          gpuType = "optimus";
        in
        {
          # =============================================================================
          # HARDWARE CONFIGURATION (from hardware-configuration.nix)
          # =============================================================================
          boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" "sdhci_pci" ];
          boot.initrd.kernelModules = [ ];
          boot.kernelModules = [ "kvm-intel" "fuse" "v4l2loopback" "snd-aloop" "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" "acpi_call" ];  # Added acpi_call
          boot.extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];  # Added acpi_call

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
          hardware.enableRedistributableFirmware = true;  # Added firmware updates

          # =============================================================================
          # SYSTEM CONFIGURATION (from configuration.nix)
          # =============================================================================
          boot = {
            loader.systemd-boot.enable = true;
            loader.efi.canTouchEfiVariables = true;
            kernelPackages = pkgs.linuxPackages_latest;
            kernelParams = [
              "quiet" "splash" "nvidia-drm.modeset=1" "nowatchdog" "tsc=reliable"
              "nohibernate" "nvreg_EnableMSI=1"
            ];
          };

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

          hardware.graphics = {
            enable = true;
            enable32Bit = true;
            extraPackages = with pkgs; [
              vaapiVdpau
              libvdpau-va-gl
              mesa
            ] ++ lib.optionals (gpuType == "nvidia" || gpuType == "optimus") [
              nvidia-vaapi-driver
            ];
            extraPackages32 = with pkgs.pkgsi686Linux; [
              libva
              mesa
            ] ++ lib.optionals (gpuType == "nvidia" || gpuType == "optimus") [
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

          hardware.bluetooth = {
            enable = true;
            powerOnBoot = true;
          };
          services.blueman.enable = true;

          networking = {
            hostName = "nixos-btw";
            networkmanager.enable = true;
          };

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
              LC_IDENTIFICATION = "da_DK.UTF-8";  # Fixed spelling
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

          # =============================================================================
          # HOME MANAGER CONFIGURATION
          # =============================================================================
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.togo-gt = import ./home.nix;
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

          users.defaultUserShell = pkgs.zsh;

          services.displayManager.autoLogin.enable = false;

          programs.firefox.enable = true;

          nixpkgs.config.allowUnfree = true;

          nix.settings = {
            experimental-features = [ "nix-command" "flakes" ];
            auto-optimise-store = true;
            keep-outputs = true;  # Added for better dev environment support
            keep-derivations = true;  # Added for better dev environment support
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
            neovim
            ripgrep
            ripgrep-all
            btop
            bottom
            htop
            glances
            iotop
            nethogs
            powertop
            borgbackup
            rsnapshot
            rsync
            gitFull
            curl
            curlie
            fzf
            starship
            taskwarrior3
            tldr
            tmux
            tmuxp
            watch
            zsh
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
            packer
            terraform
            docker
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
            firefox
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
            transmission_3-gtk
            lutris
            wine
            clinfo
            glxinfo
            vulkan-loader
            vulkan-tools
            nvidia-vaapi-driver
            dmidecode
            inxi
            pciutils
            smartmontools
            ntfs3g
            gamemode
            mangohud
            libnotify
            libva-utils
          ];

          services.fstrim.enable = true;
          services.earlyoom.enable = true;
          services.flatpak.enable = true;

          # Ensure power-profiles-daemon is fully disabled when using TLP
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

          programs.steam = {
            enable = true;
            remotePlay.openFirewall = true;
            dedicatedServer.openFirewall = true;
          };
          programs.gamescope.enable = true;
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
        })
        # Home Manager module
        home-manager.nixosModules.home-manager
      ];
    };
  };
}
