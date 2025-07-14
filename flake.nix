{
  description = "A flake for the HighLite AppImage";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable"; # or a specific version
  };

  outputs = { self, nixpkgs }: {
    packages.x86_64-linux.highlite =
      let
        version = "1.4.1";
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
      in
      pkgs.stdenv.mkDerivation {
        pname = "highlite";
        inherit version;
        src = pkgs.fetchurl {
          url = "https://github.com/Highl1te/HighliteDesktop/releases/download/v${version}/HighLite-${version}.AppImage";
          sha256 = "08fhpjrs9skv1vsnvyilfzss2m01qmqwh6dzqjmhdnv22h30bimm";
        };
        nativeBuildInputs = [ pkgs.makeWrapper ];
        unpackPhase = "true";
        installPhase = ''
          mkdir -p $out/bin $out/share/highlite
          cp $src $out/share/highlite/HighLite-${version}.AppImage
          chmod +x $out/share/highlite/HighLite-${version}.AppImage
          makeWrapper ${pkgs.appimage-run}/bin/appimage-run $out/bin/highlite \
            --add-flags "$out/share/highlite/HighLite-${version}.AppImage"
        '';
        meta = with pkgs.lib; {
          description = "HighLite Desktop Application";
          homepage = "https://github.com/Highl1te/HighliteDesktop";
          license = licenses.gpl3;
          maintainers = with maintainers; [ Ashes ];
        };
      };

    defaultPackage.x86_64-linux = self.packages.x86_64-linux.highlite;

    apps.x86_64-linux.update = {
      type = "app";
      program = toString (nixpkgs.legacyPackages.x86_64-linux.writeShellScript "update-flake" ''
        set -euo pipefail

        # Get latest release tag
        RELEASE_TAG=$(curl -s https://api.github.com/repos/Highl1te/HighliteDesktop/releases/latest | jq -r .tag_name)
        VERSION=$(echo "$RELEASE_TAG" | sed 's/^v//')
        URL="https://github.com/Highl1te/HighliteDesktop/releases/download/v$VERSION/HighLite-$VERSION.AppImage"
        # Prefetch sha256
        SHA256=$(nix-prefetch-url --type sha256 "$URL")

        # Update flake.nix in place
        sed -i "s/version = \".*\";/version = \"$VERSION\";/" flake.nix
        sed -i "s|sha256 = \".*\";|sha256 = \"$SHA256\";|" flake.nix

        echo "flake.nix updated to version $VERSION with sha256 $SHA256"
      '');
    };

    devShells.x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.mkShell {
      buildInputs = with nixpkgs.legacyPackages.x86_64-linux; [ curl jq nix-prefetch-url ];
    };
  };
}
