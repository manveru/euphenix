{ stdenv, ruby, nix, euphenixYarnPackages, makeWrapper }:

stdenv.mkDerivation {
  pname = "euphenix";
  version = "0.0.1";
  nativeBuildInputs = [ makeWrapper ruby ];
  phases = [ "installPhase" ];
  netlify = "${euphenixYarnPackages}/node_modules/.bin/netlify";
  liveServer = "${euphenixYarnPackages}/node_modules/.bin/live-server";
  nixBuild = "${nix}/bin/nix-build";
  installPhase = ''
    mkdir -p $out/bin
    substituteAll ${../bin/euphenix} $out/bin/euphenix
    chmod 0766 $out/bin/euphenix
    patchShebangs $out/bin/euphenix
  '';
}
