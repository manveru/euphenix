let
  inherit (builtins) fetchTarball fetchurl import;

  nixpkgsSource = fetchTarball {
    url =
      "https://github.com/nixos/nixpkgs-channels/archive/a835adc10cb813d214a9069361d94a2a3f8eb3a5.tar.gz";
    sha256 = "0q2nqxadlhs52q02lis27qgx624gbz9p809a5iw6a3fpbnawjdm9";
  };

  yarn2nixSource = fetchTarball {
    url =
      "https://github.com/moretea/yarn2nix/archive/780e33a07fd821e09ab5b05223ddb4ca15ac663f.tar.gz";
    sha256 = "1f83cr9qgk95g3571ps644rvgfzv2i4i7532q8pg405s4q5ada3h";
  };

  yarn2nix = import yarn2nixSource { pkgs = import nixpkgsSource {}; };

  infuseSource = fetchurl {
    url =
      "https://github.com/jucardi/infuse/releases/download/v1.0.0.0/infuse-Linux-x86_64";
    sha256 = "17ln936r21g44rskaiddz0rqqy87aji20x1qav23ga49vc4rl1ii";
  };

  srcWithout = rootPath: ignoredPaths:
    let ignoreStrings = map (path: toString path) ignoredPaths;
    in builtins.filterSource
    (path: type: (builtins.all (i: i != path) ignoreStrings)) rootPath;

in import nixpkgsSource {
  config = { allowUnfree = true; };
  overlays = [
    (self: super: {
      infuse = super.stdenv.mkDerivation {
        pname = "infuse";
        version = "1.0.0.0";
        src = infuseSource;
        buildCommand = ''
          mkdir -p $out/bin
          cp $src $out/bin/infuse
          chmod +x $out/bin/infuse
        '';
      };

      # 2.5 is a bit faster than 2.6
      rubyEnv = super.bundlerEnv {
        ruby = super.ruby_2_5;
        name = "euphenix-gems";
        gemdir = ./.;
      };

      inherit srcWithout;
      inherit (yarn2nix) yarn2nix mkYarnModules mkYarnPackage;

      euphenixYarnPackages = yarn2nix.mkYarnModules {
        name = "euphenix-packages";
        pname = "euphenix";
        version = "1.0";
        packageJSON = ./package.json;
        yarnLock = ./yarn.lock;
        yarnNix = ./yarn.nix;
      };
    })
  ];
}
