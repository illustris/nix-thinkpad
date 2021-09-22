{ config, pkgs, lib, ... }:

let sources = import ./nix/sources.nix; in
{
	imports = [
		# Include the results of the hardware scan.
		./hardware-configuration.nix
		./desktop-configuration.nix
		./networking-configuration.nix
	];

	nixpkgs.overlays = [
		#(import ./srcbuild.nix)
	];

	# use if doing srcbuild
	#boot.kernelPackages = pkgs.linuxPackagesFor (
	#	pkgs.linux.override {
	#		stdenv = pkgs.kernelStdenv;
	#	}
	#);

	# Use the systemd-boot EFI boot loader.
	boot = {
		binfmt.emulatedSystems = [ "aarch64-linux" ];
		kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
		loader = {
			systemd-boot.enable = true;
			efi.canTouchEfiVariables = true;
		};
	};

	hardware.bluetooth = {
		enable = true;
		settings = {
			General = {
				Enable = "Source,Sink,Media,Socket";
			};
		};
	};

	time.timeZone = "Asia/Kolkata";

	security.sudo.wheelNeedsPassword = false;

	users.users = {
		illustris = {
			isNormalUser = true;
			extraGroups = [ "wheel" "kvm" "docker" "libvirtd" "adbusers" "audio" "vboxusers" "networkmanager" "dialout" ];
			openssh.authorizedKeys.keyFiles = [ ./secrets/ssh_pubkeys ];
		};
		root.openssh.authorizedKeys.keyFiles = [ ./secrets/ssh_pubkeys ];
	};

	# List packages installed in system profile. To search, run:
	# $ nix search wget
	environment = {
		systemPackages = with pkgs; [
			asciinema
			bind
			binutils-unwrapped
			bmon
			cmatrix # More useful than you might think
			#ec2_api_tools
			ethtool
			expect
			fatrace
			file
			gdb
			git
			gnumake
			#graphviz
			htop
			#imagemagick
			iotop
			iperf
			jq
			killall
			latencytop
			linuxPackages.perf
			lsof
			mosh
			ncdu
			neofetch
			networkmanager
			nfs-utils
			nix-du
			nix-prefetch-git
			nix-tree
			nnn
			openvpn
			p7zip
			pciutils
			powertop
			pv
			python3
			pythonPackages.percol
			ranger
			screen
			sshfs
			surf
			sysstat
			tmate
			tmux
			tree
			unzip
			usbutils
			valgrind
			wget
			youtube-dl
			(cscope.override{emacsSupport = false;})
			#(emacs.override{withGTK3 = false; withX = false;})
			(pass.withExtensions (exts: [ exts.pass-otp ]))
			((pkgs.callPackage ./packages/passcol) {})
			(writeScriptBin "vpnpass" (builtins.readFile ./scripts/vpnpass))
		];
		etc = {
			openvpn.source = "${pkgs.update-resolv-conf}/libexec/openvpn";
			nixpkgs.source = sources.nixpkgs;
		};
	};

	nix = {
		autoOptimiseStore = true;
		nixPath = [
			"nixpkgs=/etc/nixpkgs"
			"nixos-config=/etc/nixos/configuration.nix"
		];
		#package = pkgs.nixUnstable;
		#extraOptions = ''
		#	experimental-features = nix-command flakes
		#'';
	};

	programs = {
		adb.enable = true;
		bash = {
			interactiveShellInit = ''
				export HISTSIZE=-1 HISTFILESIZE=-1 HISTCONTROL=ignoreboth:erasedups
				shopt -s histappend
				export PROMPT_COMMAND="history -a;$PROMPT_COMMAND"
				export NIX_PATH=nixpkgs=/etc/nixpkgs:nixos-config=/etc/nixos/configuration.nix
			'';
			shellAliases = {
				genpass = "cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 20 | head -n 2";
				nt = "nix-shell /etc/nixos/shell.nix --run \"sudo nixos-rebuild test\"";
				ns = "nix-shell /etc/nixos/shell.nix --run \"sudo nixos-rebuild switch\"";
				grep = "grep --color";
			};
			promptInit = ''
				if [ "$TERM" != "dumb" -o -n "$INSIDE_EMACS" ]; then
					PROMPT_COLOR="1;31m"
					let $UID && PROMPT_COLOR="1;36m"
					PS1="\[\033[$PROMPT_COLOR\][\[\e]0;\u@\h: \w\a\]\u@\h:\w]\\$\[\033[0m\] "
				fi
			'';
		};
		gnupg.agent = {
			enable = true;
			pinentryFlavor = "curses";
		};
		mosh.enable = true;
		mtr.enable = true;
		ssh.startAgent = true;
	};

	services = {
		blueman.enable = true;

		# Collect system metrics using prometheus and node exporter
		prometheus = {
			enable = false;
			exporters = {
				node = {
					enable = true;
					enabledCollectors = [ "systemd" ];
				};
			};
			scrapeConfigs = [
				{
					job_name = "node_exporter";
					scrape_interval = "10s";
					static_configs = [
						{
							targets = [ "localhost:${toString config.services.prometheus.exporters.node.port}" ];
						}
					];
				}
			];
		};

		grafana = {
			enable = true;
			security.adminPasswordFile = ./secrets/grafana_admin;
			provision = {
				enable = true;
				datasources = [
					{
						url = "http://localhost:9090";
						name = "Prometheus";
						type = "prometheus";
						isDefault = true;
					}
				];
			};
		};

		# Enable the OpenSSH daemon.
		openssh = {
			enable = true;
			forwardX11 = true;
		};

		# till parsec is packaged
		flatpak.enable = true;

	};


	# forgot why I needed this
	xdg.portal.enable = true;

	virtualisation = {
		docker = {
			enable = true;
			storageDriver = "zfs"; # todo: change to overlay2
		};
		libvirtd.enable = true;
	};

	systemd = {
		# Disable autostart
		services.grafana.wantedBy = lib.mkForce [];
		services.docker.wantedBy = lib.mkForce [];
	};

	# This value determines the NixOS release from which the default
	# settings for stateful data, like file locations and database versions
	# on your system were taken. It‘s perfectly fine and recommended to leave
	# this value at the release version of the first install of this system.
	# Before changing this value read the documentation for this option
	# (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
	system.stateVersion = "20.09"; # Did you read the comment?

}

