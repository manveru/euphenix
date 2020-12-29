{ lib, yants, mkDerivation, ruby, flags ? { } }:
let
  inherit (lib) concatStringsSep;
  inherit (builtins) attrValues mapAttrs fromJSON readFile;

  flagsString = concatStringsSep " " (attrValues
    (mapAttrs (k: v: if v == true then "--${k}" else "--${k}=${toString v}")
      flags));

  resultT = yants.struct "markdownResult" {
    body = yants.string;
    meta = yants.attrs yants.any;
    teaser = yants.string;
  };

in yants.defun [ yants.path resultT ] (src:
  fromJSON (readFile (mkDerivation {
    name = "parseMarkdown";
    buildInputs = [ ruby ];
    allowSubstitutes = false;

    buildCommand = ''
      ruby ${../scripts/front_matter.rb} ${flagsString} "${src}" | tee $out
    '';
  })))
