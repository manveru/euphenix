let
  euphenix = import ../.. { };
  inherit (euphenix) build mkPostCSS cssTag;
in build {
  src = ./.;

  routes = {
    "/index.html" = {
      template = [ ./templates/layout.html ./templates/index.html ];
      variables = {
        title = "Hello World!";
        siteName = "Hello";
        css = cssTag (mkPostCSS ./css);
      };
    };
  };
}
