{ lib, mkDerivation, ruby, flags ? { } }:
let
  inherit (lib) concatStringsSep;
  inherit (builtins) attrValues mapAttrs fromJSON readFile;

  flagsString = concatStringsSep " " (attrValues
    (mapAttrs (k: v: if v == true then "--${k}" else "--${k}=${toString v}")
      flags));

in src:
fromJSON (readFile (mkDerivation {
  name = "md2Meta";
  buildInputs = [ ruby ];

  buildCommand = ''
    ruby ${../scripts/front_matter.rb} ${flagsString} "${src}" > $out
  '';
}))
