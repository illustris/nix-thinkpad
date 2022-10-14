{ config, pkgs, ... }:

{
	networking = {
		hostName = "illustris-thinkpad";
		hostId = "d25c46cd"; # needed by ZFS, not networking
		networkmanager.enable = true;
		firewall.enable = true;
	};
	services.zerotierone.enable = true;
}
