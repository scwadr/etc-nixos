{
  config,
  ...
}:
{
  age.secrets.codex-auth = {
    file = ./secrets/codex-auth.json.age;
    owner = "kiyurica";
    group = "kiyurica";
    mode = "400";
  };

  home-manager.users.kiyurica =
    let
      systemConfig = config;
    in
    { config, pkgs, ... }:
    {
      home.packages = [ pkgs.codex ];
      home.file.".codex/auth.json" = {
        source = config.lib.file.mkOutOfStoreSymlink systemConfig.age.secrets.codex-auth.path;
      };
    };
}
