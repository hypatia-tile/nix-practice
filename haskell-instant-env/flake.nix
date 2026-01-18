{
  description = "Instant Haskell dev env (research + CP)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        # Pick a compiler once. Change if you want.
        hp = pkgs.haskell.packages.ghc910; # e.g. ghc96, ghc98, ghc910, etc.

        commonTools = [
          hp.ghc
          hp.cabal-install
          hp.haskell-language-server
          hp.ghcid
          hp.ormolu
          hp.hlint

          # Helpful general tools
          pkgs.git
          pkgs.gnumake
        ];

        cpLibs = [
          # Common CP libraries (available in the environment for repl / scripts)
          hp.bytestring
          hp.text
          hp.containers
          hp.vector
          hp.primitive
          hp.unordered-containers
          hp.attoparsec
        ];
      in
      {
        devShells = {
          # For language feature experiments / theory playground.
          research = pkgs.mkShell {
            name = "hs-research";
            packages = commonTools ++ [
              # Optional extras for profiling / debugging / docs style work
              pkgs.time
              pkgs.hyperfine
              pkgs.which
            ];

            shellHook = ''
              echo "Haskell research shell: ghc=$(ghc --numeric-version), cabal=$(cabal --numeric-version)"
              echo "Try:  cabal repl  |  ghci  |  ghcid --command 'cabal repl'"
            '';
          };

          # Competitive programming oriented.
          cp = pkgs.mkShell {
            name = "hs-cp";
            packages = commonTools ++ cpLibs ++ [
              pkgs.python3 # sometimes useful for generators/checkers
            ];

            shellHook = ''
              echo "Haskell CP shell: ghc=$(ghc --numeric-version)"
              echo "Suggested flags: -O2 -Wall -Wno-unused-do-bind -rtsopts"
              echo "Try: ghc -O2 Main.hs && ./Main < input.txt"
            '';
          };

          # Default shell if you do `nix develop`
          default = self.devShells.${system}.research;
        };
      });
}
