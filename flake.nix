{
  description = "A flake for the HighLite AppImage";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable"; # or a specific version
  };

  outputs = { self, nixpkgs }: {
    packages.x86_64-linux.highlite = 
      let
        version = "1.4.0";
      in
      with nixpkgs.legacyPackages.x86_64-linux; appimageTools.wrapType2 {
        pname = "highlite";
        inherit version;
        src = fetchurl {
          url = "https://github.com/Highl1te/HighliteDesktop/releases/download/v${version}/HighLite-${version}.AppImage";
          sha256 = "Y7Ocp9HsEyT4LKMBLx3BhpSgodYKJ564fj7VfFqXLIQ=";
        };
        meta = with lib; {
          description = "HighLite Desktop Application";
          homepage = "https://github.com/Highl1te/HighliteDesktop";
          license = licenses.gpl3;
          maintainers = with maintainers; [ Ashes ];
        };
      };

    defaultPackage.x86_64-linux = self.packages.x86_64-linux.highlite;
  };
}
