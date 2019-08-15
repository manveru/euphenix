{ lib, mkDerivation, coreutils, infuse, gnused }:
let inherit (builtins) toFile toJSON readFile;
in { variables, templateDir, ... }:
tmpl: outer: inner:
let
  body = toFile "body.tmpl" outer.body;
  metadata = toFile "meta.json" (toJSON (variables // inner));
  definitions = lib.concatMapStrings (f: ''-d "${f}" '') outer.imports;
in mkDerivation {
  name = "wrapBody-${baseNameOf tmpl}";
  buildInputs = [ coreutils infuse gnused ];
  imports =
    (map (i: toFile "__${i}" (readFile (templateDir + "/${i}"))) outer.imports);
  buildCommand = ''
    for imp in $imports; do
      filename=$(echo $imp | sed 's/.*-__//')
      cp $imp $filename
    done

    cp ${body} __body.tmpl
    infuse -f ${metadata} ${definitions} __body.tmpl -o $out
  '';
}
