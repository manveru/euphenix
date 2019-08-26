let
  euphenix = import ../. {};
in euphenix.build {
  rootDir = ../example;
  layout = ../example/templates/layout.html;
}
