{ parseMarkdown }:
let inherit (builtins) attrValues mapAttrs readDir;
in baseUrl: location:
(attrValues (mapAttrs (k: v:
  let markdown = parseMarkdown "${location + "/${k}"}";
  in (markdown // { url = "${baseUrl}${markdown.meta.slug}.html"; }))
  (readDir location)))
