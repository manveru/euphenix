let
  euphenix = (import ./.. {}).extend (self: super: {
    parseMarkdown =
      super.parseMarkdown.override { flags = { prismjs = true; }; };
  });

  inherit (euphenix) build mkPostCSS cssTag parseMarkdown copyFile;
  inherit (euphenix.lib) optionalString;
  inherit (euphenix.pkgs) fetchurl;

  prism-okaida = fetchurl {
    name = "prism-okaidia.css";
    url = https://cdn.jsdelivr.net/npm/prismjs@1.17.1/themes/prism-okaidia.css;
    sha256 = "0nzwj6smwq6nyg56mz7zp15lwiiqcnrfp1w6p1f2hllcwxsiqwfg";
  };

  prismjs = fetchurl {
    name = "prism.js";
    url = https://cdn.jsdelivr.net/npm/prismjs@1.17.1/prism.js;
    sha256 = "0x1qfblhvdqv4nmzzxki3macfc5q69ag0p2j632996byhqm4an44";
  };

  prism-autoloader = fetchurl {
    name = "prism-autoloader.min.js";
    url = https://cdn.jsdelivr.net/npm/prismjs@1.17.1/plugins/autoloader/prism-autoloader.min.js;
    sha256 = "0zzrvq32y61i5qv3mv5aq0p446m1779gf08nigp9fgaklv5impw6";
  };
in build {
  src = ./.;
  favicon = ./static/favicon.svg;

  extraParts = [
    ( copyFile prism-okaida "/css/prism-okaida.css" )
    ( copyFile prismjs "/js/prism.js" )
    ( copyFile prism-autoloader "/js/prism-autoloader.min.js" )
  ];

  routes = {
    "/index.html" = {
       template = [ ./templates/layout.html ./templates/index.html ];
       variables = {
         siteName = "EupheNix";
         title = "This is EupheNix!";
         css = cssTag (mkPostCSS ./css);
         id = "home";
         liveJS = optionalString (( __getEnv "LIVEJS" ) != "") ''<script src="/js/live.js"></script>'';
       };
    };

    "/docs/index.html" = {
      template = [ ./templates/layout.html ./templates/docs.html ];
       variables = {
         siteName = "EupheNix";
         title = "Documentation";
         css = cssTag (mkPostCSS ./css);
         id = "home";
         liveJS = optionalString (( __getEnv "LIVEJS" ) != "") ''<script src="/js/live.js"></script>'';
         manual = parseMarkdown ../README.md;
       };
    };
  };
}
