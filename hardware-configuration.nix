# Do not modify this file! It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations. Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
	imports = [
		(modulesPath + "/installer/scan/not-detected.nix")
	];

	boot = {
		initrd = {
			availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" ];
			kernelModules = [ ];
		};
		kernelModules = [ "kvm-intel" ];
		extraModulePackages = [ ];
	};

	fileSystems = {
		"/" = {
			device = "nvme/rootfs";
			fsType = "zfs";
		};
		"/nix" = {
			device = "nvme/nix";
			fsType = "zfs";
		};
		"/home" = {
			device = "nvme/home";
			fsType = "zfs";
		};
		"/root" = {
			device = "nvme/home/root";
			fsType = "zfs";
		};
		"/var/log" = {
			device = "nvme/var_log";
			fsType = "zfs";
		};
		"/tmp" = {
			device = "nvme/tmp";
			fsType = "zfs";
		};
		"/boot" = {
			device = "/dev/disk/by-uuid/EF5F-3DAC";
			fsType = "vfat";
		};
	};

	nixpkgs.config.packageOverrides = pkgs: {
		vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
	};

	hardware.opengl = {
		enable = true;
		driSupport = true;
		driSupport32Bit = true;
		extraPackages = with pkgs; [
			intel-media-driver
			vaapiIntel
			vaapiVdpau
			libvdpau-va-gl
		];
		extraPackages32 = with pkgs.pkgsi686Linux; [
			vaapiIntel
			vaapiVdpau
			libvdpau-va-gl
		];
	};
	#hardware.cpu.intel.updateMicrocode = true;

	zramSwap.enable = true;

	boot = {
		zfs.devNodes = "/dev/disk/by-label";
		supportedFilesystems = [ "zfs" ];
		loader.grub.copyKernels = true;
	};

	powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
	#powerManagement.cpuFreqGovernor = lib.mkDefault "performance";
	#services.undervolt.enable = true;

	# Enable Intel iGPU passthrough for VMs
	virtualisation.kvmgt.enable = true;
}
