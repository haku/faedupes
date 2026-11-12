{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    flake-compat.url = "github:NixOS/flake-compat";
    flake-parts.url = "github:hercules-ci/flake-parts";
    make-shell = {
      url = "github:nicknovitski/make-shell";
      inputs.flake-compat.follows = "flake-compat";
    };
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} ({...}: {
      imports = [
        inputs.make-shell.flakeModules.default
      ];
      systems = [ "x86_64-linux" ];
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

            makeWrapper "${lib.getExe pkgs.python3}" $bin/faedupes --add-flags "$sp/faedupes"

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
