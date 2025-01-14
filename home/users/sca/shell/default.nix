{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.custom.users.sca.shell;

in

{
  options = {
    custom.users.sca.shell = {
      enable = mkEnableOption "Shell configuration and utils";
    };
  };

  config = mkIf cfg.enable {
    custom = {
      programs.tmux.enable = true;
      users.sca.shell = {
        direnv.enable = true;
      };
    };

    home = {
      packages = with pkgs; [
        # Terminal fun
        asciiquarium
        bb
        cowsay
        cmatrix
        figlet
        fortune
        lolcat
        toilet

        # Make sure to have the right version in $PATH
        less

        # GNU util replacements
        fd # ultra-fast find
        ripgrep

        convmv
        eva
        file
        glow
        gnupg
        gron
        htop
        killall
        neofetch
        pandoc
        texlive.combined.scheme-small
        trash-cli
        unzip
      ];

      sessionVariables = {
        TERM = "gnome-terminal";
        MANPAGER = "less -R --use-color -Dd+g -Du+b";
      };

      shellAliases = import ./aliases.nix;
    };

    programs = {
      ssh = import ./ssh.nix;

      bat.enable = true;
      exa.enable = true;
      fzf.enable = true;
      jq.enable = true;
      starship.enable = true;
    };
  };
}
