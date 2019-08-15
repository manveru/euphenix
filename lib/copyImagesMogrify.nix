{ mkDerivation, coreutils, image_optim, gnugrep, imagemagick
, findutils }:
from: to: size:
mkDerivation {
  name = "copyImages";
  buildInputs = [ coreutils image_optim gnugrep imagemagick findutils ];
  inherit from to;

  buildCommand = ''
    mkdir -p $out$to
    cp -r "$from"/* $out$to
    chmod -R u+w $out

    find $out -name '*.jpg' -or -name '*.png' | \
      xargs -n1 -IX \
        mogrify X \
          -filter Triangle \
          -define filter:support=2 \
          -thumbnail ${toString size} \
          -unsharp 0.25x0.25+8+0.065 \
          -dither None \
          -posterize 136 \
          -quality 82 \
          -define jpeg:fancy-upsampling=off \
          -define png:compression-filter=5 \
          -define png:compression-level=9 \
          -define png:compression-strategy=1 \
          -define png:exclude-chunk=all \
          -interlace none \
          -colorspace sRGB \
          -strip X
  '';
}
