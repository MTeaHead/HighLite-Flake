
# HighLite AppImage Flake

This repository contains a Nix flake for the [Highlite Desktop Application](https://github.com/Highl1te/HighliteDesktop). The flake provides an easy way to build and manage the Highlite AppImage using Nix.


## Inputs

- **nixpkgs**: This flake uses the `nixos-unstable` branch of the Nixpkgs repository. You can specify a different version if needed.

## Installing the Package

To quickly install the Highlite AppImage, you can use the following command:

```bash
nix profile install github:MTeaHead/HighLite-Flake
