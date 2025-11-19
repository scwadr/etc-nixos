{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Allow kiyurica to monitor systemd D-Bus messages without sudo
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id == "org.freedesktop.systemd1.manage-units" &&
          subject.user == "kiyurica") {
        return polkit.Result.YES;
      }
    });
  '';
}
