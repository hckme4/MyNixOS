# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  user="w00t";
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      <home-manager/nixos>
    ];

  # Bootloader
  systemd.sleep.extraConfig = "AllowSuspend=yes";
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelParams = [ "button.lid_init_state=open" "i915.force_probe=5917" ]; #i915.force_probe enables intel integrated gfx
    kernelModules = [ "iwlwifi" ];
  };

  #opengl
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  #nvidia drivers. uncomment as necessary.
  #nixpkgs.config.allowUnfreePredicate = pkg:
  #  builtins.elem (lib.getName pkg) [
  #    "nvidia-x11"
  #  ];
  #services.xserver.videoDrivers = ["nvidia"];
  #modesetting.enable = true;
  #open = false;
  #nvidiaSettings = true;
  #adjust this value to the specific nvidia driver needed!
  #package = config.boot.kernelPackages.nvidiaPackages.stable;
 
  networking = {
    hostName = "t480s";
    networkmanager = {
      enable = true;
      #further configure networkmanager here!
    };
  };

  # Set your time zone.
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

  # Enable the X11 windowing system.
  services = {
    xserver = {
      enable = true;
      displayManager = {
        lightdm.enable = true; #enable lightdm
        defaultSession = "none+openbox"; #enable openbox
        #restore my wallpaper
        sessionCommands = ''${pkgs.feh}/bin/feh --no-fehbg --bg-fill /etc/nixos/wallpaper.jpg'';
      };
      desktopManager.xfce.enable = true;
      windowManager.openbox.enable = true;
    };

    acpid = {
      enable = true;
    };
  };
  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound = {
    enable = true;
    mediaKeys.enable = true;
  };

  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;

  services = {
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
    }; 
    #media-session.enable = true;
    mpd = {
      enable = true;
      musicDirectory = "/home/${user}/Music";
      extraConfig = ''
        audio_output {
          type "pulse"
          name "MyMusic"
        }
      '';
    };
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  #default shell across users
  users.defaultUserShell = pkgs.zsh;

  #enable Mullvad VPN :)
  services.mullvad-vpn.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${user} = {
    isNormalUser = true;
    description = "w00t";
    extraGroups = [ "networkmanager" "wheel" "video" "audio" "networkmanager" "lp" "scanner" ];
    #initialPassword = "1234";
    shell = pkgs.zsh;
    
    #packages = with pkgs; [
    #  firefox
    #  thunderbird
    #];
  };

  nixpkgs = {
    config.allowUnfree = true;

    overlays = [
      (self: super: {
        discord = super.discord.overrideAttrs (
          _: { src = builtins.fetchTarball {
            url = "https://discord.com/api/download?platform=linux&format=tar.gz";
            sha256 = "0mr1az32rcfdnqh61jq7jil6ki1dpg7bdld88y2jjfl2bk14vq4s";
            #sha256 = "0000000000000000000000000000000000000000000000000000";
      }; }
      );
    })
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    tree
    vim
    vim-full
    wget
    firefox
    vlc
    libvlc
    mpv
    mpd
    steam
    steamcmd
    steam-run
    neofetch
    git
    htop
    obconf
    nerdfonts
    material-icons
    material-symbols
    material-design-icons
    polybar
    rofi
    i3lock-fancy
    virt-manager
    mpv
    ookla-speedtest
    p7zip
    killall
    keepassxc
    ranger
    pulsemixer
    ripgrep
    acpi
    gparted
    flameshot
    feh
    zsh
    picom
    discord
    codeblocksFull
    ghidra
    gimp-with-plugins
    simplescreenrecorder
    alacritty
    xfce.xfburn
    mate.atril
    prusa-slicer
    strawberry
    transmission-gtk
    mullvad-vpn
    libreoffice-qt
    hunspell
    gcc
    nasm
    gdb
    gnumake
    gcc-arm-embedded
    nmap
    burpsuite
    wireshark
    termshark
    sqlmap
    lynis
  ];

  #Set up Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; #open firewall for steam remote play
    dedicatedServer.openFirewall = true; #open firewall for source dedicated server
  };

  #Set up oh-my-zsh
  programs.zsh = {
    enable = true;
    ohMyZsh = {
      enable = true;
      theme = "darkblood";
      plugins = [
        "sudo"
        "git"
	"python"
	"systemd"
	"colorize"
	"cp"
	"compleat"
	"adb"
      ];
    };
  };

  # symlink openbox dotfiles in proper location
  system.userActivationScripts.linktosharedfolder.text = ''
    if [[ ! -h "$HOME/.config/openbox" ]]; then
      ln -s "/etc/nixos/openbox" "$HOME/.config/"
    fi
  '';

  fonts.fonts = with pkgs; [
    nerdfonts
  ]; 


  #home-manager config
  home-manager.users.${user} = { config, pkgs, ... }: {
    home = {
      packages = with pkgs; [neovim];
      stateVersion = "23.05";

      file = {
        ".config/alacritty/alacritty.yml".text = ''
          {"font":{"bold":{style":"Bold"}}}
        '';
        #".fehbg".source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/fehbg";
      };
    };

    programs.feh.enable = true;

    systemd = {
      user = {
        services = {
          feh = {
            Install.WantedBy = [ "graphical-session.target" ];
          };
          polybar = {
            Install.WantedBy = [ "graphical-session.target" ];
          };
        };
      };
    };

    gtk = {
      enable = true;
      theme = {
        name = "Materia-dark";
        package = pkgs.materia-theme;
	#name = "gtk-theme-framework";
	#package = pkgs.gruvterial-theme;
      };
    };

    services = {
      polybar = {
        enable = true;
        package = pkgs.polybarFull;
        script = ''
          polybar centerbar &
          polybar leftbar &
          polybar rightbar &
        '';

        config = {
          "settings" = {
          "throttle-ms" = "50";
          "throttle-limit" = "5";
        };

          "colors" = {
            "black" = "#3B4252";
            "red" = "#BF616A";
            "green" = "#A3BE8C";
            "yellow" = "#EBCB8B";
            "blue" = "#5E81AC";
            "magenta" = "#B48EAD";
            "cyan" = "#88C0D0";
            "white" = "#E5E9F0";
            "black1" = "#4C566A";
            "red1" = "#D08770";
            "green1" = "#A3BE8C";
            "yellow1" = "#EBCB8B";
            "blue1" = "#81A1C1";
            "magenta1" = "#B48EAD";
            "cyan1" = "#8FBCBB";
            "white1" = "#ECEFF4";
            "background" = "#2E3440";
            "foreground" = "#D8DEE9";
            "ctransp" = "#00FFFF";
          };

          "global/wm" = {
            "margin-top" = "-3";
            "margin-bottom" = "-3";
          };

          "section/base" = {
            "top" = "true";
            "padding-left" = "0";
            "spacing" = "0";
            "padding-right" = "0";
            "module-margin-left" = "0";
            "module-margin-right" = "0";
            "module-padding-left" = "0";
            "module-padding-right" = "0";
            "border-top-size" = "3";
            "border-left-size" = "3";
            "border-right-size" = "3";
            "border-bottom-size" = "3 ";
            "foreground" = "\${colors.foreground}";
            "background" = "\${colors.background}";
            "border-top-color" = "\${colors.black1}";
            "border-bottom-color" = "\${colors.black1}";
            "border-left-color" = "\${colors.black1}";
            "border-right-color" = "\${colors.black1}";
            "font-0" = "JetBrains Mono:size=12;2";
            "font-1" = "JetBrains Mono:size=12;2";
            "font-2" = "Font Awesome 6 Free Solid:size=12;2";
          };
          "bar/leftbar" = {
            "inherit" = "section/base";
            # Position
            "offset-x" = "10";
            "offset-y" = "7";
            # Size
            "width" = "150";
            "height" = "25";
            # Modules
            "modules-left" = "xworkspaces";
          };
          "module/xworkspaces" = {
            "type" = "internal/xworkspaces";
            "label-active" = "%name%";
            "label-active-padding" = "1";
            "label-active-font" = "1";
            "label-active-foreground" = "\${colors.black}";
            "label-active-background" = "\${colors.blue1}";
            "label-occupied" = "%index%";
            "label-occupied-padding" = "1";
            "label-occupied-font" = "1";
            "label-urgent" = "%index%";
            "label-urgent-padding" = "1";
            "label-urgent-background" = "\${colors.red}";
            "label-urgent-foreground" = "\${colors.red1}";
            "label-urgent-font" = "1";
            "label-empty" = "%name%";
            "label-empty-padding" = "1";
            "label-empty-font" = "1";
            "label-empty-foreground" = "\${colors.black1}";
            "label-empty-background" = "\${colors.black}";
            #Icon for non indexed WS
            "ws-icon-default" = "○";
          };
          "bar/centerbar" = {
            "inherit" = "section/base";
            # Position
            "offset-x" = "50%:-175";
            "offset-y" = "7";
            # Size;
            "width" = "350";
            "height" = "20";
            # Modules
            "modules-center" = "mpd";
          };
          "bar/rightbar" = {
            "inherit" = "section/base";
            # Position,
              "offset-x" = "100%:-293";
            "offset-y" = "7";
            # Size
            "width" = "283";
            "height" = "20";
            # Modules
            "modules-right" = "xkeyboard cpu memory pulseaudio date";
          };
          "module/date" = {
            "type" = "internal/date";
            "interval" = "1";
            "format" = "<label>";
            "format-padding" = "1";
            "format-foreground" = "\${colors.yellow}";
            "label" = " %date% %time%";
              "time" = "%H:%M";
            "date-alt" = "%A ";
            "date" = "%d";
          };
          "module/mpd" = {
            "type" = "internal/mpd";
            # Host where mpd is running (either ip or domain name)
            # Can also be the full path to a unix socket where mpd is running.
            "host" = "localhost";
            "port" = "6600";
            "format-foreground" = "\${colors.blue1}";
            "label-song" = "%artist% - %title%";
            "format-online" = "<label-song>";
          };
          "module/pulseaudio" = {
            "type" = "internal/pulseaudio";
            "format-muted-background" = "\${colors.red}";
              "format-volume-foreground" = "\${colors.green}";
            "format-volume" = "<ramp-volume> <label-volume>";
            "format-muted" = "<label-muted>";
            "format-volume-padding" = "1";
            "format-muted-padding" = "1";
            "label-muted" = "MUTED";
            "ramp-volume-0" = "";
            "ramp-volume-1" = "";
            "ramp-volume-2" = "";
          };
          "module/memory" = {
            "type" = "internal/memory";
            # Seconds to sleep between updates
            # Default: 1
            "interval" = "1";
            "format" = "<label>";
            "label" = " %percentage_used%%";
            "format-foreground" = "\${colors.red1}";
            "format-padding" = "1";
          };
          "module/cpu" = {
            "type" = "internal/cpu";
            # Seconds to sleep between updates
            # Default: 1
            "interval" = "1";
            "label" = " %percentage%%";
            "format-foreground" = "\${colors.magenta}";
            "format-padding" = "1";
          };
          "module/xkeyboard" = {
            "type" = "internal/xkeyboard";
            "blacklist-0" = "num lock";
            "label-layout" = "%layout%";
            "format-foreground" = "\${colors.cyan1}";
          };
        };
      };

      picom = {
        enable = true;
        activeOpacity = 1.0;
        inactiveOpacity = 0.9;
        backend = "glx";
        fade = true;
        fadeDelta = 5;
        opacityRules = [ "100:name *= 'i3lock'" ];
        shadow = true;
        shadowOpacity = 0.75;
      };
    };

    programs.rofi = {
      enable = true;
      terminal = "${pkgs.alacritty}/bin/alacritty";
      theme = /etc/nixos/arthur.rasi;
    };
  };

  #set up auto-upgrading
  system.autoUpgrade = {
    enable = true;
    channel = "https://nixos.org/channels/nixos-unstable";
  };

  #auto clean generations of configs
  nix = {
    settings.auto-optimise-store = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
