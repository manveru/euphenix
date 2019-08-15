{ lib, mkRoute, wrapBody }:
let inherit (builtins) readFile;
in { variables, ... }@args:
tmpl: page:
let routeMaps = lib.attrByPath [ "meta" "routeMaps" ] null page;
in map (item:
  (mkRoute args) tmpl ({
    body = readFile (wrapBody args tmpl page item);
    imports = page.imports;
    meta = page.meta // item.meta // { route = item.url; };
  })) variables."${routeMaps}"
