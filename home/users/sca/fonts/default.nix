{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.custom.users.sca.fonts;

in

{
  options = {
    custom.users.sca.fonts = {
      enable = mkEnableOption "Fonts";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      google-fonts
      ubuntu_font_family
    ];
  };
}
