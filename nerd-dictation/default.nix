{ config, pkgs, lib, ... }:
{
  options.kiyurica.nerd-dictation.enable = lib.mkEnableOption "keyboard dictation";

  config = lib.mkIf config.kiyurica.nerd-dictation.enable {
    # callPackage ./vosk.nix { };
    environment.systemPackages = [
      (pkgs.callPackage ./nerd-dictation.nix { })
    ];
  };
}
