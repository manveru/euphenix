{ mkDerivation, coreutils, imagemagick }:

source:
let
  convertPNG = size:
    "convert -background none ${source} -resize ${size}x${size}! +repage $out/favicons/favicon${size}.png";

  convertICO =
    "convert -background none ${source} -define icon:auto-resize=32,64 +repage ico:- > $out/favicons/favicon.ico";
in mkDerivation {
  name = "favicons";
  buildInputs = [ coreutils imagemagick ];

  buildCommand = ''
    mkdir -p $out/favicons
    ${convertICO}
    ${convertPNG "32"}
    ${convertPNG "57"}
    ${convertPNG "72"}
    ${convertPNG "144"}
  '';
}
