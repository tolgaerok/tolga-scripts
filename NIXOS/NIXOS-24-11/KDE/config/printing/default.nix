
let
/*
 * What you're seeing here is our nix formatter. It's quite opinionated:
 */
  sample-01 = { lib }:
{
  list = [
    elem1
    elem2
    elem3
  ] ++ lib.optionals stdenv.isDarwin [
    elem4
    elem5
  ]; # and not quite finished
}; # it will preserve your newlines

  sample-02 = { stdenv, lib }:
{
  list =
    [
      elem1
      elem2
      elem3
    ]
    ++ lib.optionals stdenv.isDarwin [ elem4 elem5 ]
    ++ lib.optionals stdenv.isLinux [ elem6 ]
    ;
};
# but it can handle all nix syntax,
# and, in fact, all of nixpkgs in <20s.
# The javascript build is quite a bit slower.
 sample-03 = { stdenv, system }:
assert system == "i686-linux";
stdenv.mkDerivation { };
# these samples are all from https://github.com/nix-community/nix-fmt/tree/master/samples
sample-simple = # Some basic formatting
{
  empty_list = [ ];
  inline_list = [ 1 2 3 ];
  multiline_list = [
    1
    2
    3
    4
  ];
  inline_attrset = { x = "y"; };
  multiline_attrset = {
    a = 3;
    b = 5;
  };
  # some comment over here
  fn = x: x + x;
  relpath = ./hello;
  abspath = /hello;
  # URLs get converted from strings
  url = "https://foobar.com";
  atoms = [ true false null ];
  # Combined
  listOfAttrs = [
    {
      attr1 = 3;
      attr2 = "fff";
    }
    {
      attr1 = 5;
      attr2 = "ggg";
    }
  ];

  # long expression
  attrs = {
    attr1 = short_expr;
    attr2 =
      if true then big_expr else big_expr;
  };
}
;
in
[ sample-01 sample-02 sample-03 ]
  

{
  config,
  lib,
  pkgs,
  ...
}:

let
  extraBackends = [ pkgs.epkowa ];

  #---------------------------------------------------------------------
  #   Printers and printer drivers (To suit my HP LaserJet 600 M601)
  #---------------------------------------------------------------------
  printerDrivers = [
    # pkgs.brgenml1cupswrapper      # Generic drivers for more Brother printers
    # pkgs.brgenml1lpr              # Generic drivers for more Brother printers
    # pkgs.brlaser                  # Drivers for some Brother printers
    # pkgs.cnijfilter2              # Generic cannon
    pkgs.gutenprint                 # Drivers for many different printers from many different vendors
    pkgs.gutenprintBin              # Additional, binary-only drivers for some printers
    pkgs.hplip                      # Drivers for HP printers
    pkgs.hplipWithPlugin            # Drivers for HP printers, with the proprietary plugin. Use in terminal  NIXPKGS_ALLOW_UNFREE=1 nix-shell -p hplipWithPlugin --run 'sudo -E hp-setup'
  ];

in
{
  #---------------------------------------------------------------------
  #   Scanner and Printing Configuration
  #---------------------------------------------------------------------
  services = {
    # Enable the CUPS printing service
    printing.enable = true;

    # Specify the printer drivers to use (replace 'printerDrivers' with your specific drivers)
    printing.drivers = printerDrivers;  # Customize this with specific printer drivers if needed
  };

  hardware = {
    # Enable SANE (Scanner Access Now Easy) support for scanners
    sane.enable = true;

    # Specify extra backends (drivers) for scanners if needed
    sane.extraBackends = extraBackends; # Customize this if you have special scanner drivers
  };
}

