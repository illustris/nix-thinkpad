{ stdenv, python3Packages, pass, xdotool, fetchFromGitHub }:

stdenv.mkDerivation rec {
	version = "1.0.0";
	pname = "passcol";
	src = fetchFromGitHub {
		owner = "illustris";
		repo = "passcol";
		rev = "6bca0a85a6394e1fabab6790e9191f64d4bad281";
		sha256 = "1hj5ks382i5cafl6kz7576v59iqc73k90wr6567qcbl6xzgx9iq2";
	};

	buildInputs = [
		pass python3Packages.percol xdotool
	];

	installPhase = ''
		mkdir -p $out/bin
		cp passcol.sh $out/bin/passcol
	'';
}
