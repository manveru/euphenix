{ pkgs ? import ../nix { } }:
let
  euphenix = (import ./.. { }).extend (self: super: {
    parseMarkdown =
      super.parseMarkdown.override { flags = { prismjs = true; }; };
  });

  inherit (euphenix) build mkPostCSS cssTag parseMarkdown copyFile;
  inherit (pkgs.lib) optionalString hasSuffix;
  inherit (pkgs) fetchurl;

  jsdelivr = [
    {
      url =
        "https://cdn.jsdelivr.net/npm/prismjs@1.17.1/themes/prism-okaidia.css";
      sha256 = "0nzwj6smwq6nyg56mz7zp15lwiiqcnrfp1w6p1f2hllcwxsiqwfg";
    }
    {
      url = "https://cdn.jsdelivr.net/npm/prismjs@1.17.1/prism.js";
      sha256 = "0x1qfblhvdqv4nmzzxki3macfc5q69ag0p2j632996byhqm4an44";
    }
    {
      url =
        "https://cdn.jsdelivr.net/npm/prismjs@1.17.1/plugins/autoloader/prism-autoloader.min.js";
      sha256 = "0zzrvq32y61i5qv3mv5aq0p446m1779gf08nigp9fgaklv5impw6";
    }
  ];

  jsdelivrParts = map (o:
    let
      name = baseNameOf o.url;
      src = fetchurl ({ inherit name; } // o);
      dst = if hasSuffix ".js" o.url then "/js" else "/css";
    in copyFile src "${dst}/${name}") jsdelivr;

  variables = {
    siteName = "EupheNix";
    css = cssTag (mkPostCSS ./css);
    liveJS = optionalString ((__getEnv "LIVEJS") != "")
      ''<script src="/js/live.js"></script>'';
    manual = parseMarkdown ../README.md;
  };

  mkRoute = tmpl: vars: {
    template = [ ./templates/layout.html tmpl ];
    variables = variables // vars;
  };
in build {
  src = ./.;
  favicon = ./static/favicon.svg;

  extraParts = jsdelivrParts;

  routes = {
    "/index.html" = mkRoute ./templates/index.html {
      title = "This is EupheNix!";
      id = "home";
    };

    "/docs/index.html" = mkRoute ./templates/docs.html {
      title = "Documentation";
      id = "docs";
    };
  };
}
