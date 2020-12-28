final: prev: {
  packages = prev.callPackages ./nix/packages.nix { };
  yants = prev.callPackage ./nix/yants.nix { };
  pp = value: builtins.trace (builtins.toJSON value) value;
  compact = prev.lib.subtractLists [ null ];
  sortByRecent = prev.lib.sort (a: b: a.meta.date > b.meta.date);

  euphenix = prev.lib.makeExtensible (self: {
    callPackage = prev.lib.callPackageWith self;
    inherit (final)
      lib yants coreutils gnugrep imagemagick findutils bash glibcLocales gnused
      sortByRecent compact writeTextFile system;
    inherit (final.packages) nodeEnv euphenix postcss netlify;
    ruby = final.packages.rubyEnv.wrappedRuby;

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
    sanitizeDerivationName =
      self.callPackage ./lib/sanitizeDerivationName.nix { };
  });
}
