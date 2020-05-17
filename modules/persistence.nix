# source: https://github.com/talyz/nixos-config/blob/master/modules/persistence.nix

{ pkgs, config, lib, ... }:

with lib;
with builtins;

let
  cfg = config.environment.persistence;
  
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

    environment.persistence = {

      targetDir = mkOption {
        type = types.str;
        description = ''
          The directory where real files and directories are stored.
        '';
      };

      etc = {

        directories = mkOption {
          type = with types; listOf str;
          default = [];
          description = ''
            Directories in /etc that should be stored in persistent storage.
          '';
          example = ''
            [ "NetworkManager/system-connections" ]
          '';
        };

        files = mkOption {
          type = with types; listOf str;
          default = [];
          description = ''
            Files in /etc that should be stored in persistent storage.
          '';
        };

        createMissingDirectories = mkOption {
          type = types.bool;
          default = true;
        };
        
      };

      root = {

        targetDir = mkOption {
          type = types.str;
        };

        directories = mkOption {
          type = with types; listOf str;
          default = [];
        };

        createMissingDirectories = mkOption {
          type = types.bool;
          default = true;
        };

      };

    };
    
  };

  config = {
    environment.etc =
      listToAttrs
        (map (fileOrDir:
                nameValuePair
                  fileOrDir
                  { source = link (concatPaths [cfg.targetDir "etc" fileOrDir]); })
             (cfg.etc.files ++ cfg.etc.directories));

    fileSystems =
      listToAttrs
        (map (dir:
                nameValuePair
                  (concatPaths ["/" dir])
                  {
                    device = concatPaths [cfg.targetDir dir];
                    options = ["bind"];
                  })
             cfg.root.directories);

    system.activationScripts =
      optionalAttrs cfg.etc.createMissingDirectories {
        createDirsInEtc = noDepEntry
                            (concatMapStrings
                               (dir: let targetDir = concatPaths [cfg.targetDir "etc" dir]; in ''
                                 if [[ ! -e "${targetDir}" ]]; then
                                     mkdir -p "${targetDir}"
                                 fi
                               '')
                               cfg.etc.directories);
      } // optionalAttrs cfg.root.createMissingDirectories {
        createDirsInRoot = noDepEntry
                             (concatMapStrings
                                (dir: let targetDir = concatPaths [cfg.targetDir dir]; in ''
                                  if [[ ! -e "${targetDir}" ]]; then
                                      mkdir -p "${targetDir}"
                                  fi
                                '')
                                cfg.root.directories);
      };
  };
  
}
