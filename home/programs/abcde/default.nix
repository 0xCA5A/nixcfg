{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.custom.programs.abcde;

in

{
  options = {
    custom.programs.abcde = {
      enable = mkEnableOption "abcde - A Better CD Encoder";
    };
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        abcde
        cdparanoia
        easytag
        ffmpeg
        id3lib
      ];
    };

    xdg.configFile.abcde = {
      recursive = true;
      source = ./configs;
    };
  };
}
