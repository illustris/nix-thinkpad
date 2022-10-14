{ config, pkgs, lib, ... }:

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
			systemd-boot = {
				enable = true;
				configurationLimit = 8;
			};
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

	users.users = let
		keys = pkgs.fetchurl {
			url = "https://github.com/illustris.keys";
			hash = "sha256-Ue0orizAxflXASj3C4+UJ6mcJUmzeSiipls+7D2CKqE=";
		};
	in {
		illustris = {
			isNormalUser = true;
			extraGroups = [ "wheel" "kvm" "docker" "libvirtd" "adbusers" "audio" "vboxusers" "networkmanager" "dialout" "plugdev" ];
			openssh.authorizedKeys.keyFiles = [ keys ];
		};
		root.openssh.authorizedKeys.keyFiles = [ keys ];
	};

	documentation.dev.enable = true;

	# List packages installed in system profile. To search, run:
	# $ nix search wget
	environment = {
		systemPackages = with pkgs; [
			asciinema
			bind
			binutils-unwrapped
			bmon
			btop
			cmatrix # More useful than you might think
			emacs
			ethtool
			expect
			fatrace
			file
			gdb
			git
			gnumake
			gdu
			htop
			hydra-check
			iotop
			iperf
			jq
			killall
			latencytop
			linuxPackages.perf
			lsof
			man-pages
			man-pages-posix
			minicom
			mosh
			ncdu
			neofetch
			networkmanager
			nfs-utils
			nix-du
			nix-index
			nix-prefetch-git
			nix-top
			nix-tree
			nixos-shell
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
			ytfzf
			yubico-piv-tool
			(cscope.override{emacsSupport = false;})
			(pass.withExtensions (exts: [ exts.pass-otp ]))
			((pkgs.callPackage ./packages/passcol) {})
			(writeScriptBin "vpnpass" (builtins.readFile ./scripts/vpnpass))
		];
		etc = {
			openvpn.source = "${pkgs.update-resolv-conf}/libexec/openvpn";
			nixpkgs.source = pkgs.path;
		};
	};

	nix = {
		nixPath = [
			"nixpkgs=${pkgs.path}"
			"nixos-config=/etc/nixos/configuration.nix"
		];
		#package = pkgs.nixUnstable;
		extraOptions = ''
			experimental-features = nix-command flakes
		'';
		settings = {
			trusted-users = [ "root" "illustris" ];
			auto-optimise-store = true;
		};
	};

	programs = {
		adb.enable = true;
		bash = {
			interactiveShellInit = ''
				export HISTSIZE=-1 HISTFILESIZE=-1 HISTCONTROL=ignoreboth:erasedups
				shopt -s histappend
				export PROMPT_COMMAND="history -a;$PROMPT_COMMAND"
			'';
			shellAliases = {
				genpass = "cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 20 | head -n 2";
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
			enable = true;
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
			security.adminPasswordFile = config.sops.secrets.grafana_admin_pass.path;
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

		udev.extraRules = ''
			SUBSYSTEM=="tty", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6015", \
				MODE="664", GROUP="dialout"
			# this is for ujprog libusb access
			ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6015", \
				GROUP="dialout", MODE="666"
		'' + ''
			# Rules for the Saleae Logic analyzer to allow to run the programs a normal user
			# being part of the plugdev group. Simply copy the file to /etc/udev/rules.d/
			# and plug the device

			BUS!="usb", ACTION!="add", SUBSYSTEM!=="usb_device", GOTO="saleae_logic_rules_end"

			# Saleae Logic analyzer (USB Based)
			# Bus 006 Device 006: ID 0925:3881 Lakeview Research
			# Bus 001 Device 009: ID 21a9:1004 Product: Logic S/16, Manufacturer: Saleae LLC

			ATTR{idVendor}=="0925", ATTR{idProduct}=="3881", MODE="664", GROUP="plugdev"
			ATTR{idVendor}=="21a9", ATTR{idProduct}=="1004", MODE="664", GROUP="plugdev"

			LABEL="saleae_logic_rules_end"
		'' + ''
			# this udev file should be used with udev 188 and newer
			ACTION!="add|change", GOTO="u2f_end"

			# Yubico YubiKey
			KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0113|0114|0115|0116|0120|0121|0200|0402|0403|0406|0407|0410", TAG+="uaccess", GROUP="plugdev", MODE="0660"

			LABEL="u2f_end"
		'';

		zfs.autoScrub.enable = true;

	};


	# for flatpak
	xdg.portal = {
		enable = true;
		extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
	};

	virtualisation = {
		docker = {
			enable = true;
			storageDriver = "zfs"; # todo: change to overlay2
		};
		libvirtd.enable = true;
	};

	systemd = {
		# Disable autostart
		services.grafana = {
			wantedBy = lib.mkForce [];
			serviceConfig.SupplementaryGroups = [ config.users.groups.keys.name ];
		};
		services.docker.wantedBy = lib.mkForce [];
	};

	sops = {
		defaultSopsFile = ./secrets/sops.yaml;
		secrets.grafana_admin_pass.owner = config.users.users.grafana.name;
	};

	# This value determines the NixOS release from which the default
	# settings for stateful data, like file locations and database versions
	# on your system were taken. It‘s perfectly fine and recommended to leave
	# this value at the release version of the first install of this system.
	# Before changing this value read the documentation for this option
	# (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
	system.stateVersion = "20.09"; # Did you read the comment?

}

