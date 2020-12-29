{ bundlerEnv, ruby, mkYarnPackage, lib, stdenv, makeWrapper, nixUnstable
, gitMinimal }:
let
  nodeDrv = env: bin:
    stdenv.mkDerivation {
      name = bin;
      src = env;
      installPhase = ''
        mkdir -p $out/bin
        ln -s $src/libexec/euphenix/node_modules/.bin/${bin} $out/bin/${bin}
      '';
    };
in rec {
  rubyEnv = bundlerEnv {
    inherit ruby;
    name = "euphenix-rubyEnv";
    gemdir = ../.;
    groups = [ "default" ];
  };

  nodeEnv = mkYarnPackage {
    pname = "euphenix";
    name = "euphenix-nodeEnv";
    version = "1.0";
    packageJSON = ../package.json;
    yarnLock = ../yarn.lock;
    publishBinsFor = [ "netlify" "postcss" ];

    src = lib.cleanSourceWith {
      filter = lib.cleanSourceFilter;
      src = lib.cleanSourceWith {
        filter = name: type:
          !(lib.hasSuffix ".nix" name || type == "directory");
        src = ../.;
      };
    };
  };

  netlify = nodeDrv nodeEnv "netlify";
  postcss = nodeDrv nodeEnv "postcss";

  euphenix = stdenv.mkDerivation {
    name = "euphenix";
    version = "0.0.1";
    nativeBuildInputs = [ makeWrapper rubyEnv.wrappedRuby ];
    phases = [ "installPhase" ];

    netlify = "${netlify}/bin/netlify";
    nix = "${nixUnstable}/bin/nix";
    git = "${gitMinimal}/bin/git";

    installPhase = ''
      mkdir -p $out/bin
      substituteAll ${../bin/euphenix} $out/bin/euphenix
      chmod 0766 $out/bin/euphenix
      patchShebangs $out/bin/euphenix
    '';
  };
}
