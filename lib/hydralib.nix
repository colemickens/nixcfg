rec {
  jobsetDefaults = {
    enabled = 1;
    hidden = false;
    keepnr = 3;
    schedulingshares = 100;
    checkinterval = 15;
    emailoverride = "";
    type = 1;
  };

  flakeJob = flakeRef: jobsetDefaults // {
    flake = flakeRef;
  };

  makeSpec = contents: builtins.derivation {
    name = "spec.json";
    system = "x86_64-linux";
    preferLocalBuild = true;
    allowSubstitutes = false;
    builder = "/bin/sh";
    args = [ (builtins.toFile "builder.sh" ''
      echo "$contents" > $out
    '') ];
    contents = builtins.toJSON contents;
  };
}
