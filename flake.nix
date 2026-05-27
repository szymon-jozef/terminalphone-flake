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

        commonDeps = with pkgs; [
          tor
          opus-tools
          sox
          socat
          openssl
        ];

        linuxDeps = pkgs.lib.optionals pkgs.stdenv.isLinux (
          with pkgs;
          [
            alsa-utils
          ]
        );

        dependencies = commonDeps ++ linuxDeps;
      in
      {
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "terminalphone";

          version = "unstable-${builtins.substring 0 8 (terminalphone.lastModifiedDate or "19700101")}-${
            terminalphone.shortRev or "dirty"
          }";

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

          meta = with pkgs.lib; {
            description = "Encrypted push-to-talk voice communication over Tor hidden services.";
            longDescription = ''
              TerminalPhone is a single, self-contained Bash script that provides anonymous, end-to-end encrypted voice and text communication between two or more parties over the Tor network. It operates as a walkie-talkie: you record a voice message, and it is compressed, encrypted, and transmitted to the remote party as a single unit. You can also send encrypted text messages during a call. No server infrastructure, no accounts, no phone numbers. Your Tor hidden service .onion address is your identity.
            '';
            homepage = "https://gitlab.com/here_forawhile/terminalphone";
            license = licenses.mit;
            platforms = platforms.all;
          };
        };
      }
    );
}
