{ pkgs ? import ./nixpkgs.nix, overrides ? x: { } }:
let
  inherit (builtins) trace toJSON;

  callPackage = pkgs.lib.callPackageWith stdlib;

  fixedPoint = rec {
    inherit pkgs;
    inherit (pkgs)
      lib coreutils bash glibcLocales infuse gnused euphenixYarnPackages
      imagemagick stdenv makeWrapper;
    ruby = pkgs.rubyEnv.wrappedRuby;

    pp = value: trace (toJSON value) value;
    compact = pkgs.lib.subtractLists [ null ];
    sortByRecent = pkgs.lib.sort (a: b: a.meta.date > b.meta.date);

    build = callPackage ./lib/build.nix { };
    copyFiles = callPackage ./lib/copyFiles.nix { };
    cssDeps = callPackage ./lib/cssDeps.nix { };
    cssDepsFor = callPackage ./lib/cssDepsFor.nix { };
    loadPosts = callPackage ./lib/loadPosts.nix { };
    mkDerivation = callPackage ./lib/mkDerivation.nix { };
    mkFavicons = callPackage ./lib/mkFavicons.nix { };
    mkPostCSS = callPackage ./lib/mkPostCSS.nix { };
    mkRoute = callPackage ./lib/mkRoute.nix { cssCompiler = mkPostCSS; };
    mkRoutes = callPackage ./lib/mkRoutes.nix { };
    parseMarkdown = callPackage ./lib/parseMarkdown.nix { };
    parseTemplates = callPackage ./lib/parseTemplates.nix { };
    routes = callPackage ./lib/routes.nix { };
    wrapBody = callPackage ./lib/wrapBody.nix { };
    euphenix = callPackage ./pkgs/euphenix.nix { };
  };

  stdlib = fixedPoint // (overrides fixedPoint);

in stdlib
