{ config, pkgs, callPackage, lib, ... }:
# let
# 	dwlCustom = pkgs.callPackage ./packages/dwl {};
# in
{

	# Build my st fork
	nixpkgs.overlays = [
		(import ./st-overlay.nix)
		(import ./dwm-overlay.nix)
	];
	# My ST needs this font, need to move this into the overlay
	fonts.fonts = with pkgs; [
		(nerdfonts.override { fonts = [ "DroidSansMono" ]; })
	];

	programs = {
		browserpass.enable = true;
		dconf.enable = true;
		chromium = {
			enable = true;
			defaultSearchProviderSuggestURL = "https://sx.illustris.tech/autocompleter?q={searchTerms}";
			defaultSearchProviderSearchURL = "https://sx.illustris.tech/search?q={searchTerms}";
			extraOpts = {
				DefaultSearchProviderEnabled = true;
				DefaultSearchProviderName = "Sx";
				DefaultCookiesSetting = 1;
			};
			extensions = [
				"lcbjdhceifofjlpecfpeimnnphbcjgnc" # xBrowserSync
				"gcbommkclmclpchllfjekcdonpmejbdp" # https everywhere
				"cjpalhdlnbpafiamejdnhcphjbkeiagm" # ublock origin
				# "gppongmhjkpfnbhagpmjfkannfbllamg" # wappalyzer
				"bdakmnplckeopfghnlpocafcepegjeap" # RescueTime
				"chlffgpmiacpedhhbkiomidkjlcfhogd" # pushbullet
				"aghfnjkcakhmadgdomlmlhhaocbkloab" # just black
				"fmkadmapgofadopljbjfkapdkoienihi" # React Developer Tools
				"naepdomgkenhinolocfifgehidddafch" # Browserpass
				"ahmkjjgdligadogjedmnogbpbcpofeeo" # The Great Suspender
			];
		};
	};

	environment.systemPackages = with pkgs; [
		arandr
		dmenu
		dwl
		#dwlCustom
		glxinfo
		gnome.gnome-screenshot
		google-chrome # screen sharing on gmeet
		# guake # TODO: fine a better popover terminal
		i3lock
		insomnia
		moonlight-qt
		mpv
		pavucontrol
		perlPackages.AppClusterSSH
		remmina
		signal-desktop
		st
		steam
		ungoogled-chromium
		virt-manager
		vlc
		wireshark
		xsecurelock
		# zoom-us
	];

	services = {
		xserver = {
			enable = true;

			# breaks touch input if enabled
			wacom.enable = true;

			# Touchpad
			libinput.enable = true;

			displayManager = {
				defaultSession = "none+dwm";
				# sessionPackages = [ dwlCustom ];
			};

			videoDrivers = [ "displaylink" "modesetting" ];

			windowManager = {
				i3 = {
					enable = true;
					package = pkgs.i3-gaps;
					configFile = pkgs.writeText "i3.conf" (builtins.readFile ./conf_files/i3.conf);
				};
				dwm = {
					enable = true;
				};
			};
		};
		# Compositor for shell transparency
		picom = {
			enable = true;
			vSync = true;
			backend = "glx";
		};
	};

	systemd.user.services = {
		# guake = {
		#	enable = true;
		#	description = "Guake terminal";
		#	serviceConfig = {
		#		Type = "simple";
		#		ExecStart = "${pkgs.guake}/bin/guake";
		#		Restart = "always";
		#	};
		#	after = [ "dbus.service" ];
		# };
		picom.bindsTo = [ "graphical-session.target" ];
	};

	# Start VNC on boot
	# systemd.services.x11vnc = {
	#	path = [ pkgs.gawk pkgs.nettools ];
	#	wantedBy = [ "multi-user.target" ];
	#	requires = [ "graphical.target" ];
	#	description = "VNC server";
	#	serviceConfig = {
	#		Type = "simple";
	#		ExecStart = "${pkgs.x11vnc}/bin/x11vnc -display :0 -loop -shared -forever -auth /var/run/lightdm/root/:0 -rfbauth /var/lib/x11vnc/x11vnc_auth";
	#	};
	# };

	# open ports for VNC
	# networking.firewall.allowedTCPPorts = [ 5900 ];

	hardware.pulseaudio = {
		enable = true;
		# extraModules = [ pkgs.pulseaudio-modules-bt ];
		package = pkgs.pulseaudioFull;
	};

}
