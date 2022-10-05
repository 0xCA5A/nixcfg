{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    alsa-utils
    pavucontrol
  ];
  hardware.bluetooth.enable = true;

  # Recommended by https://nixos.wiki/wiki/PipeWire
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
}
