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

  yantsSource = fetchTarball {
    url =
      "https://github.com/tazjin/yants/archive/afd2fd5058d14c99ca60e9be28ee778f5df1958d.tar.gz";
    sha256 = "07vrdpg0l7lqc8lb170cslky1l0cimbcmvp78qf5rz8lhrpm95bp";
  };

  srcWithout = rootPath: ignoredPaths:
    let ignoreStrings = map (path: toString path) ignoredPaths;
    in builtins.filterSource
    (path: type: (builtins.all (i: i != path) ignoreStrings)) rootPath;

in import nixpkgsSource {
  config = { allowUnfree = true; };
  overlays = [
    (self: super: {
      rubyEnv = super.bundlerEnv {
        ruby = super.ruby_2_6;
        name = "euphenix-gems";
        gemdir = ./.;
        groups = [ "default" ];
      };

      rubyDevEnv = super.bundlerEnv {
        ruby = super.ruby_2_6;
        name = "euphenix-gems";
        gemdir = ./.;
        groups = [ "default" "development" ];
      };

      inherit srcWithout;
      inherit (yarn2nix) yarn2nix mkYarnModules mkYarnPackage;

      euphenixYarnPackages = yarn2nix.mkYarnModules {
        name = "euphenix-packages";
        pname = "euphenix";
        version = "1.0";
        packageJSON = ./package.json;
        yarnLock = ./yarn.lock;
      };
    })
  ];
}
