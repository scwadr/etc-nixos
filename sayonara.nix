{
  specialArgs,
  pkgs,
  lib,
  ...
}:
let
  mkNixPak = specialArgs.nixpak.lib.nixpak {
    inherit (pkgs) lib;
    inherit pkgs;
  };
  sandboxed-sayonara = mkNixPak {
    config =
      { sloth, ... }:
      {
        app.package = pkgs.sayonara;
        dbus.enable = true;
        dbus.policies = {
          "org.freedesktop.DBus" = "talk";
          "org.mpris.MediaPlayer2" = "talk";
        };
        flatpak.appId = "com.sayonara_player.Sayonara";
        bubblewrap = {
          network = false;
          bind.ro = [
            "${config.services.syncthing.settings.folders."inaba".path}/music-library"
          ];
          bind.dev = [ "/dev/dri" ];
        };
      };
  };
in
{
  users.users.kiyurica.packages = [ sandboxed-sayonara.config.script ];
}
