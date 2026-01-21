{ pkgs, ... }:
{
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    wireplumber.enable = true;
  };

  home-manager.users.artems = {
    imports = [
      (
        { pkgs, ... }:
        {
          home.packages = [ pkgs.pwvucontrol ];
        }
      )
    ];
  };
}
