{ pkgs ? import ./nixpkgs.nix }:

( pkgs.lib.makeExtensible (self: {
  callPackage = pkgs.lib.callPackageWith self;

  inherit pkgs;
  inherit (pkgs)
    lib coreutils bash glibcLocales gnused euphenixYarnPackages
    imagemagick stdenv makeWrapper infuse;
  ruby = pkgs.rubyEnv.wrappedRuby;

  pp = value: builtins.trace (builtins.toJSON value) value;
  compact = pkgs.lib.subtractLists [ null ];
  sortByRecent = pkgs.lib.sort (a: b: a.meta.date > b.meta.date);
}) ).extend (self: super: {
  build = super.callPackage ./lib/build.nix { };
  copyFiles = super.callPackage ./lib/copyFiles.nix { };
  cssDeps = super.callPackage ./lib/cssDeps.nix { };
  cssDepsFor = super.callPackage ./lib/cssDepsFor.nix { };
  loadPosts = super.callPackage ./lib/loadPosts.nix { };
  mkDerivation = super.callPackage ./lib/mkDerivation.nix { };
  mkFavicons = super.callPackage ./lib/mkFavicons.nix { };
  mkPostCSS = super.callPackage ./lib/mkPostCSS.nix { };
  mkRoute =
    super.callPackage ./lib/mkRoute.nix { cssCompiler = self.mkPostCSS; };
  mkRoutes = super.callPackage ./lib/mkRoutes.nix { };
  parseMarkdown = super.callPackage ./lib/parseMarkdown.nix { };
  parseTemplates = super.callPackage ./lib/parseTemplates.nix { };
  routes = super.callPackage ./lib/routes.nix { };
  wrapBody = super.callPackage ./lib/wrapBody.nix { };
  euphenix = super.callPackage ./pkgs/euphenix.nix { };
})
