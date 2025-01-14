{ config, pkgs, lib, ... }: #inputs, outputs, osConfig,

{
  imports = [
      ./hardware-configuration.nix
      <home-manager/nixos>
      #<nixos-hardware/lenovo/thinkpad/p14s/intel/gen3>
    ];

  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 5;
      };
    };
    #kernelModules = [ 
    #];
    kernelPackages = with pkgs; [
      linuxPackages_latest
    ];
    kernelParams = [ 
      #"preempt=full" 
    ];
    blacklistedKernelModules = [
      #"nouveau"
    ];
    initrd = {
      supportedFilesystems = [
        #"bcachefs"
      ];
    };
  };

  nix = {
    settings = {
      experimental-features = [ 
        "nix-command"
        "flakes" # Enables Flakes.
      ];
    };
  };

  services = {
    rpcbind = { # Needed for NFS.
      enable = true; 
    };
    displayManager = {
      sddm = {
        enable = true;
        wayland = {
          enable = true;
        };
      };
    };
    desktopManager = {
      plasma6 = {
        enable = true;
      };
    };
    printing = {
      enable = true;
    };
    xserver = {
      enable = true; # Enable the X11 windowing system. 
      xkb = {
        layout = "us";
        variant = "";
      };
      videoDrivers = [
        "displaylink" 
        "modesetting"
        "nvidia"
      ];
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    #openssh = {
    # enable = true;
    # settings = {
    #  PermitRootLogin = "no"; # Opinionated: forbid root login through SSH.
    #  PasswordAuthentication = false; # Opinionated: use keys only.  Remove if you want to SSH using passwords
    #  };
    #};
    resolved = { # Enable resolved for DNS Resolution fix
      enable = true;
    };
    tailscale = {
      enable = true;
      useRoutingFeatures = "client";
      port = 41641;
    };
    throttled = {
      enable = true;
    };
    thermald = {
      enable = true;
    };
    syncthing = {
      enable = true;
      dataDir = "/home/akmzero";
      openDefaultPorts = true;
      configDir = "/home/akmzero/.config/syncthing";
      user = "akmzero";
      group = "users";
      guiAddress = "127.0.0.1:8384";
      overrideDevices = false;
      overrideFolders = false;
      settings = {
        options = {
          urAccepted = -1;
        };
      };
    };
  };
  
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };

  # Enable Hyprland Wayland Support
  #wayland = {
  #  windowManager = {
  #   hyprland = {
  #     enable = true;
  #    };
  #  };
  #};

  hardware = {
    bluetooth = {
      enable = true;
    };
    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        vpl-gpu-rt
        intel-media-driver
        vaapiVdpau
        libvdpau-va-gl
        intel-media-driver
        nvidia-vaapi-driver
      ];
    };
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = true;
      #nvidiaPersistenced = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
        #sync.enable = true;
        nvidiaBusId = "PCI:45:00:0";
        intelBusId = "PCI:00:02:0";
      };
    };
    pulseaudio = { # Enable sound with pipewire.
      enable = false;
    };
    flipperzero = {
      enable = true;
    };
  };

  security = {
    rtkit = {
      enable = true;
    };
  };

  users = {
    users = {
      akmzero = { # Define user account.
        isNormalUser = true;
      };
    };
    groups = {
      networkmanager = {
        members = [
          "akmzero"
        ];
      };
      wheel = { # Define the Wheel group for Sudo Access.
        members = [
          "akmzero"
        ];
      };
    };
  };
  
  home-manager = {
    useGlobalPkgs = true;
    #useUserPackages = true;
    users = {
      akmzero = { pkgs, ... }: {
        programs = {
          bash = {
            enable = true;
          };
          chromium = {
            package = pkgs.brave;
            enable = true;
            extensions = [
              "kefcfmgmlhmankjmnbijimhofdjekbop" # ChangeDetecion.io
              "nngceckbapebfimnlniiiahkandclblb" # Bitwarden
              "dphilobhebphkdjbpfohgikllaljmgbn" # SimpleLogin
              "hfapbcheiepjppjbnkphkmegjlipojba" # Klarna
              "liindccgkpdcafeceonflfdmkjhijapj" # Quadpay/Zip
              "hmgpakheknboplhmlicfkkgjipfabmhp" # Privacy Payments
              "pnidmkljnhbjfffciajlcpeldoljnidn" # Linkwarden
              "kgcjekpmcjjogibpjebkhaanilehneje" # Hoarder
            ];
          };
          vscode = {
            enable = true;
            extensions = with pkgs.vscode-extensions; [
              continue.continue
              ms-azuretools.vscode-docker
              ms-vscode-remote.remote-ssh
              ms-vscode-remote.remote-containers
              jnoortheen.nix-ide
              ms-python.vscode-pylance
              ms-python.debugpy
              ms-vscode-remote.remote-ssh-edit
              ms-vscode-remote.vscode-remote-extensionpack
              tailscale.vscode-tailscale
              ms-vscode-remote.remote-wsl
            ];
          };
          #hyprland = {
          #  enable = true;
          #};
        };
        home = {
          stateVersion = "24.11";
          packages = with pkgs; [
            obsidian
            syncthing
            brave
            #lutris
            ferdium
            fuse
            #remmina
            vlc
            caffeine-ng
            signal-desktop
            #moonlight-qt
            #bambu-studio
            vscode
            #chirp
            #vscodium
          ];
        };
      };
    };
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
      permittedInsecurePackages = [
        "electron-25.9.0" # For Obsidian.
      ];
    };
  };

  # Global Packages
  environment = {
    systemPackages = with pkgs; [
      git
      wget
      curl
      tmux
      pciutils
      trayscale
      tailscale
      htop-vim
      clinfo
      ffmpeg
      virtualgl
      glxinfo
      vulkan-tools
      wayland-utils
      gpu-viewer
      firmware-updater
      firmware-manager
      ncdu
      htop
      python3
      libvirt
      #rustdesk
      rustdesk-flutter
      #virt-viewer
      #virt-manager
      #spice-gtk
      #egl-wayland
      #cifs-utils
      #nfs-utils
      #pipewire
      direnv
      libnfs
      s-tui
      throttled
      thermald
      wtype
    ];
    sessionVariables = { 
      LIBVA_DRIVER_NAME = [
        "iHD" # Force intel-media-driver: https://nixos.wiki/wiki/Accelerated_Video_Playback
      ]; 
    };
  };

  networking = {
    hostName = "nomad"; # Defines Hostname
    networkmanager = {
      enable = true;
    };
    firewall = {
      enable = true;
      allowedTCPPorts = [ 
        8384 # Syncthing port for remote access to GUI
        22000 # Syncthing port for sync traffic
      ];
      allowedUDPPorts = [ 
        22000 # Syncthing port for sync traffic
        21027 # Syncthing port for discovery
        41641 # Tailscale
      ];
      extraCommands = ''iptables -t raw -A OUTPUT -p udp -m udp --dport 137 -j CT --helper netbios-ns'';
      trustedInterfaces = [
        "tailscale0"
      ];
    };
  };

  system.stateVersion = "24.11"; 

  }

  # Tailscale keys
  # Create a secrets location for your tailscale auth keys.  Create a reusable key at
  # https://login.tailscale.com/admin/settings/authkeys, save it in a file, and put that file in your secrets location
  # If you're running an "Erase Your Darlings" setup, don't forget to persist your tailscale secrets location
  #environment.etc."tailscale".source = "/persist/etc/tailscale/";
 
 
  # source: https://docs.syncthing.net/users/firewall.html
