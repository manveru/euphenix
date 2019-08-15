{ lib, mkDerivation, coreutils, infuse, gnused, cssCompiler }:
let inherit (builtins) toFile toJSON readFile;
in { variables, expensiveVariables, cssDir, layout, templateDir, ... }:
tmpl: page:
let
  cheapMetaData = (variables // page.meta // { inherit body; });
  metaData = if cheapMetaData ? requires then
    cheapMetaData // (builtins.listToAttrs (map (key: {name = key; value = expensiveVariables."${key}"; }) (lib.toList cheapMetaData.requires )))
  else cheapMetaData;

  style = if metaData ? css then {
    cssTag = ''<link rel="stylesheet" href="/css/${metaData.css}" />'';
  } else
    { };

  metaJSON = toFile "meta.json" (toJSON (metaData // style));

  compiledCSS = if metaData ? css then cssCompiler cssDir metaData.css else "";
  body = toFile "body.tmpl" page.body;
  definitions = lib.concatMapStrings (f: ''-d "${f}" '') page.imports;
in mkDerivation {
  name = "mkRoute-${baseNameOf tmpl}";
  buildInputs = [ coreutils infuse gnused ];
  imports =
    (map (i: toFile "__${i}" (readFile (templateDir + "/${i}"))) page.imports);
  buildCommand = ''
    mkdir -p $out

    for imp in $imports; do
      filename=$(echo $imp | sed 's/.*-__//')
      cp $imp $filename
    done

    cp ${body} __body.tmpl
    sed 's!{{ yield }}!{{template "__body.tmpl" .}}!' ${layout} > __layout.tmpl
    ${if compiledCSS != "" then ''
      mkdir -p $out/css
      cp -r ${compiledCSS}/* $out/css
    '' else
      ""}
    infuse -f ${metaJSON} ${definitions} -d __body.tmpl __layout.tmpl -o result

    install -m 0644 -D result "$out${page.meta.route}"
  '';
}
