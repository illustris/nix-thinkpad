{ lib, ... }:
with lib;
{
	nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
		"displaylink"
		"google-chrome"
		"steam"
		"steam-original"
		"zerotierone"
	];
}
