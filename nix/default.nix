{ sources ? import ./sources.nix }:
with {
  overlay = _: pkgs: {
    inherit (import sources.niv { }) niv;
    packages = pkgs.callPackages ./packages.nix { };
    inherit (import sources.yarn2nix { inherit pkgs; }) yarn2nix mkYarnPackage;
    yants = import sources.yants { inherit (pkgs) lib; };
    lib = pkgs.lib;
    pp = value: builtins.trace (builtins.toJSON value) value;
    compact = pkgs.lib.subtractLists [ null ];
    sortByRecent = pkgs.lib.sort (a: b: a.meta.date > b.meta.date);
  };
};
import sources.nixpkgs {
  overlays = [ overlay ];
  config = { };
}
