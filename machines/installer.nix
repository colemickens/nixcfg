# this machine is unique:
#  it includes a few system profiles:
#   - a default one for a generic system
#   - a profile for each persona

# in theory, this lets me rebuild install media
# even if devices need really quirky hardware

# and the multie profile support in nixos
# means our installer media will give us a menu to boot into these
# profiles or not

# in our persona, we'll have ALL of our normal everything, except any missing data
# in all profiles we can invoke the installer
# the nix store will contain closures for all of our systems, assuming nixcfg matches when we invoke them

# ----- ground level ------
# "persona" => all non-disk configuration
# "machines" => persona + disk configuration
# "configuration" => machines + nixpkgs