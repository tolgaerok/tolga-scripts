{ config, pkgs, ... }:

let
  wpsFonts = pkgs.stdenv.mkDerivation {
    pname = "wps-fonts";
    version = "latest";
    src = pkgs.fetchzip {
      url = "https://github.com/tolgaerok/fonts-tolga/raw/main/WPS-FONTS.zip";
      sha256 = "02imcxnzhmpvhchxmgpfx4af806p7kwx306fspk14s9g1zx7af9z"; # Update this if needed
      stripRoot = false;
    };
    installPhase = ''
      mkdir -p $out/share/fonts
      cp -r $src/* $out/share/fonts/
    '';
  };
in
{
  fonts.packages = with pkgs; [
    noto-fonts
    corefonts
    fira-code
    jetbrains-mono
    liberation_ttf
    wineWowPackages.fonts 
    wpsFonts  # Now it should be available
  ];

  environment.systemPackages = with pkgs; [
    fontconfig # Ensures `fc-cache` is installed
  ];

  system.activationScripts.updateFontCache = ''
    echo "Updating font cache..."
    ${pkgs.fontconfig}/bin/fc-cache -f -v
  '';
}
