{ config, lib, pkgs, ... }:

with lib;

let

  inherit (config.lib.custom) genAttrs';

  cfg = config.custom.users.sca.bin;

  mkUserBinScript = name:
    {
      name = "bin/${name}";
      value = {
        source = ./scripts + "/${name}";
        executable = true;
      };
    };

in

{
  options = {
    custom.users.sca.bin = {
      enable = mkEnableOption "User bin scripts";
    };
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        # Bluetooth
        bluez

        _1password
        pulseaudio
      ];

      file = genAttrs'
        [
          # Bluetooth headset
          "lib/btctl"
          "wh1000xm2-connect"
          "wh1000xm2-disconnect"

          # Password CLI
          "pass"
        ]
        mkUserBinScript;
    };
  };
}
