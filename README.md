# EupheNix

This is a static site generator that uses [Nix](https://nixos.org/nix),
[Ruby](https://ruby-lang.org), and [infuse](https://github.com/jucardi/infuse).

My goal was to ensure reproducible site builds, and ease of use. The prior is
provided by Nix, and the latter is of course subjective.

## History

I started this as a proof of concept, and out of frustration with existing site
generators like Hugo or Hakyll.

It's still at an early stage, but I think it's good enough for public
consumption after the 4th rewrite.

## Similar Projects

### Styx

This is the closest in spirit, but heavily relies on evaluating Nix within Nix,
which leads to poor performance. I also didn't need half of the features that it
provides, since I usually write my sites in plain HTML and CSS and don't use
common themes.
