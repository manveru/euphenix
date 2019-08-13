{ pkgs ? import ./nixpkgs.nix }@globalArgs:
let
  inherit (builtins)
    attrValues baseNameOf fromJSON listToAttrs mapAttrs pathExists placeholder
    readDir readFile toFile toJSON trace;

  inherit (pkgs)
    bash coreutils euphenixYarnPackages glibcLocales gnused imagemagick infuse
    makeWrapper stdenv;

  inherit (pkgs.lib)
    assertMsg attrByPath concatMapStrings hasPrefix makeBinPath optional sort
    subtractLists;

  inherit (pkgs.rubyEnv) wrappedRuby;

in rec {
  pp = value: trace (toJSON value) value;
  compact = subtractLists [ null ];
  sortByRecent = sort (a: b: a.meta.date > b.meta.date);

  # we use our own derivation because we don't need all the overhead of stdenv
  # and this speeds up builds a lot.
  mkDerivation = givenArgs:
    derivation (givenArgs // {
      out = placeholder "out";
      system = builtins.currentSystem;
      builder = "${bash}/bin/bash";
      args = [
        "-e"
        (toFile "builder.sh" ''
          if [ -e .attrs.sh ]; then
            source .attrs.sh;
          fi

          eval "$buildCommand"
        '')
      ];
    });

  loadPosts = baseUrl: location:
    (attrValues (mapAttrs (k: v:
    let markdown = parseMarkdown "${location + "/${k}"}";
    in (markdown // { url = "${baseUrl}${markdown.meta.slug}.html"; }))
    (readDir location)));

  parseTemplates = dir:
    let
      generated = mkDerivation {
        name = "parseTemplates";
        PATH = makeBinPath [ wrappedRuby ];
        inherit dir;
        LOCALE_ARCHIVE = "${glibcLocales}/lib/locale/locale-archive";
        LC_ALL = "en_US.UTF-8";

        buildCommand = ''
          ruby ${./scripts/parse_templates.rb} "$dir" > $out
        '';
      };
    in fromJSON (readFile generated);

  cssDeps = src:
    let
      generated = mkDerivation {
        name = "cssDeps";
        PATH = makeBinPath [ wrappedRuby ];
        inherit src;
        LOCALE_ARCHIVE = "${glibcLocales}/lib/locale/locale-archive";
        LC_ALL = "en_US.UTF-8";

        buildCommand = ''
          ruby ${./scripts/css_deps.rb} "$src" > $out
        '';
      };
    in fromJSON (readFile generated);

  cssDepsFor = src: entryPoint:
    let allDeps = cssDeps src;
    in listToAttrs (map (v: {
      name = v;
      value = "${src + "/${v}"}";
    }) allDeps."${entryPoint}");

  parseMarkdown = src:
    fromJSON (readFile (mkDerivation {
      name = "md2Meta";
      PATH = makeBinPath [ wrappedRuby ];
      LOCALE_ARCHIVE = "${glibcLocales}/lib/locale/locale-archive";
      LC_ALL = "en_US.UTF-8";

      buildCommand = ''
        ruby ${./scripts/front_matter.rb} "${src}" > $out
      '';
    }));

  copyFiles = from: to:
    mkDerivation {
      name = "copyFiles";
      PATH = makeBinPath [ coreutils ];
      inherit from to;

      buildCommand = ''
        mkdir -p $out$to
        cp -r "$from"/* $out$to
      '';
    };

  mkFavicons = source:
    let
      convertPNG = size:
        "convert -background none ${source} -resize ${size}x${size}! +repage $out/favicons/favicon${size}.png";

      convertICO =
        "convert -background none ${source} -define icon:auto-resize=32,64 +repage ico:- > $out/favicons/favicon.ico";
    in mkDerivation {
      name = "favicons";
      PATH = makeBinPath [ coreutils imagemagick ];

      buildCommand = ''
        mkdir -p $out/favicons
        ${convertICO}
        ${convertPNG "32"}
        ${convertPNG "57"}
        ${convertPNG "72"}
        ${convertPNG "144"}
      '';
    };

  mkPostCSS = cssDir: fileName:
    let imports = cssDepsFor cssDir fileName;
    in mkDerivation {
      name = "mkPostCSS";
      __structuredAttrs = true;
      inherit imports fileName;
      PATH = "${coreutils}/bin:${euphenixYarnPackages}/node_modules/.bin";

      LOCALE_ARCHIVE = "${glibcLocales}/lib/locale/locale-archive";
      LC_ALL = "en_US.UTF-8";

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
    };

  mkRoutes = { variables, ... }@args:
    tmpl: page:
    let routeMaps = attrByPath [ "meta" "routeMaps" ] null page;
    in map (item:
    (mkRoute args) tmpl ({
      body = readFile (wrapBody args tmpl page item);
      imports = page.imports;
      meta = page.meta // item.meta // { route = item.url; };
    })) variables."${routeMaps}";

  mkRoute = { variables, cssCompiler, cssDir, layout, templateDir, ... }:
    tmpl: page:
    let
      metaData = (variables // page.meta // { inherit body; });

      style = if metaData ? css then {
        cssTag = ''<link rel="stylesheet" href="/css/${metaData.css}" />'';
      } else
        { };

      metaJSON = toFile "meta.json" (toJSON (metaData // style));

      compiledCSS =
        if metaData ? css then cssCompiler cssDir metaData.css else "";
      body = toFile "body.tmpl" page.body;
      definitions = concatMapStrings (f: ''-d "${f}" '') page.imports;
    in mkDerivation {
      name = "mkRoute-${baseNameOf tmpl}";
      PATH = makeBinPath [ coreutils infuse gnused ];
      imports = (map (i: toFile "__${i}" (readFile (templateDir + "/${i}")))
        page.imports);
      buildCommand = ''
        mkdir -p $out

        for imp in $imports; do
          filename=$(echo $imp | sed 's/.*-__//')
          cp $imp $filename
        done

        cp ${body} __body.tmpl
        sed 's!{{ yield }}!{{template "__body.tmpl" .}}!' ${layout} > __layout.tmpl
        ${if compiledCSS != "" then ''
          mkdir -p $out/css
          cp -r ${compiledCSS}/* $out/css
        '' else
          ""}
        infuse -f ${metaJSON} ${definitions} -d __body.tmpl __layout.tmpl -o result

        install -m 0644 -D result "$out${page.meta.route}"
      '';
    };

  wrapBody = { variables, templateDir, ... }:
    tmpl: outer: inner:
    let
      body = toFile "body.tmpl" outer.body;
      metadata = toFile "meta.json" (toJSON (variables // inner));
      definitions = concatMapStrings (f: ''-d "${f}" '') outer.imports;
    in mkDerivation {
      name = "wrapBody-${baseNameOf tmpl}";
      PATH = with pkgs; makeBinPath [ coreutils infuse gnused ];
      imports = (map (i: toFile "__${i}" (readFile (templateDir + "/${i}")))
        outer.imports);
      buildCommand = ''
        for imp in $imports; do
          filename=$(echo $imp | sed 's/.*-__//')
          cp $imp $filename
        done

        cp ${body} __body.tmpl
        infuse -f ${metadata} ${definitions} __body.tmpl -o $out
      '';
    };

  assertRoute = route: file:
    assert (assertMsg (hasPrefix "/" route)
    "route in ${file} must begin with a slash '/'");
    true;

  routes = { templateDir, ... }@args:
    let
      parsedTemplates = parseTemplates templateDir;
      compiledTemplates = mapAttrs (k: v:
        let
          route = attrByPath [ "meta" "route" ] null v;
          routeMaps = attrByPath [ "meta" "routeMaps" ] null v;
        in if route != null && assertRoute route k then
          ((mkRoute args) (templateDir + "/${k}") v)
        else if routeMaps != null then
          ((mkRoutes args) (templateDir + "/${k}") v)
        else
          null) parsedTemplates;
    in compact (attrValues compiledTemplates);

  build = { rootDir, cssDir ? null, templateDir ? null, staticDir ? null
    , favicon ? null, variables ? null, layout
    , cssCompiler ? null, extraPargs ? null }@givenBuildArgs:

    let
      buildArgs = {
        cssDir = rootDir + "/css";
        templateDir = rootDir + "/templates";
        staticDir = rootDir + "/static";
        variables = { };
        cssCompiler = mkPostCSS;
        favicon = null;
        extraParts = [ ];
      } // givenBuildArgs;

      inherit (buildArgs) favicon staticDir extraParts;
    in mkDerivation {
      name = "euphenix";

      parts = [ (routes buildArgs) ]
        ++ (optional (pathExists staticDir) (copyFiles staticDir "/"))
        ++ (optional (favicon != null) (mkFavicons favicon)) ++ extraParts;

      PATH = makeBinPath [ coreutils ];

      buildCommand = ''
        mkdir -p $out

        for part in $parts; do
          chmod u+rw -R $out
          cp -r $part/* $out
        done
      '';
    };

  euphenix = stdenv.mkDerivation {
    pname = "euphenix";
    version = "0.0.1";
    nativeBuildInputs = [ makeWrapper wrappedRuby ];
    phases = [ "installPhase" ];
    installPhase = ''
      mkdir -p $out/bin
      cp ${./bin/euphenix} $out/bin/euphenix
      patchShebangs $out/bin/euphenix
    '';
  };
}
