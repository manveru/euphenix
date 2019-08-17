let
  euphenix = import ./.. {};
in euphenix.build {
  rootDir = ./.;
  layout = ./templates/layout.tmpl;
  favicon = ./static/favicon.svg;
  variables = {
    siteName = "EupheNix";
    liveJS = (builtins.getEnv "LIVEJS") != "";
    manual = euphenix.parseMarkdown { prismjs = true; } ../README.md;
  };
}
