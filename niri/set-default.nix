{
  config,
  lib,
  ...
}:
{
  config = lib.mkIf (config.kiyurica.desktop.niri.enable && config.kiyurica.desktop.niri.default) {
    services.displayManager.defaultSession = "niri-uwsm";
  };
}
