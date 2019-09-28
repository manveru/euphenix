{ mkDerivation, coreutils }:
from: to:
mkDerivation {
  name = "copyFiles";
  buildInputs = [ coreutils ];
  inherit from to;

  buildCommand = ''
    mkdir -p $(dirname $out$to)
    cp "$from" $out/$to
  '';
}
