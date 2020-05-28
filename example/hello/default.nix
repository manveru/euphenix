{ pkgs ? import ../../nix {} }:
let
  euphenix = import ../.. { };
  inherit (euphenix) build mkPostCSS cssTag;

  globalVariables = {
    siteName = "Hello";
    css = cssTag (mkPostCSS ./css);
  };

  mkRoute = tmpl: vars: {
    template = [ ./templates/layout.html tmpl ];
    variables = globalVariables // vars;
  };
in build {
  src = ./.;

  routes = {
    "/index.html" = mkRoute ./templates/index.html { title = "Hello World!"; };
  };
}
