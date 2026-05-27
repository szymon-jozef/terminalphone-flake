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
      nixpkgs,
      flake-utils,
      terminalphone,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        dependencies = with pkgs; [ curl ];
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
              cp terminalphone.sh $out/bin/
              chmod +x $out/bin/terminalphone

              wrapProgram $out/bin/terminalphone.sh \
                --prefix PATH : ${dependencies}
            '';
        };
      }
    );
}
