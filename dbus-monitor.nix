{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Allow artems to monitor systemd D-Bus messages without sudo
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id == "org.freedesktop.systemd1.manage-units" &&
          subject.user == "artems") {
        return polkit.Result.YES;
      }
    });
  '';
}
