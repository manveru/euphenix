# we use our own derivation because we don't need all the overhead of stdenv
# and this speeds up builds a lot.

{ lib, bash, glibcLocales }:
let inherit (builtins) toFile;
in { buildInputs ? [], ... }@givenArgs:
derivation ({
  out = placeholder "out";
  system = builtins.currentSystem;
  builder = "${bash}/bin/bash";

  PATH = lib.makeBinPath buildInputs;
  LOCALE_ARCHIVE = "${glibcLocales}/lib/locale/locale-archive";
  LC_ALL = "en_US.UTF-8";

  args = [
    "-e"
    (toFile "builder.sh" ''
      if [ -e .attrs.sh ]; then
        source .attrs.sh;
      fi

      eval "$buildCommand"
    '')
  ];
} // givenArgs)
