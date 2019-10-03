{ lib, mkDerivation, coreutils, ruby, gnused, cssCompiler ? mkPostCSS, mkPostCSS  }:
let inherit (builtins) toFile toJSON readFile;
in { variables, expensiveVariables, cssDir, layout, templateDir, ... }:
tmpl: page:
let
  cheapMetaData = (variables // page.meta // { inherit body; });
  metaData = if cheapMetaData ? requires then
    cheapMetaData // (builtins.listToAttrs (map (key: {
      name = key;
      value = expensiveVariables."${key}";
    }) (lib.toList cheapMetaData.requires)))
  else
    cheapMetaData;

  style = if metaData ? css then {
    cssTag = ''<link rel="stylesheet" href="/css/${metaData.css}" />'';
  } else
    { };

  metaJSON = toFile "meta.json" (toJSON (metaData // style));

  compiledCSS = if metaData ? css then cssCompiler cssDir metaData.css else "";
  body = toFile "body.tmpl" page.body;
  definitions = lib.concatMapStrings (f: ''-d "${f}" '') page.imports;
  finalRoute = if lib.hasSuffix "/" page.meta.route then
    "${page.meta.route}/index.html"
  else
    page.meta.route;

  omgData = (metaData // style);
  omg = scopedImport (omgData // { template = scopedImport omgData; }) layout;
in mkDerivation {
  name = "mkRoute-${baseNameOf tmpl}";
  buildInputs = [ coreutils gnused ];
  buildCommand = ''
    mkdir -p $out

    ${if compiledCSS != "" then ''
      mkdir -p $out/css
      cp -r ${compiledCSS}/* $out/css
    '' else
      ""}

    install -m 0644 -D ${toFile "result" omg} "$out${finalRoute}"
  '';
}
