{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.custom.roles.multimedia;

in

{
  options = {
    custom.roles.multimedia = {
      enable = mkEnableOption "Multimedia";
    };
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        #       plex-media-player
        spotifywm
      ];
    };

    #    programs.mpv.enable = true;
  };
}
