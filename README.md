A nix flake for [terminalphone](https://gitlab.com/here_forawhile/terminalphone).

*I'm not the author of this program. I just made this flake.*

# Usage
## Run
```bash
nix run github:szymon-jozef/terminalphone-flake
```
## Install (add to profile)
```bash
nix profile add github:szymon-jozef/terminalphone-flake
```
## Install (declarative)
*in your flake*
```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    terminalphone.url = "github:szymon-jozef/terminalphone-flake";
  };

  outputs = { self, nixpkgs, terminalphone, ... }: 
  let
    system = "x86_64-linux"; 
    pkgs = nixpkgs.legacyPackages.${system};
  in
  {
    nixosConfigurations.myMachine = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ({ pkgs, ... }: {
          environment.systemPackages = [
            terminalphone.packages.${system}.default
          ];
        })
      ];
    };
  };
}
```
