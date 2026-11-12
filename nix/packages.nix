{ inputs, ... }:
{
  perSystem = { pkgs, lib, ... }:
  let
    faedupes = pkgs.stdenv.mkDerivation rec {
      name = "faedupes";
      src = ./..;
      propagatedBuildInputs = [pkgs.python3];
      nativeBuildInputs = [pkgs.makeWrapper];
      installPhase = ''
        runHook preInstall

        sp="$out/${pkgs.python3.sitePackages}"
        bin="$out/bin"
        mkdir -p "$sp" "$bin"
        install -m644 ./faedupes "$sp"

        makeWrapper "${lib.getExe pkgs.python3}" $bin/faedupes --add-flags "$sp/faedupes"

        runHook postInstall
      '';
      meta = {
        description = "Fae's Duplicate Finder";
        homepage = "https://github.com/haku/faedupes";
        sourceProvenance = lib.sourceTypes.fromSource;
        mainProgram = name;
      };
    };
  in {
    packages = {
      inherit faedupes;
      default = faedupes;
    };

    apps.faedupes = {
      program = faedupes;
    };

    make-shells.default = {
      name = "Faedupes";
      packages = [
        faedupes
        pkgs.python3
      ];
    };
  };
}
