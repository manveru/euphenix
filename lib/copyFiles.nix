{ mkDerivation, coreutils }:
from: to:
mkDerivation {
  name = "copyFiles";
  buildInputs = [ coreutils ];
  inherit from to;

  buildCommand = ''
    mkdir -p $out$to
    cp -r "$from"/* $out$to
  '';
}
