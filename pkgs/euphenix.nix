{ stdenv, ruby, makeWrapper }:

stdenv.mkDerivation {
  pname = "euphenix";
  version = "0.0.1";
  nativeBuildInputs = [ makeWrapper ruby ];
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out/bin
    cp ${../bin/euphenix} $out/bin/euphenix
    patchShebangs $out/bin/euphenix
  '';
}
