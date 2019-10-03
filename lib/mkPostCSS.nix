{ cssDepsFor, mkDerivation, coreutils, postcss, lib }:
cssDir: fileName:
let imports = cssDepsFor cssDir fileName;
in mkDerivation {
  name = "mkPostCSS";
  __structuredAttrs = true;
  inherit imports fileName;
  buildInputs = [ coreutils postcss ];

  buildCommand = ''
    mkdir -p $out

    for i in "''${!imports[@]}"; do
      cp "''${imports[$i]}" $i
    done

    postcss "$fileName" \
      --map \
      -u postcss-import \
      -u postcss-cssnext \
      -u css-mqpacker \
      -u cssnano \
      --dir "$out"
  '';
}
