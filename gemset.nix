{
  ast = {
    groups = [ "default" "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "184ssy3w93nkajlz2c70ifm79jp3j737294kbc5fjw69v1w0n9x7";
      type = "gem";
    };
    version = "2.4.0";
  };
  bacon = {
    groups = [ "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1f06gdj77bmwzc1k5iragl1595hbn67yc7sqvs56ca8plrr2vmai";
      type = "gem";
    };
    version = "1.2.0";
  };
  cmdparse = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0byw9hhydml5lrlwgch3865r849h1j5xhwcr004kwn4y6qlq5wlb";
      type = "gem";
    };
    version = "3.0.4";
  };
  ffi = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "06mvxpjply8qh4j3fj9wh08kdzwkbnvsiysh0vrhlk5cwxzjmblh";
      type = "gem";
    };
    version = "1.11.1";
  };
  jaro_winkler = {
    groups = [ "default" "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1930v0chc1q4fr7hn0y1j34mw0v032a8kh0by4d4sbz8ksy056kf";
      type = "gem";
    };
    version = "1.5.3";
  };
  liquid = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0zhg5ha8zy8zw9qr3fl4wgk4r5940n4128xm2pn4shpbzdbsj5by";
      type = "gem";
    };
    version = "4.0.3";
  };
  listen = {
    dependencies = [ "rb-fsevent" "rb-inotify" "ruby_dep" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "01v5mrnfqm6sgm8xn2v5swxsn1wlmq7rzh2i48d4jzjsc7qvb6mx";
      type = "gem";
    };
    version = "3.1.5";
  };
  parallel = {
    groups = [ "default" "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1x1gzgjrdlkm1aw0hfpyphsxcx90qgs3y4gmp9km3dvf4hc4qm8r";
      type = "gem";
    };
    version = "1.17.0";
  };
  parser = {
    dependencies = [ "ast" ];
    groups = [ "default" "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1pnks149x0fzgqiw53qlmvcd8bi746cxdw03sjljby5s97p1fskn";
      type = "gem";
    };
    version = "2.6.3.0";
  };
  rainbow = {
    groups = [ "default" "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0bb2fpjspydr6x0s8pn1pqkzmxszvkfapv0p4627mywl7ky4zkhk";
      type = "gem";
    };
    version = "3.0.0";
  };
  rb-fsevent = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1lm1k7wpz69jx7jrc92w3ggczkjyjbfziq5mg62vjnxmzs383xx8";
      type = "gem";
    };
    version = "0.10.3";
  };
  rb-inotify = {
    dependencies = [ "ffi" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1fs7hxm9g6ywv2yih83b879klhc4fs8i0p9166z795qmd77dk0a4";
      type = "gem";
    };
    version = "0.10.0";
  };
  redcarpet = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0skcyx1h8b5ms0rp2zm3ql6g322b8c1adnkwkqyv7z3kypb4bm7k";
      type = "gem";
    };
    version = "3.5.0";
  };
  rubocop = {
    dependencies = [
      "jaro_winkler"
      "parallel"
      "parser"
      "rainbow"
      "ruby-progressbar"
      "unicode-display_width"
    ];
    groups = [ "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0wpyass9qb2wvq8zsc7wdzix5xy2ldiv66wnx8mwwprz2dcvzayk";
      type = "gem";
    };
    version = "0.74.0";
  };
  ruby-progressbar = {
    groups = [ "default" "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1k77i0d4wsn23ggdd2msrcwfy0i376cglfqypkk2q77r2l3408zf";
      type = "gem";
    };
    version = "1.10.1";
  };
  ruby_dep = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1c1bkl97i9mkcvkn1jks346ksnvnnp84cs22gwl0vd7radybrgy5";
      type = "gem";
    };
    version = "1.5.0";
  };
  unicode-display_width = {
    groups = [ "default" "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "08kfiniak1pvg3gn5k6snpigzvhvhyg7slmm0s2qx5zkj62c1z2w";
      type = "gem";
    };
    version = "1.6.0";
  };
  webrick = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "09nxnxm7xgqh07krjhqniwqdr517sshz2cy2b8pfmnmaa9rdqnjs";
      type = "gem";
    };
    version = "1.4.2";
  };
  webrick-websocket = {
    dependencies = [ "webrick" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1ibsimnzkrizq9pxf0897pz1xvil5j323dsw8lfjhj8fvk5f7dkm";
      type = "gem";
    };
    version = "0.0.2";
  };
}
