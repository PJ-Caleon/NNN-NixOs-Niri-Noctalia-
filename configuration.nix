{ config, pkgs, inputs, lib, ... }:

{
  imports = [ 
  	./hardware-configuration.nix
	inputs.spicetify-nix.nixosModules.default
	inputs.silentSDDM.nixosModules.default
	];

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    extra-substituters = [ "https://noctalia.cachix.org" ];
    extra-trusted-public-keys = [
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];
  };

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Singapore";

  i18n.defaultLocale = "en_SG.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_SG.UTF-8";
    LC_IDENTIFICATION = "en_SG.UTF-8";
    LC_MEASUREMENT = "en_SG.UTF-8";
    LC_MONETARY = "en_SG.UTF-8";
    LC_NAME = "en_SG.UTF-8";
    LC_NUMERIC = "en_SG.UTF-8";
    LC_PAPER = "en_SG.UTF-8";
    LC_TELEPHONE = "en_SG.UTF-8";
    LC_TIME = "en_SG.UTF-8";
  };

  # Login screen + XFCE kept as a fallback session while niri gets set up.
  # Once niri works, you can delete the desktopManager line.
  services.xserver.enable = true;
  services.xserver.desktopManager.xfce.enable = true;
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.printing.enable = true;

  # Nvidia
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    open = false; 
    package = config.boot.kernelPackages.nvidiaPackages.legacy_580;

    prime = {
      offload.enable = true;
      offload.enableOffloadCmd = true; 
      intelBusId  = "PCI:0:2:0";  
      nvidiaBusId = "PCI:1:0:0";  
    };
  };

  # Sddm
  services.displayManager = {
  	sddm = {
		enable = true;
		wayland.enable = lib.mkForce true;
	};
	autoLogin = {
		enable = false;
		user = "exfemboy";
		};
	};

  # Sound
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Bluetooth
hardware.bluetooth = {
  enable = true;
  powerOnBoot = true;
  settings.General.Experimental = true;
};

# Temporary GUI + pairing agent
services.blueman.enable = true;

  users.users."exfemboy" = {
    isNormalUser = true;
    shell = pkgs.fish;
    description = "exfemboy";
    extraGroups = [ "networkmanager" "wheel" "dialout" "docker" ];
  };

  nixpkgs.config.allowUnfree = true;

  # fonts
  fonts.packages = with pkgs; [
	nerd-fonts.fira-mono
	redhat-official-fonts
  ];

  # Steam Setup
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    };

  # Programs
  programs.niri.enable = true;
  programs.firefox.enable = true;
  programs.fish.enable = true;
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
};
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    };
  programs.spicetify = let
  	spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
	in {
  		enable = true;
		theme = spicePkgs.themes.text;
		colorScheme = "Dracula";
		enabledExtensions = with spicePkgs.extensions; [
			adblock
			hidePodcasts
			shuffle
			volumePercentage
		];
	};
  programs.silentSDDM = {
  	enable = true;
	theme = "rei";
	};

    # Extra Services
    services.flatpak.enable = true;

  environment.systemPackages = with pkgs; [

    # CLI Commands
    ani-cli
    yazi 
    fish 
    fastfetch
    zoxide
    unzip
    kitty
    starship
    flatpak
    neovim
    ripgrep
    gcc
    fd
    btop

    # Coding Dev
    gcc-arm-embedded
    gdb
    openocd
    stlink
    gnumake
    cmake
    ninja
    git
    picocom
    cppcheck
    renode
    qemu
    (python3.withPackages (ps: with ps; [ pyserial matplotlib scipy pytest ]))

    # Applications
    thunderbird
    osu-lazer
    obsidian
    flameshot
    grim
    steam
    localsend
    (discord.override { withVencord = true;})

    # Misc
    xwayland-satellite
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
    swayidle
    quickshell
    (writeShellScriptBin "rei-lock" ''
    export QML2_IMPORT_PATH="${qt6.qtmultimedia}/${qt6.qtbase.qtQmlPrefix}:$QML2_IMPORT_PATH"
    export QML_IMPORT_PATH="$QML2_IMPORT_PATH"
    export QT_PLUGIN_PATH="${qt6.qtmultimedia}/${qt6.qtbase.qtPluginPrefix}:$QT_PLUGIN_PATH"
    exec ${quickshell}/bin/quickshell -p /home/exfemboy/.config/rei-lock/shell.qml "$@"
    '')
  ];
  
  # SDDM and LockScreen Face 
  security.pam.services.rei-lock = {};
  environment.etc."sddm-faces/exfemboy.face.icon".source = ./face.png;
  services.displayManager.sddm.settings.Theme.FacesDir = "/etc/sddm-faces";

  # ST-Link and OpenOCD Udev rules
  services.udev.packages = [ pkgs.stlink pkgs.openocd ];
  virtualisation.docker.enable = true; 

  environment.variables.EDITOR = "nvim";

  system.stateVersion = "26.05";
}

