{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.kiyurica.mosh.enable = lib.mkEnableOption "mosh";

  config = lib.mkIf config.kiyurica.mosh.enable {
    programs.mosh = {
      enable = true;
      withUtempter = true;
      openFirewall = true;
    };
  };
}
