{
  services.flatpak.packages = [ "flathub:app/com.github.flxzt.rnote//stable" ];
  services.flatpak.overrides."com.github.flxzt.rnote" = {
    Context.filesystems = [ "!host" "!xdg-documents" "!xdg-pictures" "!xdg-desktop" ];
  };
}

