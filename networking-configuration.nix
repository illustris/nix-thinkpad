{ config, pkgs, ... }:

{
	networking = {
		hostName = "illustris-thinkpad";
		hostId = "d25c46cd"; # needed by ZFS, not networking
		networkmanager.enable = true;
		firewall = {
			# leave an arbitrary port open for ad-hoc use
			allowedTCPPorts = [ 1337 ];
			allowedUDPPorts = [ 1337 ];
			enable = true;
		};
	};
	services.zerotierone.enable = true;
}
