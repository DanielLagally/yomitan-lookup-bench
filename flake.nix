{
  description = "Build a cargo project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    crane.url = "github:ipetkov/crane";

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      nixpkgs,
      crane,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        craneLib = crane.mkLib pkgs;

        # Every implementation is a standalone Cargo workspace with its own
        # profile and lock file. Its only link to the others is bench/api.
        mkImplementation =
          name:
          let
            root = ./. + "/implementations/${name}";
            src = pkgs.lib.fileset.toSource {
              root = ./.;
              fileset = pkgs.lib.fileset.unions [
                (craneLib.fileset.commonCargoSources root)
                (craneLib.fileset.commonCargoSources ./bench/api)
                (root + "/Cargo.lock")
                ./bench/Cargo.toml
              ];
            };
            commonArgs = {
              inherit src;
              strictDeps = true;
              pname = name;
              version = "0.1.0";
              cargoLock = root + "/Cargo.lock";
              sourceRoot = "source/implementations/${name}";
            };
            cargoArtifacts = craneLib.buildDepsOnly commonArgs;
            package = craneLib.buildPackage (commonArgs // { inherit cargoArtifacts; });
          in
          {
            inherit package;
            checks = {
              "${name}-clippy" = craneLib.cargoClippy (
                commonArgs
                // {
                  inherit cargoArtifacts;
                  cargoClippyExtraArgs = "--all-targets -- --deny warnings";
                }
              );
              "${name}-fmt" = craneLib.cargoFmt (commonArgs // { inherit src; });
            };
          };

        implementationNames = [
          "claude"
          "local-model"
          "plebs"
        ];
        implementations = pkgs.lib.genAttrs implementationNames mkImplementation;
      in
      {
        checks = pkgs.lib.concatMapAttrs (_: i: i.checks) implementations;

        packages = pkgs.lib.mapAttrs (_: i: i.package) implementations;

        devShells.default = craneLib.devShell {
          packages = [
            pkgs.perf
            pkgs.cargo-flamegraph
            pkgs.cargo-show-asm
            pkgs.hyperfine
            pkgs.valgrind
            pkgs.gdb
            pkgs.taplo
          ];
        };
      }
    );
}
