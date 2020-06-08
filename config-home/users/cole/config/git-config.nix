{ pkgs, ... }:

{
  enable = true;
  package = pkgs.gitAndTools.gitFull; # to get send-email

  # TODO: include git crypt here?

  # root key = "8A94ED58A476A13AE0D6E85E9758078DE5308308";
  # signing key = "8329C1934DA5D818AE35F174B475C2955744A019";
  signing.key = "8329C1934DA5D818AE35F174B475C2955744A019";
  signing.signByDefault = true;
  userEmail = "cole.mickens@gmail.com";
  userName = "Cole Mickens";
}

