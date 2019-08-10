let
  pkgs = import ./nixpkgs.nix;
in
  {
    euphenix = pkgs.stdenv.mkDerivation {
      pname = "euphenix";
      version = "0.0.1";
      buildInputs = [ pkgs.makeWrapper ];
      phases = ["installPhase"];
      installPhase = ''
        mkdir -p $out/bin
        makeWrapper ${./bin/euphenix} $out/bin/euphenix \
          --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.rubyEnv.wrappedRuby ]}
      '';
    };
  }
