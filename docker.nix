{ pkgs ? import ./nixpkgs.nix }:
pkgs.dockerTools.buildLayeredImage {
  name = "registry.gitlab.com/manveru/euphenix";
  tag = "latest";
  created = "now";
  maxLayers = 110;

  contents = [ (import ./. { }).euphenix ];
}
