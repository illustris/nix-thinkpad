(self: super: {
	st = super.st.overrideAttrs (oldAttrs: {
		inputs = [ (super.nerdfonts.override { fonts = [ "DroidSansMono" ]; }) ];
		pname = "st";
		version = "1.0.0";
		src = self.fetchFromGitHub {
			owner = "illustris";
			repo = "st";
			rev = "e81a0418d6333127e7b8b7c3690ea18fc3278f73";
			sha256 = "107hk45m67hh10vbkmph98chcl3ix601bjr8s89pmf5j0z8d2aw7";
		};
		# src = /home/illustris/src/st;
		buildInputs = oldAttrs.buildInputs ++ (with super; [ harfbuzz ]);
	});
})
