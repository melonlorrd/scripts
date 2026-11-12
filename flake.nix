{
  description = "dotfiles";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [ "aarch64-darwin" "x86_64-darwin" "x86_64-linux" "aarch64-linux" ];
      # import nixpkgs ourselves so we can allow unfree packages (claude-code)
      forAll = f: nixpkgs.lib.genAttrs systems (s:
        f (import nixpkgs { system = s; config.allowUnfree = true; }));

      # Shared shell prelude: profile detection + layer resolution
      prelude = ''
        root=$(git rev-parse --show-toplevel)

        detect_host() {
          # macOS: `hostname` follows the network and is unreliable
          if command -v scutil >/dev/null 2>&1; then
            scutil --get LocalHostName 2>/dev/null && return
          fi
          hostname -s
        }

        # precedence: argument > $DOTS_PROFILE > hostname
        profile="''${1:-''${DOTS_PROFILE:-$(detect_host | tr '[:upper:]' '[:lower:]')}}"
        profile="''${profile#dots-}"

        if [ ! -d "$root/dots-$profile" ]; then
          echo "no profile '$profile'. available:" >&2
          for d in "$root"/dots-*/; do
            n=$(basename "$d"); echo "  ''${n#dots-}" >&2
          done
          exit 1
        fi

        # shared layer first (if present), then the profile
        layers="$profile"
        if [ -d "$root/dots-common" ] && [ "$profile" != "common" ]; then
          layers="common $profile"
        fi
      '';

      mkApp = pkgs: name: text: {
        type = "app";
        program = pkgs.lib.getExe (pkgs.writeShellApplication {
          inherit name;
          runtimeInputs = with pkgs; [ git coreutils findutils hostname ];
          text = prelude + text;
        });
      };
    in {
      # one bundle of packages per profile: `nix profile install .#ganymede`
      packages = forAll (pkgs: {
        ganymede = pkgs.buildEnv {
          name = "ganymede";
          paths = with pkgs; [ claude-code glow w3m ];
        };
      });

      apps = forAll (pkgs: {
        default = self.apps.${pkgs.stdenv.hostPlatform.system}.link;

        link = mkApp pkgs "link-dots" ''
          echo "profile: $profile (layers: $layers)"
          for layer in $layers; do
            src="$root/dots-$layer"
            ( cd "$src"
              find . -type f -print0 | while IFS= read -r -d "" f; do
                f="''${f#./}"
                dst="$HOME/$f"
                mkdir -p "$(dirname "$dst")"
                if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src/$f" ]; then
                  echo "ok      $dst"
                elif [ -e "$dst" ] || [ -L "$dst" ]; then
                  echo "SKIP    $dst (already exists)"
                else
                  ln -s "$src/$f" "$dst"
                  echo "linked  $dst"
                fi
              done
            )
          done
        '';

        unlink = mkApp pkgs "unlink-dots" ''
          echo "profile: $profile (layers: $layers)"
          for layer in $layers; do
            src="$root/dots-$layer"
            ( cd "$src"
              find . -type f -print0 | while IFS= read -r -d "" f; do
                f="''${f#./}"
                dst="$HOME/$f"
                if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src/$f" ]; then
                  rm "$dst"
                  echo "removed $dst"
                fi
              done
            )
          done
        '';
      });
    };
}
