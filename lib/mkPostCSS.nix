{cssDepsFor, mkDerivation, coreutils, euphenixYarnPackages }:
  cssDir: fileName:
    let imports = cssDepsFor cssDir fileName;
    in mkDerivation {
      name = "mkPostCSS";
      __structuredAttrs = true;
      inherit imports fileName;
      PATH = "${coreutils}/bin:${euphenixYarnPackages}/node_modules/.bin";

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
