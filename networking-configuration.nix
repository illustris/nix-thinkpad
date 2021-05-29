{ config, pkgs, ... }:

{
	imports = [
		./secrets/zerotier
	];
	networking = {
		hostName = "illustris-thinkpad";
		hostId = "d25c46cd"; # needed by ZFS, not networking
		networkmanager.enable = true;
		firewall.enable = true;
	};
}
