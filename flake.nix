{
  nixConfig = {
    extra-substituters = "https://cachix.cachix.org";
    extra-trusted-public-keys = "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM=";
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

    flake-parts.url = "github:hercules-ci/flake-parts";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    make-shell = {
      url = "github:nicknovitski/make-shell";

      inputs.flake-compat.follows = "flake-compat";
    };

    git-hooks-nix = {
      url = "github:cachix/git-hooks.nix";

      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-compat.follows = "flake-compat";
    };

    flake-compat.url = "github:NixOS/flake-compat";
  };

  outputs = inputs @ {flake-parts, ...}:
  # https://flake.parts/module-arguments.html
    flake-parts.lib.mkFlake {inherit inputs;} ({...}: {
      imports = [
        inputs.make-shell.flakeModules.default
        inputs.treefmt-nix.flakeModule
        inputs.git-hooks-nix.flakeModule
      ];
      systems = [
        # systems for which you want to build the `perSystem` attributes
        "x86_64-linux"
        # ...
      ];
      perSystem = {
        lib,
        pkgs,
        ...
      }: let
        faedupes = pkgs.stdenv.mkDerivation {
          name = "faedupes";
          src = ./.;
          propagatedBuildInputs = [pkgs.python3];

          nativeBuildInputs = [pkgs.makeWrapper];

          installPhase = ''
            runHook preInstall

            sp="$out/${pkgs.python3.sitePackages}"
            bin="$out/bin"
            mkdir -p "$sp" "$bin"
            install -m644 faedupes "$sp"

            makeWrapper "${lib.getExe' pkgs.python3 "python"}" $bin/faedupes --add-flags "$sp/faedupes"

            runHook postInstall
          '';

          meta = {
            description = "Fae's Duplicate Finder";
            homepage = "https://github.com/haku/faedupes";
            sourceProvenance = lib.sourceTypes.fromSource;
            mainProgram = "faedupes";
          };
        };
      in {
        treefmt = {
          flakeCheck = true;
          flakeFormatter = true;

          # Enable the Nix formatter
          programs.alejandra.enable = true;
          programs.statix.enable = true;

          programs.ruff-format = {
            enable = true;
            lineLength = 180;
            includes = ["faedupes"];
          };
          programs.ruff-check = {
            enable = true;
            includes = ["faedupes"];
            extendSelect = [
              "A"
              "ANN"
              "ARG"
              "ASYNC"
              "B"
              "BLE"
              "C"
              "C4"
              "C90"
              "COM"
              "D"
              "DOC"
              "DTZ"
              "E"
              "EM"
              "EXE"
              "F"
              "F"
              "FA"
              "FBT"
              "FIX"
              "FLY"
              "FURB"
              "G"
              "I"
              "ICN"
              "INP"
              "INT"
              "ISC"
              "LOG"
              "N"
              "PERF"
              "PGH"
              "PIE"
              "PL"
              "PTH"
              "PYI"
              "Q"
              "Q"
              "RET"
              "RSE"
              "RUF"
              "S"
              "SIM"
              "SLF"
              "T10"
              "T20"
              "TC"
              "TD"
              "TID"
              "TRY"
              "UP"
              "W"
              "W"
              "YTT"
            ];
          };
        };

        pre-commit = {
          check.enable = true;
          settings = {
            enable = true;
            hooks = {
              check-added-large-files.enable = true;
              check-builtin-literals.enable = true;
              check-case-conflicts.enable = true;
              check-docstring-first.enable = true;
              check-executables-have-shebangs.enable = true;
              check-json.enable = true;
              check-merge-conflicts.enable = true;
              check-python.enable = true;
              check-shebang-scripts-are-executable.enable = true;
              check-symlinks.enable = true;
              check-vcs-permalinks.enable = true;
              fix-byte-order-marker.enable = true;

              typos.enable = true;

              deadnix.enable = true;
              flake-checker.enable = true;
            };
          };
        };

        make-shells.default = {
          name = "Faedupes";
          packages = [
            faedupes
            pkgs.python3
          ];
        };

        packages = {
          inherit faedupes;
          default = faedupes;
        };

        apps.faedupes = {
          program = faedupes;
        };
      };
    });
}
