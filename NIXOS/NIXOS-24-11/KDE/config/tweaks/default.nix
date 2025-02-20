
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
  

{ config, pkgs, ... }:

{
  # First, everything that applies to all machines:
  imports = [
    # ./packages/scripts.nix
    # ./packages/custom-fonts.nix
    # ./packages/apple-fonts.nix
    # ./packages/minecraft-fonts.nix
    # ./packages/remote-builders.nix
    # ./services/syncthing.nix
  ];

  #---------------------------------------------------------------------
  # Systemd Configuration
  #---------------------------------------------------------------------
  # Prevents getting stuck in emergency mode due to boot failures.
  # https://github.com/NixOS/nixpkgs/issues/147783
  systemd = {
    # enableEmergencyMode = false;
    # network.wait-online.anyInterface = true;
    services.systemd-udev-settle.enable = false;
  };

  #---------------------------------------------------------------------
  # Nix Configuration
  #---------------------------------------------------------------------
  nix.settings = {
    auto-optimise-store = true; # Corrected option name
    trusted-users = [
      "@wheel"
      "tolga"
    ]; # Corrected option name
    system-features = [
      "i686-linux"
      "big-parallel"
    ];
  };

  nix.gc = {
    automatic = true;
    options = "--delete-older-than 15d";
  };

  environment.sessionVariables = {
    NIXPKGS_ALLOW_INSECURE = "1";
  };

  nixpkgs.config.allowUnfreePredicate = (pkg: true);

  # Enables simultaneous use of processor threads.
  # ---------------------------------------------
  security.allowSimultaneousMultithreading = true;
}

