{ lib, mkDerivation, coreutils, ruby, writeTextFile, sanitizeDerivationName }:
let
  inherit (builtins)
    baseNameOf attrValues mapAttrs toFile readFile addErrorContext;
  inherit (lib) attrByPath foldr fileContents;
in { templateDir }:
let
  mkRoute = route: value:
    let
      fakeImport = vars: file:
        addErrorContext "Importing ${file}" (scopedImport vars file);
          # (toFile (baseNameOf file) "''${fileContents file}''"));

      include = file: vars:
        let actual = templateDir + "/" + file;
        in addErrorContext "include ${actual}" (scopedImport vars actual);
          # (toFile (baseNameOf actual) "''${readFile actual}''"));

      variables = {
        inherit route include;
      } // (attrByPath [ "variables" ] { } value);

      template = foldr (val: sum:
        if sum == null then
          fakeImport variables val
        else
          fakeImport (variables // { content = sum; }) val) null value.template;

    in addErrorContext "Building ${route}" (mkDerivation {
      allowSubstitutes = false;
      preferLocalBuild = true;
      name = "mkRoute-${sanitizeDerivationName route}";
      buildInputs = [ coreutils ruby ];
      inherit route;
      template = (writeTextFile {
        name = "template";
        text = template;
      }).outPath;
      buildCommand = ''
        ruby ${../scripts/compile.rb}
      '';
    });
in args: attrValues (mapAttrs mkRoute args)
