{
	inputs = {
		nixpkgs.url = github:nixos/nixpkgs/nixos-unstable;
		sops-nix = {
			url = github:Mic92/sops-nix;
			inputs.nixpkgs.follows = "nixpkgs";
			inputs.nixpkgs-22_05.follows = "nixpkgs";
		};
	};

	outputs = { self, nixpkgs, sops-nix, ... }: let
		supportedSystems = [ "x86_64-linux" ];
		forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
	in {
		nixosConfigurations = {
			illustris-thinkpad = nixpkgs.lib.nixosSystem {
				system = "x86_64-linux";
				modules = [
					./configuration.nix
					sops-nix.nixosModules.sops
					{nix.registry.np.flake = nixpkgs;}
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
