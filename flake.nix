{
  description = "Add nils for the convenience of editting Nix files";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells = {
          with-nil = pkgs.mkShell {
            name = "nix-dev-shell-with-nil";

            buildInputs = [ pkgs.nil ];

            shelllHook = ''
              echo "Welcome to the Nix development shell with nil installed!"
            '';
          };
          default = self.devShells.${system}.with-nil;
        };
      }
    );
}
