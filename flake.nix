{
  description = "Dev env flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
  };
  outputs = {
    self,
    nixpkgs,
    flake-utils,
    pre-commit-hooks,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};
      checks = {
        pre-commit-check = pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
          };
        };
      };
    in {
      devShell = pkgs.mkShell {
        inherit (checks.pre-commit-check) shellHook;
        buildInputs = [
          pkgs.wasmer
          pkgs.wabt
          pkgs.nodejs_23
        ];
      };
    });
}
