# we use our own derivation because we don't need all the overhead of stdenv
# and this speeds up builds a lot.

{ lib, yants, bash, glibcLocales, system ? builtins.currentSystem }:
yants.defun [
  (yants.struct "mkDerivationArgs" {
    name = yants.string;
    buildInputs = yants.option (yants.list yants.drv);
    allowSubstitutes = yants.option yants.bool;
    buildCommand = yants.string;
    parts = yants.option yants.string;
    preferLocalBuild = yants.option yants.bool;
    route = yants.option yants.string;
    template = yants.option yants.string;
    PATH = yants.option yants.string;
    __structuredAttrs = yants.option yants.bool;
    fileName = yants.option yants.string;
    imports = yants.option (yants.attrs yants.string);
    src = yants.option yants.path;
    to = yants.option yants.any;
    from = yants.option yants.any;
  })
  yants.drv
] (args:
  derivation ({
    out = placeholder "out";
    inherit system;
    builder = "${bash}/bin/bash";

    PATH = lib.makeBinPath args.buildInputs;
    LOCALE_ARCHIVE = "${glibcLocales}/lib/locale/locale-archive";
    LC_ALL = "en_US.UTF-8";

    args = [
      "-e"
      (__toFile "builder.sh" ''
        if [ -e .attrs.sh ]; then
          source .attrs.sh;
        fi

        eval "$buildCommand"
      '')
    ];
  } // args))
