{ config, pkgs, lib, ... }: #inputs, outputs, osConfig,

{
  imports = [
      ./hardware-configuration.nix
      <home-manager/nixos>
      <nixos-hardware/lenovo/thinkpad/p14s>
      #<nixos-hardware/lenovo/thinkpad/p14s/intel/gen3> # Leave this ere so you know how to put future lines in for this
      #<nixos-hardware/dell/xps/13-9333>
    ];

  boot.kernel.sysctl = {
    "net.ipv4.ip_default_ttl" = 65;
  };


  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 1;
      };
    };
    #kernel = {
    #  sysctl = {
    #    net = {
    #      ipv4 = {
    #        ip_default_ttl = 65;
    #      };
    #    };
    #  };
    #};
    #kernelModules = [ 
    #];
    kernelPackages = pkgs.linuxPackages_6_12;#latest; # This is the Kernel of Linux
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
      kernelModules = [
        #cifs
        #nfs
        #bcachefs
      ];
    };
  };

  fileSystems."/mnt/shares" = {
    device = "10.5.0.46:/mnt/blerg/nfs-shares";
    fsType = "nfs";
    options = [
      "nfsvers=4.2"
      "x-systemd.automount"
      "noauto"
      "x-systemd.idle-timeout=600"
      "noatime"
      ];
    };

  fileSystems."/mnt/smbshare" = {
    device = "//10.5.0.46/blerg";  # Replace with your SMB server and share
    fsType = "cifs";
    options = [
      "credentials=/etc/nixos/secrets/smb-credentials"
      "rw"
      "vers=3.0"
      "uid=1000"                      # Adjust to your user
      "gid=100"
      "x-systemd.automount"
      "noauto"
      "x-systemd.idle-timeout=600"
      "noatime"
      ];
    };

  nix = {
    settings = {
      experimental-features = [ 
        "nix-command"
        "flakes"
      ];
    };
  };

  services = {
    gvfs = {
      enable = true;
    };
    udisks2 = {
      enable = true;
    };
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
      drivers = with pkgs; [
        brlaser
        brgenml1lpr
        brgenml1cupswrapper
        cups-brother-hll3230cdw
      ];
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
        #"nvidia"
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
      #domains = [ 
      #  "home.lan"
      #  "dreamsword.win"
      #  "local.dreamsword.win"
      #  "tail13623.ts.net"
      #];
      #fallbackDns = [
      #  "100.106.71.44"
      #  "10.5.0.2"
      #  "100.100.100.100"
      #];
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
    udev = {
      extraRules = ''
        SUBSYSTEM=="usbmon", GROUP="wireshark", MODE="0640"
      '';
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
        #nvidia-vaapi-driver
      ];
    };
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      #powerManagement.finegrained = true;
      open = false;
      nvidiaSettings = true;
      #nvidiaPersistenced = true;
      #package = config.boot.kernelPackages.nvidiaPackages_550;
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
    rtl-sdr = {
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
      plugdev = {
        members = [
          "akmzero"
        ];
      };
      dialout = { #For Chrip Programming
        members = [
          "akmzero"
        ];
      };
      wireshark = {
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
          git = {
            enable = true;
            userName = "akmzero";
            userEmail = "akmzero@gmail.com";
            extraConfig = {
              init.defaultBranch = "main";
              pull.rebase = false;
              color.ui = "auto";
            };
          };
          #home.file.".ssh/config".text = ''
          #  Host github.com
          #    HostName github.com
          #    User git
          #    IdentityFile ~/.ssh/id_ed25519
          #    IdentitiesOnly yes
          #'';
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
              #"pnidmkljnhbjfffciajlcpeldoljnidn" # Linkwarden
              "kgcjekpmcjjogibpjebkhaanilehneje" # Hoarder/Karakeep
              "aapbdbdomjkkjkaonfhkkikfgjllcleb" # Google Translate
            ];
            #overrideAttrs = {
            #  braveAutoTranslateStudy = enabled;
            #};
            #commandLineArgs = [
            #  "--enable-features=BraveEnableAutoTranslate"
            #];
          };
          firefox = {
            package = pkgs.librewolf;
            enable = true;
            settings = {
              "xpinstall.signatures.required" = false;
              "extensions.autoDisableScopes" = 0;
              "extensions.enabledScopes" = 15;
            };
            policies = {
                DisableTelemtry = true;
                DisableFirefoxStudies = true;
                Prefences = {
                  "cookiebanners.service.mode.privateBrowsing" = 2; # Block cookie banners in private browsing
                  "cookiebanners.service.mode" = 2; # Block cookie banners
                  "privacy.donottrackheader.enabled" = true;
                  "privacy.fingerprintingProtection" = true;
                  "privacy.resistFingerprinting" = true;
                  "privacy.trackingprotection.emailtracking.enabled" = true;
                  "privacy.trackingprotection.enabled" = true;
                  "privacy.trackingprotection.fingerprinting.enabled" = true;
                  "privacy.trackingprotection.socialtracking.enabled" = true;
                };
              };
            ExtensionSettings = { 
               "changedetection@local" = { # This is a local extension, Firefox does not have a extension.  This is the Chrome extension with changes made to the manifest.json
                  installation_mode = "development";
                  install_url = "file:///home/akmzero/.local/librewolf-extensions/changedetection";
                };
                "simplelogin.firefox@addons.mozilla.org" = {
                  installation_mode = "force_installed";
                  install_url = "https://addons.mozilla.org/firefox/downloads/latest/simplelogin/addon-379388-latest.xpi";
                };
                "bitwarden.firefox@addons.mozilla.org" = {
                  installation_mode = "force_installed";
                  install_url = "https://addons.mozilla.org/firefox/downloads/file/4493940/bitwarden_password_manager-2025.5.0.xpi";
                };
                "privacy.firefox@addons.mozilla.org" = {
                  installation_mode = "force_installed";
                  install_url = "https://addons.mozilla.org/firefox/downloads/latest/pay-by-privacy/latest.xpi";
                };
                "{101d614d-9577-4554-bc53-3b6f1899fb99}" = { # TWP - Translate Web Pages - https://addons.mozilla.org/en-US/firefox/addon/traduzir-paginas-web/
                  installation_mode = "force_installed";
                  install_url = "https://addons.mozilla.org/firefox/downloads/latest/traduzir-paginas-web/latest.xpi";
                };
                "karakeep.firefox@addons.mozilla.org" = {
                  installation_mode = "force_installed";
                  install_url = "https://addons.mozilla.org/firefox/downloads/file/4477863/karakeep-1.2.5.xpi";
                };
              };
            };
          vscode = {
            #package = pkgs.vscode;
            enable = true;
            extensions = with pkgs.vscode-extensions; [
              #continue.continue
              ms-azuretools.vscode-docker
              ms-vscode-remote.remote-ssh
              ms-vscode-remote.remote-containers
              jnoortheen.nix-ide
              ms-python.vscode-pylance
              ms-python.python
              ms-python.debugpy
              ms-vscode-remote.remote-ssh-edit
              #ms-vscode-remote.vscode-remote-extensionpack
              tailscale.vscode-tailscale
              ms-vscode-remote.remote-wsl
            ];
          };
          #ssh = {
          #  enable = true;
          #  matchBlocks = {
          #    "github.com" = {
          #      identityFile = "~/.ssh/id_ed25519";
          #      user = "git";
          #    };
          #  };
          #};
        };
        home = {
          stateVersion = "24.11";
          packages = with pkgs; [
            putty
            obsidian
            syncthing
            brave
            lutris
            ferdium
            fuse
            #remmina
            #vlc
            #caffeine-ng
            signal-desktop
            #moonlight-qt
            #bambu-studio
            vscode
            #chirp
            #vscodium
            bitwarden
            wireshark
            #rtl-sdr
            #spektrum
            #sdr++
            gqrx
            orca-slicer
            #ssh
            librewolf
            chromium
          ];
        };
      };
    };
  };

  #programs = {
  #  wireshark = {
  #    enable = true;
  #    package = pkgs.wireshark;
  #  };
  #};

  nixpkgs = {
    config = {
      allowUnfree = true;
      permittedInsecurePackages = [
        #"electron-25.9.0" # For Obsidian.
        "electron-32.1.2" # For Ferdium
        "electron-33.4.11" # For Obsidian.
      ];
    };
  };

  # Global Packages
  environment = {
    systemPackages = with pkgs; [
      git
      wget
      curl
      #tmux
      nmap
      pciutils
      trayscale
      tailscale
      ##htop-vim
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
      #aria 
      #p7zip 
      #ventoy-full zero
      openocd
      #where
      dig
      kdePackages.discover # Optional: Install if you use Flatpak or fwupd firmware update sevice
      kdePackages.kcalc # Calculator
    ];
    sessionVariables = { 
      LIBVA_DRIVER_NAME = [
        "iHD" # Force intel-media-driver: https://nixos.wiki/wiki/Accelerated_Video_Playback
      ];
      NIXOS_OZONE_WL = "1";
    };
  };

  networking = {
    #interfaces = {
    #  #wlp0s20f3 = {
    #  #  useDHCP = true;
    #  };
    #};
    nameservers = [ "10.5.0.2" "100.106.71.44" "100.100.100.100" ];
    hostName = "nomad"; # Defines Hostname
    #domain = [ "home.lan" ];
    useNetworkd = true;
    useDHCP = false;
    networkmanager = {
      enable = true;
      #dns = "none";
      #wifi {
      #  macAddress = "stable";
      #};
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
      extraCommands = ''
        #SMB
        iptables -t raw -A OUTPUT -p udp -m udp --dport 137 -j CT --helper netbios-ns
        #Accept incoming multicast packets (for discovery or multicast services)
        iptables -I INPUT -m pkttype --pkt-type multicast -j ACCEPT
        iptables -A INPUT -m pkttype --pkt-type multicast -j ACCEPT
      '';
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
