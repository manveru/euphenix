{ mkDerivation, ruby }:
let inherit (builtins) fromJSON readFile;
in dir:
let
  generated = mkDerivation {
    name = "parseTemplates";
    buildInputs = [ ruby ];
    inherit dir;

    buildCommand = ''
      ruby ${../scripts/parse_templates.rb} "$dir" > $out
    '';
  };
in fromJSON (readFile generated)
