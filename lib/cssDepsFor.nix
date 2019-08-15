{ cssDeps }:
let inherit (builtins) listToAttrs;
in src: entryPoint:
let allDeps = cssDeps src;
in listToAttrs (map (v: {
  name = v;
  value = "${src + "/${v}"}";
}) allDeps."${entryPoint}")
