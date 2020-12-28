{
  description = "A flake for building Euphenix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, flake-utils, nixpkgs }:
    (flake-utils.lib.simpleFlake {
      inherit self nixpkgs;
      name = "euphenix";
      overlay = ./overlay.nix;
      shell = ./shell.nix;
    }) // {
      overlay = import ./overlay.nix;
    };
}
