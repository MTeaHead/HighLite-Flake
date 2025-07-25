{
  description = "A flake for the HighLite AppImage";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable"; # or a specific version
  };

  outputs = { self, nixpkgs }: 
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      version = "1.4.4";
      icon = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/Highl1te/HighliteDesktop/main/build/icon.png";
        sha256 = "0imbsn2s0h4k5b7a3z8rzhnzhxckm571lz52xyjrwbrqiv2406nw"; 
      };
    in
    {
      packages.x86_64-linux.highlite = pkgs.stdenv.mkDerivation {
        pname = "highlite";
        inherit version;
        src = pkgs.fetchurl {
          url = "https://github.com/Highl1te/HighliteDesktop/releases/download/v${version}/HighLite-${version}.AppImage";
          sha256 = "1a92fa6dbsccw2gnqg0ciqimg1k0i5h56yah9hy8xp3rfxajqph6";
        };
        nativeBuildInputs = [ pkgs.makeWrapper ];
        unpackPhase = "true";
        installPhase = ''
          mkdir -p $out/bin $out/share/highlite
          cp $src $out/share/highlite/HighLite-${version}.AppImage
          chmod +x $out/share/highlite/HighLite-${version}.AppImage
          makeWrapper ${pkgs.appimage-run}/bin/appimage-run $out/bin/highlite \
            --add-flags "$out/share/highlite/HighLite-${version}.AppImage"
          # Install icon
          mkdir -p $out/share/icons/hicolor/256x256/apps
          cp ${icon} $out/share/icons/hicolor/256x256/apps/highlite.png
          # Generate desktop entry
          mkdir -p $out/share/applications
          cat > $out/share/applications/highlite.desktop <<EOF
[Desktop Entry]
Type=Application
Name=HighLite
Exec=highlite
Icon=highlite
Categories=Game;
Comment=HighLite Desktop Application
Terminal=false
EOF
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
          sed -i "/HighLite-.*\.AppImage/{n;s|sha256 = \".*\";|sha256 = \"$SHA256\";|;}" flake.nix

          echo "flake.nix updated to version $VERSION with sha256 $SHA256"
        '');
      };

      devShells.x86_64-linux = {
        default = pkgs.mkShell {
          buildInputs = with pkgs; [ curl jq nix-prefetch ];
        };
        impure-latest = pkgs.mkShell {
          buildInputs = with pkgs; [ git corepack electron yarn ];
          shellHook = ''
            echo "\nWelcome to the impure HighLite dev shell!"
            echo "This shell is for building the latest HighLiteDesktop from a live git clone."
            echo "Run the following commands:"
            echo "  git clone https://github.com/Highl1te/HighliteDesktop.git"
            echo "  cd HighliteDesktop"
            echo "  yarn install"
            echo "  yarn build"
            echo "  yarn exec electron-builder"
            echo "AppImages will be in dist/"
          '';
        };
      };
    };
}
