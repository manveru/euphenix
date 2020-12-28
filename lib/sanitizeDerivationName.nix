{ lib }:
/* Creates a valid derivation name from a potentially invalid one.

   Type: sanitizeDerivationName :: String -> String

   Example:
     sanitizeDerivationName "../hello.bar # foo"
     => "-hello.bar-foo"
     sanitizeDerivationName ""
     => "unknown"
     sanitizeDerivationName pkgs.hello
     => "-nix-store-2g75chlbpxlrqn15zlby2dfh8hr9qwbk-hello-2.10"
*/
string:
lib.pipe string [
  # Get rid of string context. This is safe under the assumption that the
  # resulting string is only used as a derivation name
  builtins.unsafeDiscardStringContext
  # Strip all leading "."
  (x: builtins.elemAt (builtins.match "\\.*(.*)" x) 0)
  # Split out all invalid characters
  # https://github.com/NixOS/nix/blob/2.3.2/src/libstore/store-api.cc#L85-L112
  # https://github.com/NixOS/nix/blob/2242be83c61788b9c0736a92bb0b5c7bbfc40803/nix-rust/src/store/path.rs#L100-L125
  (builtins.split "[^[:alnum:]+._?=-]+")
  # Replace invalid character ranges with a "-"
  (lib.concatMapStrings (s: if lib.isList s then "-" else s))
  # Limit to 211 characters (minus 4 chars for ".drv")
  (x: lib.substring (lib.max (lib.stringLength x - 207) 0) (-1) x)
  # If the result is empty, replace it with "unknown"
  (x: if lib.stringLength x == 0 then "unknown" else x)
]
