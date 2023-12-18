{
  description = "Payload Inspector app";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, rust-overlay, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };

        rustPlatform = pkgs.makeRustPlatform {
          cargo = pkgs.rust-bin.stable.latest.default;
          rustc = pkgs.rust-bin.stable.latest.default;
        };

        rustPackage = rustPlatform.buildRustPackage {
          name = "payload-inspector";
          src = ./payload-inspector;
          cargoLock.lockFile = ./payload-inspector/Cargo.lock;
        };

        dockerImage = pkgs.dockerTools.buildImage {
          name = "payload-inspector";
          config = {
            Cmd = [ "${rustPackage}/bin/payload-inspector" ];
          };
        };
      in
      with pkgs;
      {
        devShells.default = mkShell {
          buildInputs = [
            rust-bin.stable.latest.default
            rustfmt
            pre-commit
            rustPackages.clippy
            just
            pkg-config
            openssl
          ];
          shellHook = ''
            cat <<EOF
            Welcome to the `payload-inspector` app development shell.

            $(just -l |sed 's/^Available recipes:/The following `just` recipes are available:/')
            EOF
            user_shell=$(getent passwd "$(whoami)" |cut -d: -f 7)
            exec "$user_shell"
          '';
        };

        packages = {
          rustPackage = rustPackage;
          dockerImage = dockerImage;
        };
      }
    );
}
