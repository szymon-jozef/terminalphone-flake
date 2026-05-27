{
  description = "Flake for terminalphone app";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    terminalphone = {
      url = "gitlab:here_forawhile/terminalphone";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      terminalphone,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        dependencies = with pkgs; [
          tor
          opus-tools
          sox
          socat
          openssl
          alsa-utils
        ];
      in
      {
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "terminalphone";

          version = "1.1.6";

          src = terminalphone;

          nativeBuildInputs = with pkgs; [ makeWrapper ];
          buildInputs = dependencies;

          installPhase = # bash
            ''
              mkdir -p $out/bin
              cp terminalphone.sh $out/bin/terminalphone
              chmod +x $out/bin/terminalphone

              sed -i 's|$(cd "$(dirname "$0")" && pwd -P)|''${XDG_DATA_HOME:-$HOME/.local/share}/terminalphone|g' $out/bin/terminalphone

              wrapProgram $out/bin/terminalphone \
                --prefix PATH : ${pkgs.lib.makeBinPath dependencies}
            '';
        };
      }
    );
}
