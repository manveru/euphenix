{ yants, parseMarkdown }:

let
  inherit (builtins) attrValues mapAttrs readDir;

  mdIn = yants.struct "markdownIn" {
    body = yants.string;
    meta = yants.attrs yants.any;
    teaser = yants.string;
  };

  mdOut = yants.struct "markdownOut" {
    body = yants.string;
    meta = yants.attrs yants.any;
    teaser = yants.string;
    url = yants.string;
  };

  parse = yants.defun [ yants.path yants.string mdIn ]
    (location: file: parseMarkdown ( location + "/${file}" ));

  withUrl = yants.defun [ yants.string mdIn mdOut ] (baseUrl: markdown:
    markdown // {
      url = "${baseUrl}${markdown.meta.slug}.html";
    });

in yants.defun [
  yants.string
  yants.path
  (yants.list mdOut)
] (baseUrl: location:
  let
    files = readDir location;
    loadPost = yants.defun [ yants.string yants.string mdOut ]
      (file: type: withUrl baseUrl (parse location file));
  in attrValues (mapAttrs loadPost files))
