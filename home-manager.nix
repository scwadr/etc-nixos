{
  config,
  lib,
  home-manager,
  specialArgs,
  ...
}:
{
  imports = [ home-manager.nixosModules.default ];

  options.kiyurica.home-manager.enable = lib.mkEnableOption "home-manager configuration";

  config = lib.mkIf config.kiyurica.home-manager.enable {
    home-manager.users.artems = {
      imports = [ ./home-manager/base.nix ];
      nixpkgs.config.allowUnfree = true;
      nixpkgs.overlays = [
        (final: prev: {
          python310Packages =
            specialArgs.nixpkgs-unstable.legacyPackages.${prev.stdenv.hostPlatform.system}.python310Packages;
        })
      ];
    };
    home-manager.extraSpecialArgs = specialArgs;
  };
}
