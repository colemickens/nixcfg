{ config, pkgs, ... }:

let
  # TODO: credit: https://gist.github.com/corpix/f761c82c9d6fdbc1b3846b37e1020e11
  # TODO: nix-rice ? conversion function
  hexToDec = v:
    let
      pow =
        let
          pow' = base: exponent: value:
            # FIXME: It will silently overflow on values > 2**62 :(
            # The value will become negative or zero in this case
            if exponent == 0
            then 1
            else if exponent <= 1
            then value
            else (pow' base (exponent - 1) (value * base));
        in base: exponent: pow' base exponent base;
      hexToInt = {
        "0" = 0; "1" = 1;  "2" = 2;
        "3" = 3; "4" = 4;  "5" = 5;
        "6" = 6; "7" = 7;  "8" = 8;
        "9" = 9; "a" = 10; "b" = 11;
        "c" = 12;"d" = 13; "e" = 14;
        "f" = 15;
      };
      chars = pkgs.lib.stringToCharacters v;
      charsLen = builtins.length chars;
    in
      pkgs.lib.foldl
        (a: v: a + v)
        0
        (pkgs.lib.imap0
          (k: v: hexToInt."${pkgs.lib.toLower v}" * (pow 16 (charsLen - k - 1)))
          chars);

  convert = old: [
    (hexToDec (builtins.substring 1 2 old))
    (hexToDec (builtins.substring 3 2 old))
    (hexToDec (builtins.substring 5 2 old))
  ];

  ts = import ./_common/termsettings.nix { inherit pkgs; };
  font = ts.fonts.default;
  colors = ts.colors.default;
in
{
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      imports = [
        ../modules-hm/zellij.nix
      ];
      programs.zellij = {
        enable = true;

        settings = {
          default-mode = "normal";
          simplified-ui = true;
          no-pane-frames = true;

          themes = {
            custom = {
              fg = convert colors.foreground;
              bg = convert colors.background;
              black = convert colors.black;
              red = convert colors.red;
              green = convert colors.green;
              yellow = convert colors.yellow;
              blue = convert colors.blue;
              magenta = convert colors.purple;
              cyan = convert colors.cyan;
              white = convert colors.white;
              orange = convert colors.yellow;
            };
          };
        };
      };
    };
  };
}
