{ lib, mkDerivation, mkPostCSS, copyFiles, mkFavicons, coreutils }:

{ rootDir, name ? null, cssDir ? null, templateDir ? null, staticDir ? null
, favicon ? null, variables ? null, expensiveVariables ? null, layout
, extraParts ? null, routes ? null  }@givenBuildArgs:

let
  buildArgs = {
    name = baseNameOf rootDir;
    cssDir = rootDir + "/css";
    templateDir = rootDir + "/templates";
    staticDir = rootDir + "/static";
    variables = { };
    expensiveVariables = { };
    favicon = null;
    extraParts = [ ];
    routes = {};
  } // givenBuildArgs;

  inherit (buildArgs) name favicon staticDir extraParts;
in mkDerivation {
  inherit name;

  parts = routes
    ++ (lib.optional (builtins.pathExists staticDir) (copyFiles staticDir "/"))
    ++ (lib.optional (favicon != null) (mkFavicons favicon)) ++ extraParts;

  buildInputs = [ coreutils ];

  buildCommand = ''
    mkdir -p $out

    for part in $parts; do
      chmod u+rw -R $out
      cp -r $part/* $out
    done
  '';
}
