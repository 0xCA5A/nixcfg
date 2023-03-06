{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.custom.roles.desktop;

in

{
  options = {
    custom.roles.desktop = {
      enable = mkEnableOption "Desktop";

    };
  };

  config = mkIf cfg.enable {
    custom.roles.desktop.awesome.enable = true;

    home = {
      packages = with pkgs; [
        mupdf
        peek
        gifski
        xclip
        flameshot
        gnome.gnome-terminal
      ];
    };

    xsession = {
      enable = true;
      numlock.enable = true;
    };
  };
}
