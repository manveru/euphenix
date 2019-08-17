## Installation

You will need to have [Nix](https://nixos.org/nix) installed on your system to
be able to use EupheNix anyway, so once you have that you can easily go to the
next step.

To build the executable, you can run:

```shell-session
nix build -f https://github.com/manveru/euphenix/archive/master.tar.gz \
  euphenix --out-link euphenix
```

It will then be located in `./euphenix/bin/euphenix`. If you want to add it to your user profile, use:

```shell-session
nix-env -if ./euphenix
```

For declarative installation, use this instead:

```nix
let
  euphenixSource = import (fetchTarball {
    url = https://github.com/manveru/euphenix/archive/master.tar.gz;
  }) { };
in euphenixSource.euphenix
```

And then, depending on your system add `euphenixSource.eupehnix` to your
`environment.systemPackages` (on NixOS) or `home.packages` (in case of
home-manager)

Installation on other systems is left as an exercise for the reader.
