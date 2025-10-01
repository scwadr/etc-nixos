{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [ ./home-manager.nix ];

  options.kiyurica.desktop.niri.enable = lib.mkEnableOption "Niri-based";

  config = lib.mkIf config.kiyurica.desktop.niri.enable {
    home-manager.users.kiyurica = {
      imports = [
        ./home-manager/graphical.nix
      ];
    };

    programs.uwsm.enable = true;
    programs.niri.enable = true;
    environment.systemPackages = with pkgs; [ pkgs.libsForQt5.qt5.qtwayland ];
    services.systemd-lock-handler.enable = true;
  };
}
