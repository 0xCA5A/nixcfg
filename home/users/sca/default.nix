{ config, lib, ... }:

with lib;

let

  username = "sca";
  cfg = config.custom.users."${username}";

in

{
  options = {
    custom.users."${username}" = {
      enable = mkEnableOption "User config";
    };
  };

  config = mkIf cfg.enable {
    home = {
      username = mkDefault username;
      homeDirectory = mkDefault "/home/${username}";
    };

    custom = {
      #      roles.homeage.enable = true;
      roles.desktop.enable = true;
      roles.graphics.enable = true;
      roles.dev.enable = true;
      users."${username}" = {
        #        bin.enable = true;
        #        fonts.enable = true;
        git.enable = true;
        hardware = {
          #          kmonad.enable = true;
          xbindkeys.enable = true;
        };
        shell.enable = true;
        #        office.cli.enable = config.custom.roles.office.cli.enable;
        #        ranger.enable = true;
        #        shell.enable = true;
        #        steam.enable = config.custom.roles.gaming.enable;
        #        vim.enable = true;
      };
    };
  };
}
