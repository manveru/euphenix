{ lib, yants, mkDerivation, copyFiles, mkFavicons, coreutils, mkRoutes }:
let
  inherit (yants) struct option path string list drv attrs any;

  buildArgsT = struct "buildArgs" {
    name = option string;
    src = path;
    templateDir = option path;
    staticDir = option path;
    favicon = option path;
    extraParts = option (list drv);
    routes = attrs any;
  };

in givenBuildArgs:
let
  checkedBuildArgs = buildArgsT givenBuildArgs;
  buildArgs = buildArgsT ({
    name = baseNameOf checkedBuildArgs.src;
    templateDir = checkedBuildArgs.src + "/templates";
    staticDir = checkedBuildArgs.src + "/static";
    favicon = checkedBuildArgs.src + "/static/img/favicon.svg";
    extraParts = [ ];
    routes = [ ];
  } // givenBuildArgs);

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
