{
	inputs = {
		# for https://github.com/NixOS/nixpkgs/pull/239883
		# revert to nixos-unstable once it propagates
		nixpkgs.url = github:nixos/nixpkgs/nixos-unstable-small;
		sops-nix = {
			url = github:Mic92/sops-nix;
			inputs.nixpkgs.follows = "nixpkgs";
			inputs.nixpkgs-stable.follows = "nixpkgs";
		};
		home-manager = {
			url = "github:nix-community/home-manager";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};

	outputs = { self, nixpkgs, sops-nix, home-manager, ... }: let
		supportedSystems = [ "x86_64-linux" ];
		forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
	in {
		nixosConfigurations = {
			illustris-thinkpad = nixpkgs.lib.nixosSystem {
				system = "x86_64-linux";

				modules = [
					./configuration.nix
					sops-nix.nixosModules.sops
					{
						nix.registry.nixpkgs.flake = nixpkgs;
						environment.etc.flake.source = self;
					}
					home-manager.nixosModule
				];
			};
		};
		devShells = forAllSystems (system: {
			default = with (import nixpkgs {inherit system;}); mkShell {
				buildInputs = with sops-nix.packages.${system}; [
					sops
					sops-init-gpg-key
					ssh-to-pgp
				];
				shellHook = ''
					  export PS1=">$PS1"
					  export NIX_PATH=nixpkgs=${path}:nixos-config=/etc/nixos/configuration.nix
				'';
			};
		});
	};
}
