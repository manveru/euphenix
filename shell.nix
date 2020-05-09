{ pkgs, packages }:
pkgs.mkShell {
  buildInputs = with pkgs; [
    cacert
    yarn
    yarn2nix
    packages.rubyEnv.wrappedRuby
    packages.netlify
    packages.postcss
  ];
}
