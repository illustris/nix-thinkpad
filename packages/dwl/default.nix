{ pkgs, lib, ... }:

pkgs.dwl.overrideAttrs (old: {
	postInstall = ''
		mkdir -p $out/share/wayland-sessions
		cp ${
			pkgs.substituteAll {
				src = ./dwl.desktop;
				bar = "${pkgs.somebar}/bin/somebar";
			}
		} $out/share/wayland-sessions/dwl.desktop
	'';
	passthru.providedSessions = [ "dwl" ];
	src = /home/illustris/src/dwl;
})
