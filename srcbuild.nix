(
	self: super: {

		# Build everything with O3 and skylake optimizations
		stdenv = super.stdenv // {
			mkDerivation = args: super.stdenv.mkDerivation (
				args // {
					#dontStrip = true;
					#NIX_CFLAGS_COMPILE = toString (args.NIX_CFLAGS_COMPILE or "") + " -pipe -march=skylake -O3 -grecord-gcc-switches";
					NIX_CFLAGS_COMPILE = toString (args.NIX_CFLAGS_COMPILE or " -pipe -march=skylake -O3"); # + " -pipe -march=skylake";
				}
			);
		};

		# Kernel doesn't like O2 or O3
		# This is the cleanest way I could find for making sure the kernel doesn't get built with the NIX_CFLAGS_COMPILE added to stdenv
		# This stdenv is used to create a new derivation for pkgs.linux, which is then given to boot.kernelPackages in configuration.nix using:
		# boot.kernelPackages = pkgs.linuxPackagesFor ( pkgs.linux.override { stdenv = pkgs.kernelStdenv; } );
		kernelStdenv = super.stdenv // {
			mkDerivation = args: super.stdenv.mkDerivation (
				args // {
					#dontStrip = true;
					#NIX_CFLAGS_COMPILE = toString (args.NIX_CFLAGS_COMPILE or "") + " -pipe -march=skylake -grecord-gcc-switches";
					NIX_CFLAGS_COMPILE = toString (args.NIX_CFLAGS_COMPILE or " -pipe -march=skylake"); # added o2
				}
			);
		};

		# Docker and docker-runc don't like O2 or O3
		docker = super.docker.overrideAttrs (
			oldAttrs: {
				NIX_CFLAGS_COMPILE = " -pipe -march=skylake";
			}
		);
		# docker-runc is found in
		# nixpkgs/pkgs/applications/virtualization/docker/default.nix:19: docker-runc = runc.overrideAttrs ....
		# This was the only way I could find to stop docker-runc form getting the flags from stdenv
		# runc doesn't appear to be used by anything other than docker-runc at the moment, so this will have to do
		runc = super.runc.overrideAttrs (
			oldAttrs: {
				NIX_CFLAGS_COMPILE = " -pipe -march=skylake";
			}
		);

		# Go doesn't like O2 or O3
		# This override is for the base go package
		go = super.go.overrideAttrs (
			oldAttrs: {
				NIX_CFLAGS_COMPILE = " -pipe -march=skylake";
			}
		);
		# The following overrides do the same for the go packages used by "buildGoPackage"
		go_1_14 = super.go_1_14.overrideAttrs (
			oldAttrs: {
				NIX_CFLAGS_COMPILE = " -pipe -march=skylake";
			}
		);
		go_1_15 = super.go_1_15.overrideAttrs (
			oldAttrs: {
				NIX_CFLAGS_COMPILE = " -pipe -march=skylake";
			}
		);

		blas = super.blas.override {
			blasProvider = self.mkl;
		};

		lapack = super.lapack.override {
			lapackProvider = self.mkl;
		};

	}

)
