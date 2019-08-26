FROM lnl7/nix:2.2.2

ENV USER=root

RUN IANA_PATH="$(nix-build --no-out-link '<nixpkgs>' -A iana-etc)" \
 && cp "${IANA_PATH}/etc/protocols" /etc/ \
 && cp "${IANA_PATH}/etc/services" /etc/

RUN CACERT_PATH="$(nix-build --no-out-link '<nixpkgs>' -A cacert)" \
 && cp -r "${CACERT_PATH}/etc/ssl" /etc/

RUN nix-env -f '<nixpkgs>' -iA gnutar gzip
RUN nix-env -iA cachix -f https://cachix.org/api/v1/install \
 && cachix use manveru

COPY . /root/github/manveru/euphenix

RUN cd /root/github/manveru/euphenix \
 && nix-build ./ci.nix -A euphenix
