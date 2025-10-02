{
  config,
  lib,
  ...
}:
{
  config = lib.mkIf (config.kiyurica.desktop.niri.enable && config.kiyurica.desktop.niri.enableUWSM) {
    kiyurica.desktop.niri.config = ''
      spawn-at-startup "uwsm finalize"
      binds {
        Mod+Return { spawn "uwsm-app -- foot"; }
        Mod+D { spawn "fuzzel '--launch-prefix=uwsm-app --'"; }
        Mod+Shift+Return { spawn "uwsm-app -- firefox"; }
        Super+Alt+L { spawn "swaylock"; }
      }
    '';

    programs.uwsm = {
      enable = true;
      waylandCompositors.niri = {
        # becomes niri-uwsm.desktop
        binPath = "/run/current-system/sw/bin/niri-session";
        prettyName = "Niri";
        comment = "Niri-based session managed by UWSM";
      };
    };
  };
}
