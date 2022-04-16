{ gnupg
, pinentry
, openssh
, efibootmgr
, tailscale
, asciinema
, msr-tools
, nixUnstable
, writeShellScriptBin
, linkFarmFromDrvs
, symlinkJoin
, writePython3Bin
}:

let
  efibootmgr_ = "${efibootmgr}/bin/efibootmgr";

  gpgKeyId = "0x9758078DE5308308";
  gpgCardId = "D2760001240100000006071267080000";
  gpgSshSocket = "/run/user/1000/gnupg/d.kbocp7uc7zjy47nnek3436ij/S.gpg-agent.ssh";

  tsip4 = (writeShellScriptBin "tsip4" ''
    ${tailscale}/bin/tailscale ip --4 "$1"
  '');

  tsip6 = (writeShellScriptBin "tsip6" ''
    ${tailscale}/bin/tailscale ip --6 "$1"
  '');

  gssh = (writeShellScriptBin "gssh" ''
    [[ -z "''${DEBUG_GPGSSH}" ]] || set -x
    set -euo pipefail

    ip="$(${tailscale}/bin/tailscale ip --6 "$1")"
    "${gpgssh}/bin/gpgssh" cole@"$ip"
  '');

  gpgssh = (writeShellScriptBin "gpgssh" ''
    [[ -z "''${DEBUG_GPGSSH}" ]] || set -x
    set -euo pipefail

    host=$1; shift

    lpath="$(${gnupg}/bin/gpgconf --list-dirs agent-socket)"
    rpath="$(${openssh}/bin/ssh "$host" -- "\
      pkill -9 gpg-agent; \
      systemctl --user stop gpg-agent.service; \
      pkill -9 gpg-agent; \
      gpgconf --list-dirs agent-socket \
        | xargs -d $'\n' sh -c 'for arg do rm -f "\$arg"; echo "\$arg"; done' _")"

    ssh \
        -o "RemoteForward $rpath:$lpath.extra" \
        -o StreamLocalBindUnlink=yes \
        -A "$host" -t 'ssh-fix || true; which zsh >/dev/null && exec zsh -l || exec bash -l'
  '');

  name = "cole-custom-commands";
  drvs = [
    tsip4
    tsip6
    gssh
    gpgssh

    (writeShellScriptBin "rec" ''
      ${asciinema}/bin/asciinema rec "''${HOME}/''${1}.cast" -c "zellij attach -c ''${1}"
    '')

    (writeShellScriptBin "gopass-clip" ''
      gopass show --clip "$(gopass ls --flat | sk --height '100%' -p "gopass show --clip> ")"
    '')

    (writeShellScriptBin "gopass-totp" ''
      gopass totp --clip "$(gopass ls --flat | sk --height '100%' -p "gopass totp --clip> ")"
    '')

    (writeShellScriptBin "devenv" ''
      nix develop $HOME/code/nixcfg#devenv "''${@}"
    '')

    (writePython3Bin "json2nix" { libraries = [ ]; } ''
      """Converts JSON objects into nix (hackishly)."""

      import sys
      import json


      INDENT = " " * 2


      def strip_comments(t):
          # fixme: doesn't work if JSON strings contain //
          return "\n".join(line.partition("//")[0] for line in t.split("\n"))


      def indent(s):
          return "\n".join(INDENT + i for i in s.split("\n"))


      def nix_stringify(s):
          # FIXME this doesn't handle string interpolation and possibly has more bugs
          return json.dumps(s)


      def sanitize_key(s):
          if s and s.isalnum() and not s[0].isdigit():
              return s
          return nix_stringify(s)


      def flatten_obj_item(k, v):
          keys = [k]
          val = v
          while isinstance(val, dict) and len(val) == 1:
              k = next(iter(val.keys()))
              keys.append(k)
              val = val[k]
          return keys, val


      def fmt_object(obj, flatten):
          fields = []
          for k, v in obj.items():
              if flatten:
                  keys, val = flatten_obj_item(k, v)
                  formatted_key = ".".join(sanitize_key(i) for i in keys)
              else:
                  formatted_key = sanitize_key(k)
                  val = v
              fields.append(f"{formatted_key} = {fmt_any(val, flatten)};")

          return "{\n" + indent("\n".join(fields)) + "\n}"


      def fmt_array(o, flatten):
          body = indent("\n".join(fmt_any(i, flatten) for i in o))
          return f"[\n{body}\n]"


      def fmt_any(o, flatten):
          if isinstance(o, str) or isinstance(o, bool) or isinstance(o, int):
              return json.dumps(o)
          if isinstance(o, list):
              return fmt_array(o, flatten)
          if isinstance(o, dict):
              return fmt_object(o, flatten)
          if o is None:
              return None
          raise TypeError(f"Unknown type {type(o)!r}")


      def main():
          flatten = "--flatten" in sys.argv
          args = [a for a in sys.argv[1:] if not a.startswith("--")]

          if len(args) < 1:
              print(f"Usage: {sys.argv[0]} [--flatten] <file.json>", file=sys.stderr)
              sys.exit(1)

          with open(args[0], "r") as f:
              data = json.loads(strip_comments(f.read()))

          print(fmt_any(data, flatten=flatten))


      if __name__ == "__main__":
          main()
    '')


    (writeShellScriptBin "gpg-fix" ''
      set -x
      ln -sf ${gpgSshSocket} /run/user/1000/sshagent
      sudo systemctl stop pcscd.service >/dev/null
      sudo systemctl stop pcscd.socket >/dev/null
      systemctl --user stop gpg-agent.service 2>/dev/null
      sudo pkill -f scdaemon
      sudo pkill -f gpg-agent
      systemctl --user restart gpg-agent.socket 2>/dev/null
      systemctl --user restart gpg-agent-extra.socket 2>/dev/null
      systemctl --user restart gpg-agent-ssh.socket 2>/dev/null
      export GPG_TTY=$(tty)
      gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1
      sleep 0.1
      sudo systemctl start pcscd.service >/dev/null
      sleep 0.1
      # check if key is known
      if ! gpg --list-keys "${gpgKeyId}" | grep "${gpgKeyId}" ; then
        curl -L https://github.com/colemickens.gpg | gpg --import
        (echo 5; echo y; echo save) |
          gpg --command-fd 0 --no-tty --no-greeting -q --edit-key "${gpgKeyId}" trust >/dev/null 2>&1
      fi
      gpg --card-status >/dev/null
      gpg-connect-agent "scd checkpin ${gpgCardId}" /bye
    '')
    
    (writeShellScriptBin "oa" ''
      "''${@}" \
        --override-input 'nixpkgs' ~/code/nixpkgs/cmpkgs \
        --override-input 'crosspkgs' ~/code/nixpkgs/crosspkgs \
        --override-input 'home-manager' ~/code/home-manager/cmhm \
        --override-input 'mobile-nixos' ~/code/mobile-nixos \
        --override-input 'nix-coreboot' ~/code/nix-coreboot
      '')

    (writeShellScriptBin "ssh-fix" ''
      ent="$(ls /tmp/ssh-**/agent.* | head -1)"
      ln -sf $ent /run/user/1000/sshagent
      export SSH_AUTH_SOCK="/run/user/1000/sshagent"
      ssh-add -L | ssh-add -T /dev/stdin
      ssh-add -l
    '')

    (writeShellScriptBin "dell-fix-power" ''
      oldval="$(sudo ${msr-tools}/bin/rdmsr 0x1FC)"
      newval="$(( 0xFFFFFFFE & 0x$oldval ))"
      sudo ${msr-tools}/bin/wrmsr -a 0x1FC "$newval"
      echo "hello"
    '')
    
    (writeShellScriptBin "vksway-nvidia" ''
      export VK_ICD_FILENAMES="/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json"
      export WLR_RENDERER=vulkan
      echo "nope, nvidia missing ext"
      exit -1
      systemctl import-environment --user VK_ICD_FILENAMES WLR_RENDERER
      xsway
    '')
    (writeShellScriptBin "vksway-radeon" ''
      export VK_ICD_FILENAMES="/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json"
      export WLR_RENDERER=vulkan
      systemctl import-environment --user VK_ICD_FILENAMES WLR_RENDERER
      xsway
    '')

    (writeShellScriptBin "bootnext" ''
      set -e
      term=$1
      next="$(sudo ${efibootmgr_} | rg --ignore-case "Boot(\d+)\*+ ''${term}.*" -r '$1')"
      sudo ${efibootmgr_} --bootnext "$next" >/dev/null

      next="$(sudo ${efibootmgr_} | rg --ignore-case "BootNext: (\d+)" -r '$1')"
      sudo ${efibootmgr_} | rg "Boot''${next}"
    '')
  ];
in
(symlinkJoin { name = "commands"; paths = drvs; })

