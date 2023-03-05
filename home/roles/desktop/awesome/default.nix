{ config, lib, pkgs, ... }:

with lib;

let

  desktopCfg = config.custom.roles.desktop;
  cfg = desktopCfg.awesome;

in

{
  options = {
    custom.roles.desktop.awesome = {
      enable = mkEnableOption "Awesome window manager";
    };
  };

  config = mkIf cfg.enable {
    xsession.windowManager.awesome.enable = true;
    xsession.windowManager.awesome.luaModules = [ pkgs.luaPackages.vicious ];
  };
}
