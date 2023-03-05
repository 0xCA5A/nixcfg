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
    custom.desktop.awesome.enable = true;

    home = {
      packages = with pkgs; [
        mupdf
        peek
        gifski
        xclip
      ];
    };

    xsession = {
      enable = true;
      numlock.enable = true;
    };
  };
}
