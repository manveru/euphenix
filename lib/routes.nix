{ lib, mkRoute, mkRoutes, parseTemplates }:
let
  inherit (builtins) mapAttrs attrValues;
  assertRoute = route: file:
    assert (lib.assertMsg (lib.hasPrefix "/" route)
      "route in ${file} must begin with a slash '/'");
    true;
in { templateDir, ... }@args:
let
  parsedTemplates = parseTemplates templateDir;
  compiledTemplates = mapAttrs (k: v:
    let
      route = lib.attrByPath [ "meta" "route" ] null v;
      routeMaps = lib.attrByPath [ "meta" "routeMaps" ] null v;
    in if route != null && assertRoute route k then
      ((mkRoute args) (templateDir + "/${k}") v)
    else if routeMaps != null then
      ((mkRoutes args) (templateDir + "/${k}") v)
    else
      null) parsedTemplates;
in lib.subtractLists [ null ] (attrValues compiledTemplates)
