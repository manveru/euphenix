#!/usr/bin/env bash

IANA_PATH="$(nix-build --no-out-link '<nixpkgs>' -A iana-etc)"
cp "${IANA_PATH}/etc/protocols" /etc/
cp "${IANA_PATH}/etc/services" /etc/

CACERT_PATH="$(nix-build --no-out-link '<nixpkgs>' -A cacert)"
cp -r "${CACERT_PATH}/etc/ssl" /etc/

nix-env -f '<nixpkgs>' -iA gnutar gzip
nix-env -iA cachix -f https://cachix.org/api/v1/install

export USER=root
cachix use manveru

cd site/example
nix-build
