# source: https://github.com/talyz/nixos-config/blob/master/home-talyz-nixpkgs/modules/persistence.nix

{ pkgs, config, lib, ... }:

with lib;
with builtins;

let
  cfg = config.home.persistence;
  
  # ["/home/user/" "/.screenrc"] -> ["home" "user" ".screenrc"]
  splitPath = paths:
    (filter (s: typeOf s == "string" && s != "")
            (concatMap (split "/") paths));
            
  # ["home" "user" ".screenrc"] -> "home/user/.screenrc"
  dirListToPath = dirList: (concatStringsSep "/" dirList);
  
  # ["/home/user/" "/.screenrc"] -> "/home/user/.screenrc"
  concatPaths = paths: (if hasPrefix "/" (head paths) then "/" else "") +
                         (dirListToPath (splitPath paths));
                         
  link = file: pkgs.runCommand "${replaceStrings ["/" "." " "] ["-" "" ""] file}" {}
                               "ln -s '${file}' $out";
in
{
  options = {

    home.persistence = mkOption {
      default = {};
      type = with types; attrsOf (submodule
        {
          options = {
            
            directories = mkOption {
              type = with types; listOf string;
              default = [];
            };

            files = mkOption {
              type = with types; listOf string;
              default = [];
            };

            createMissingDirectories = mkOption {
              type = types.bool;
              default = true;
            };

            removePrefixDirectory = mkOption {
              type = types.bool;
              default = false;
            };
            
          };
        }
      );
    };
    
  };

  config = {
    home.file =
      foldr recursiveUpdate {}
            (map (path:
                    (listToAttrs
                       (map (fileOrDir:
                               nameValuePair
                                 (if cfg.${path}.removePrefixDirectory then
                                    dirListToPath (tail (splitPath [fileOrDir]))
                                  else
                                    fileOrDir)
                                 { source = link (concatPaths [path fileOrDir]); })
                            (cfg.${path}.files ++ cfg.${path}.directories))))
                 (attrNames cfg));

    home.activation =
      let
        dag = config.lib.dag;
      in
      listToAttrs
        (map (path:
                if cfg.${path}.createMissingDirectories then
                   nameValuePair
                     "createDirsIn-${replaceStrings ["/" "."] ["-" ""] path}"
                     (dag.entryAfter
                       ["writeBoundary"]
                       (concatMapStrings
                          (dir: let targetDir = concatPaths [path dir]; in ''
                            if [[ ! -e "${targetDir}" ]]; then
                                mkdir -p "${targetDir}"
                            fi
                          '')
                         cfg.${path}.directories))
                 else [])
             (attrNames cfg));
  };
  
}
