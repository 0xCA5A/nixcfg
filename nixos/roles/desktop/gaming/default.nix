{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.custom.roles.desktop.gaming;

in

{
  options = {
    custom.roles.desktop.gaming = {
      enable = mkEnableOption "Gaming computer config";
    };
  };

  config = mkIf cfg.enable {
    programs.steam.enable = true;
    hardware = {
      #new-lg4ff.enable = true; # Gaming wheel driver - coming in unstable
      xpadneo.enable = true;
    };
  };
}
