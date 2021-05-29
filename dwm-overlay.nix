(self: super: {
	dwm = super.dwm.overrideAttrs (oldAttrs: {
		pname = "dwm-illustris";
		version = "1.0.0";
		#src = self.fetchFromGitHub {
		#	owner = "illustris";
		#	repo = "dwm";
		#	rev = "dc50ebe69299bd895ae09bc1291f247fa40b2a5b";
		#	sha256 = "03hbc2k2fvpvrpdiln2g1sp249msgjvdy14xd7r7vpmgh3vqg8a1";
		#};
		src = /home/illustris/src/dwm;
		buildInputs = oldAttrs.buildInputs ++ (with super; [ harfbuzz ]);
	});
})
