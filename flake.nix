{
  description = "A flake for building Euphenix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs-channels/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, utils, nixpkgs }:
    utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in rec {
        packages = pkgs.callPackage ./nix/packages.nix { };
        apps = { inherit (packages) euphenix netlify postcss; };
        defaultApp = apps.euphenix;
        devShell = import ./shell.nix { inherit pkgs packages; };
      });
}
