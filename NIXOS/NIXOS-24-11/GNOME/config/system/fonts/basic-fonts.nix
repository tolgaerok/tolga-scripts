{ pkgs, ... }:

let
  wpsFonts = pkgs.stdenv.mkDerivation {
    pname = "wps-fonts";
    version = "latest";
    src = pkgs.fetchzip {
      url = "https://github.com/tolgaerok/fonts-tolga/raw/main/WPS-FONTS.zip";
      sha256 = "02imcxnzhmpvhchxmgpfx4af806p7kwx306fspk14s9g1zx7af9z"; # Update if necessary
      stripRoot = false;
    };
    installPhase = ''
      mkdir -p $out/share/fonts
      cp -r $src/* $out/share/fonts/
    '';
  };
in
{
  fonts.packages = [ wpsFonts ];
}
