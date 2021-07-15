{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = [
    # keep this line if you use bash
    pkgs.bashInteractive
  ];

  shellHook = ''
    export CYPRESS_INSTALL_BINARY=0
    export CYPRESS_RUN_BINARY=${pkgs.cypress}/bin/Cypress
  '';
}
