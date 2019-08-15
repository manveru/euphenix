{ lib, mkDerivation, ruby }:
let inherit (builtins) fromJSON readFile;
in src:
let
  generated = mkDerivation {
    name = "cssDeps";
    buildInputs = [ ruby ];
    inherit src;

    buildCommand = ''
      ruby ${../scripts/css_deps.rb} "$src" > $out
    '';
  };
in fromJSON (readFile generated)
