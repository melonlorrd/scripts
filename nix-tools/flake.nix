{
  description = "Pinned, reproducible Nix package for Google's Antigravity CLI (agy)";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];

      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system (import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      }));

      # BEGIN AGY RELEASE PINS
      releasePins = {
        "aarch64-darwin" = { version = "1.3.3"; url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.3.3-5524738307653632/darwin-arm/cli_mac_arm64.tar.gz"; hash = "sha512-Beu0chScpGHpn3hwzoH73UjjhE9DuWp3jJgdmDQhYnxb0CWW3IIRzNMLTO4N+MpNF7aB9YfvIpSOpMcD6cf8vQ=="; };
        "x86_64-darwin" = { version = "1.3.3"; url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.3.3-5524738307653632/darwin-x64/cli_mac_x64.tar.gz"; hash = "sha512-lwdax+0ICSj1jsPgvoOzgFf5gNQJJ6PQ2txUhQypmohPOMkL9cT27LPGEB8x11YFAEUDkMRoIIrH3iVgry33aw=="; };
        "aarch64-linux" = { version = "1.3.3"; url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.3.3-5524738307653632/linux-arm/cli_linux_arm64.tar.gz"; hash = "sha512-G/01A1diGaECF2wTV5ZlovOehKyGqQSxF9OzPz3XUfGUqGJJa61v/pFK1G0sh3uhK2wH5tsHEotwbSOCYv5DDA=="; };
        "x86_64-linux" = { version = "1.3.3"; url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.3.3-5524738307653632/linux-x64/cli_linux_x64.tar.gz"; hash = "sha512-q+Pd9c8w062qWGrPUFIhqhlwL1ynGvPIsfmxpZdr2OXBUcQeozs5xBZ10lhDRio+jDgsBU9YDp1+FoiRnTtREA=="; };
      };
      # END AGY RELEASE PINS

      updater = pkgs: pkgs.writeShellScript "agy-update" ''
        set -euo pipefail
        BASE="https://antigravity-cli-auto-updater-974169037036.us-central1.run.app/manifests"
        FLAKE="flake.nix"
        if [ ! -f "$FLAKE" ] && [ -f "nix-tools/flake.nix" ]; then
          FLAKE="nix-tools/flake.nix"
        fi

        pins="$(
          for pair in aarch64-darwin:darwin_arm64 x86_64-darwin:darwin_amd64 aarch64-linux:linux_arm64 x86_64-linux:linux_amd64; do
            sys="''${pair%%:*}"
            plat="''${pair##*:}"
            json="$(${pkgs.curl}/bin/curl -fsSL "$BASE/$plat.json")"
            ver="$(echo "$json" | ${pkgs.jq}/bin/jq -r .version)"
            url="$(echo "$json" | ${pkgs.jq}/bin/jq -r .url)"
            sha="$(echo "$json" | ${pkgs.jq}/bin/jq -r .sha512)"
            sri="$(nix hash convert --to sri --hash-algo sha512 "$sha")"
            echo "        \"$sys\" = { version = \"$ver\"; url = \"$url\"; hash = \"$sri\"; };"
          done
        )"

        ${pkgs.gawk}/bin/awk -v pins="$pins" '
          /# BEGIN AGY RELEASE PINS/ {
      releasePins = {
        "aarch64-darwin" = { version = "1.3.3"; url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.3.3-5524738307653632/darwin-arm/cli_mac_arm64.tar.gz"; hash = "sha512-Beu0chScpGHpn3hwzoH73UjjhE9DuWp3jJgdmDQhYnxb0CWW3IIRzNMLTO4N+MpNF7aB9YfvIpSOpMcD6cf8vQ=="; };
        "x86_64-darwin" = { version = "1.3.3"; url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.3.3-5524738307653632/darwin-x64/cli_mac_x64.tar.gz"; hash = "sha512-lwdax+0ICSj1jsPgvoOzgFf5gNQJJ6PQ2txUhQypmohPOMkL9cT27LPGEB8x11YFAEUDkMRoIIrH3iVgry33aw=="; };
        "aarch64-linux" = { version = "1.3.3"; url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.3.3-5524738307653632/linux-arm/cli_linux_arm64.tar.gz"; hash = "sha512-G/01A1diGaECF2wTV5ZlovOehKyGqQSxF9OzPz3XUfGUqGJJa61v/pFK1G0sh3uhK2wH5tsHEotwbSOCYv5DDA=="; };
        "x86_64-linux" = { version = "1.3.3"; url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.3.3-5524738307653632/linux-x64/cli_linux_x64.tar.gz"; hash = "sha512-q+Pd9c8w062qWGrPUFIhqhlwL1ynGvPIsfmxpZdr2OXBUcQeozs5xBZ10lhDRio+jDgsBU9YDp1+FoiRnTtREA=="; };
      };
          /# END AGY RELEASE PINS/ { skip=0 }
          !skip
        ' "$FLAKE" > "$FLAKE.tmp" && mv "$FLAKE.tmp" "$FLAKE"
        echo "Updated release pins in $FLAKE successfully."
      '';
    in
    {
      packages = forAllSystems (system: pkgs:
        let
          release = releasePins.${system};
        in
        {
          default = self.packages.${system}.agy;
          agy = pkgs.stdenvNoCC.mkDerivation {
            pname = "antigravity-cli";
            version = release.version;

            src = pkgs.fetchurl {
              inherit (release) url hash;
              name = "agy-${release.version}-${system}.tar.gz";
            };

            sourceRoot = ".";
            dontStrip = true;
            nativeBuildInputs = [ pkgs.makeWrapper ]
              ++ pkgs.lib.optionals pkgs.stdenv.hostPlatform.isLinux [ pkgs.autoPatchelfHook ];

            installPhase = ''
              runHook preInstall
              install -D -m 0755 antigravity "$out/libexec/agy"
              makeWrapper "$out/libexec/agy" "$out/bin/agy" \
                --set AGY_CLI_DISABLE_AUTO_UPDATE true
              runHook postInstall
            '';

            meta = with pkgs.lib; {
              description = "Terminal CLI for Google Antigravity agents";
              homepage = "https://antigravity.google/product/antigravity-cli";
              license = licenses.unfree;
              platforms = supportedSystems;
              sourceProvenance = with sourceTypes; [ binaryNativeCode ];
              mainProgram = "agy";
            };
          };
        });

      apps = forAllSystems (system: pkgs: {
        update = {
          type = "app";
          program = toString (updater pkgs);
        };
      });
    };
}
