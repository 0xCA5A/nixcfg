{ config, lib, pkgs, rootPath, ... }:

with lib;

let

  cfg = config.custom.base.non-nixos;
  flakeBaseDir = config.home.homeDirectory + "/.nix-config";

in

{

  options = {
    custom.base.non-nixos = {
      enable = mkEnableOption "Config for non NixOS systems";

      installNix = mkEnableOption "Nix installation" // { default = true; };
    };
  };

  config = mkIf cfg.enable {

    home = {
      packages = with pkgs; [
        unstable.home-manager
      ];

      shellAliases = {
        hm-switch = "home-manager switch -b hm-bak --impure --flake '${flakeBaseDir}'";
      };
    };

    nix = {
      package = pkgs.nix;
      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
      };
    };

    targets.genericLinux.enable = true;
  };
}
