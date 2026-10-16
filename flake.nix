{
  description = "NixOS with niri + Noctalia v5";

  nixConfig = {
    extra-substituters = [ "https://noctalia.cachix.org" ];
    extra-trusted-public-keys = [
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # "cachix" branch = latest commit that already has prebuilt binaries
    noctalia.url = "github:noctalia-dev/noctalia/cachix";

    # Spicetify 
    spicetify-nix = {
    	url = "github:Gerg-L/spicetify-nix";
	inputs.nixpkgs.follows = "nixpkgs";
    };

    # Sddm
    silentSDDM = {
    	url = "github:uiriansan/SilentSDDM";
	inputs.nixpkgs.follows = "nixpkgs";
  	};
  };

  outputs = { self, nixpkgs, spicetify-nix, ... }@inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [ 
         ./configuration.nix
 	];
    };
    nixosConfigurations.iso = nixpkgs.lib.nixosSystem {
  	system = "x86_64-linux";
  	specialArgs = { inherit inputs; };
  	modules = [
    		"${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
    		./configuration.nix
    	({ lib, ... }: {
      		boot.loader.systemd-boot.enable = lib.mkForce false;
      		boot.loader.grub.enable = lib.mkForce false;
      		boot.loader.efi.canTouchEfiVariables = lib.mkForce false;
      		isoImage.squashfsCompression = "zstd -Xcompression-level 6"; # faster build
    		})
  	];
	};
  };
}
