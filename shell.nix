with import ./nixpkgs.nix;
pkgs.mkShell {
  buildInputs = [
    cacert
    yarn
    yarn2nix
    infuse
    rubyEnv.wrappedRuby
  ];

  LOCALE_ARCHIVE = "${buildPackages.glibcLocales}/lib/locale/locale-archive";
  LC_ALL = "en_US.UTF-8";

  shellHook = ''
    unset preHook # fix for lorri

    export PATH=$PATH:${euphenixYarnPackages + "/node_modules/.bin"}
  '';
}
