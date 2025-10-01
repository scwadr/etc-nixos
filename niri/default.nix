{
  config,
  pkgs,
  lib,
  nixpkgs-unstable,
  ...
}:
{
  imports = [ ../home-manager.nix ];

  options.kiyurica.desktop.niri.enable = lib.mkEnableOption "Niri-based";
  options.kiyurica.desktop.niri.config = lib.mkOption {
    default = ''
      Mod+T hotkey-overlay-title="Open a Terminal: foot" { spawn "foot"; }
    '';
    type = lib.types.lines;
    description = "config file contents";
  };

  config = lib.mkIf config.kiyurica.desktop.niri.enable {
    nixpkgs.overlays = [
      (
        final: prev:
        let
          unstable = import nixpkgs-unstable { system = prev.system; };
        in
        {
          niri = unstable.niri;
        }
      )
    ];
    home-manager.users.kiyurica = {
      imports = [
        ./home-manager/graphical.nix
        {
          imports = [
            ../home-manager/fuzzel.nix
            ../home-manager/wlsunset.nix
            ../home-manager/wayland.nix
          ];
          config = {
            xdg.configFile."niri/config.kdl" = {
              text = config.kiyurica.desktop.niri.config;
            };
            systemd.user.services.swaybg = lib.mkIf config.kiyurica.graphical.background {
              Unit = {
                Description = "swaywm background";
                PartOf = [ "graphical-session.target" ];
                StartLimitIntervalSec = 350;
                StartLimitBurst = 30;
              };
              Service = {
                ExecStart = "${pkgs.swaybg}/bin/swaybg -mfill -i ${../wallpapers/takamatsu.jpg}";
                Restart = "on-failure";
                RestartSec = 3;
              };
              Install.WantedBy = [ "graphical-session.target" ];
            };
          };
        }
      ];
    };

    programs.niri.enable = true;
    environment.etc."greetd/environments".text = "/run/current-system/sw/bin/niri";
    environment.systemPackages = with pkgs; [ pkgs.libsForQt5.qt5.qtwayland ];
    services.systemd-lock-handler.enable = true;
  };
}
