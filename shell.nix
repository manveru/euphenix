{ pkgs }:
pkgs.mkShell {
  buildInputs = with pkgs; [
    cacert
    yarn
    yarn2nix
    euphenix.ruby
    euphenix.netlify
    euphenix.postcss
  ];
}
