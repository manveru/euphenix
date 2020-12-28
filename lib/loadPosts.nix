{ yants, parseMarkdown }:

let
  inherit (builtins) attrValues mapAttrs readDir;
  inherit (yants) struct string attrs any defun path list;

  mdIn = struct "markdownIn" {
    body = string;
    meta = attrs any;
    teaser = string;
  };

  mdOut = struct "markdownOut" {
    body = string;
    meta = attrs any;
    teaser = string;
    url = string;
  };

  parse = defun [ path string mdIn ]
    (location: file: parseMarkdown (location + "/${file}"));

  withUrl = defun [ string mdIn mdOut ] (baseUrl: markdown:
    markdown // {
      url = "${baseUrl}${markdown.meta.slug}.html";
    });

in defun [ string path (list mdOut) ] (baseUrl: location:
  let
    files = readDir location;
    loadPost = defun [ string string mdOut ]
      (file: type: withUrl baseUrl (parse location file));
  in attrValues (mapAttrs loadPost files))
