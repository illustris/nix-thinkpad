{
	sources ? import ./nix/sources.nix,
	pkgs ? import sources.nixpkgs {}
}:

pkgs.mkShell {
	buildInputs = with pkgs; [
		niv
	];
	shellHook = ''
		export nixpkgs=${sources.nixpkgs.outPath}
		export NIX_PATH=nixpkgs=${sources.nixpkgs.outPath}:nixos-config=/etc/nixos/configuration.nix
	'';
}
