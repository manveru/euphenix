{ pkgs ? import ./nix { } }:

pkgs.lib.makeExtensible (self: {
  callPackage = pkgs.lib.callPackageWith self;
  inherit (pkgs) lib yants coreutils gnugrep imagemagick findutils bash glibcLocales gnused;
  inherit (pkgs.packages) nodeEnv euphenix;
  ruby = pkgs.packages.rubyEnv.wrappedRuby;
  postcss = pkgs.packages.postcss;
  netlify = pkgs.packages.netlify;

  build = self.callPackage ./lib/build.nix { };
  copyFile = self.callPackage ./lib/copyFile.nix { };
  copyFiles = self.callPackage ./lib/copyFiles.nix { };
  copyImagesMogrify = self.callPackage ./lib/copyImagesMogrify.nix { };
  cssDepsFor = self.callPackage ./lib/cssDepsFor.nix { };
  cssDeps = self.callPackage ./lib/cssDeps.nix { };
  cssTag = self.callPackage ./lib/cssTag.nix { };
  loadPosts = self.callPackage ./lib/loadPosts.nix { };
  mkDerivation = self.callPackage ./lib/mkDerivation.nix { };
  mkFavicons = self.callPackage ./lib/mkFavicons.nix { };
  mkPostCSS = self.callPackage ./lib/mkPostCSS.nix { };
  mkRoute = self.callPackage ./lib/mkRoute.nix { };
  mkRoutes = self.callPackage ./lib/mkRoutes.nix { };
  parseMarkdown = self.callPackage ./lib/parseMarkdown.nix { };
  parseTemplates = self.callPackage ./lib/parseTemplates.nix { };
  routes = self.callPackage ./lib/routes.nix { };
})
