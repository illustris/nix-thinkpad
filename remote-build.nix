{ config, lib, pkgs, ... }:

{
	nix.buildMachines = [
		{
			hostName = "192.168.1.27";
			system = "x86_64-linux";
			maxJobs = 16;
			sshKey = "/root/.ssh/id_rsa";
			supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" ];
			sshUser = "root";
			speedFactor = 2;
		}
		#{
		#	#hostName = "192.168.1.26";
		#	hostName = "192.168.2.2";
		#	system = "x86_64-linux";
		#	maxJobs = 127;
		#	sshKey = "/root/.ssh/id_rsa";
		#	#supportedFeatures = [ ];
		#	supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" ];
		#	sshUser = "root";
		#	speedFactor = 8;
		#}
	];

	# Useful if builder has a faster internet connection
	nix.extraOptions = ''
		builders-use-substitutes = true
	'';
	# Allow untrusted users to trigger distributed builds
	nix.distributedBuilds = true;
}
