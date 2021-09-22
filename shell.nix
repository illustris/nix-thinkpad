{
	sources ? import ./nix/sources.nix,
	pkgs ? import sources.nixpkgs {}
}:

pkgs.mkShell {
	buildInputs = with pkgs; [
		niv
	];
	shellHook = ''
		export NIX_PATH=nixpkgs=${pkgs.path}:nixos-config=/etc/nixos/configuration.nix
	'';
}
