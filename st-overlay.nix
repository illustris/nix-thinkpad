(self: super: {
	st = super.st.overrideAttrs (oldAttrs: {
		inputs = [ (super.nerdfonts.override { fonts = [ "DroidSansMono" ]; }) ];
		pname = "st";
		version = "1.0.0";
		src = self.fetchFromGitHub {
			owner = "illustris";
			repo = "st";
			rev = "fa363487355fe0b27d82e7247577802ac66e4b0f";
			hash = "sha256-KLh4yGSq7pf6F+mWZvH6slN+Qa1/LkjWbhFTxQ2vYng=";
		};
		# src = /home/illustris/src/st;
		buildInputs = oldAttrs.buildInputs ++ (with super; [ harfbuzz ]);
	});
})
