{ lib, mkDerivation, copyFiles, mkFavicons, coreutils, mkRoutes }:

rootDir:
{ name ? null, templateDir ? null, staticDir ? null
, favicon ? null, extraParts ? null, routes ? null }@givenBuildArgs:

let
  buildArgs = {
    name = baseNameOf rootDir;
    templateDir = rootDir + "/templates";
    staticDir = rootDir + "/static";
    favicon = rootDir + "/static/img/favicon.svg";
    extraParts = [ ];
    routes = [ ];
  } // givenBuildArgs;

  inherit (buildArgs) name favicon staticDir templateDir extraParts routes;
  inherit (lib) optional;

  staticParts = (optional (__pathExists staticDir) (copyFiles staticDir "/"));
  faviconParts = (optional (__pathExists favicon) (mkFavicons favicon));
  routeParts = mkRoutes { inherit templateDir; } routes;
in mkDerivation {
  inherit name;

  parts = routeParts ++ staticParts ++ faviconParts ++ extraParts;

  buildInputs = [ coreutils ];

  buildCommand = ''
    mkdir -p $out

    for part in $parts; do
      chmod u+rw -R $out
      cp -r $part/* $out
    done
  '';
}
