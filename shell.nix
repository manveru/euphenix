with import ./nix {};
pkgs.mkShell {
  buildInputs = [
    cacert
    yarn
    yarn2nix
    packages.rubyEnv.wrappedRuby
    packages.netlify
    packages.postcss
  ];

  shellHook = ''
    unset preHook # fix for lorri
  '';
}
