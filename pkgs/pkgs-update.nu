#!/usr/bin/env nu

let system = "x86_64-linux"
let packageNames = (nix eval --json $".#packages.($system)" --apply 'x: builtins.attrNames x' | str trim | from json)
let fakeSha256 = "0000000000000000000000000000000000000000000000000000";

def getBadHash [ attrName: string ] {
  
  (do -i { ^nix build --no-link $attrName }| complete)
      | get stderr
      | split row "\n"
      | where ($it | str contains "got:")
      | str replace '\s+got:(.*)(sha256-.*)' '$2'
      | get 0
}

$packageNames | each { |packageName|
  let verinfo = (nix eval --json $".#packages.($system).($packageName).passthru.verinfo" | str trim | from json)
  let meta = (nix eval --json $".#packages.($system).($packageName).meta" | str trim | from json)

  print -e $verinfo
  print -e $meta
  
  let position = ($meta.position | str replace "/nix/store/([0-9a-z-]+)/pkgs/" "")
  let position = ($position | str replace ':([0-9]+)' "")

  # Try update rev
  let newrev = (
    if "repo_git" in ($verinfo | transpose | get column0) {
      (do -c {
        ^git ls-remote $"($verinfo.repo_git)" $"refs/heads/($verinfo.branch)"
      } | complete | get stdout | str trim | str replace '(\s+)(.*)$' '')
    } else if "repo_hg" in ($verinfo | transpose | get column0) {
      (do -c {
        ^git ls-remote $"($verinfo.repo_git)" $"refs/heads/($verinfo.branch)"
        ^hg identify $"$(verinfo.repo_hg)" -r $"$(verinfo.branch)"
      } | complete | get stdout | str trim)
    } else {
      error make { msg: "unknown repo type" }
    }
  )
  print -e $"[($packageName)]: oldrev='($verinfo.rev)'"
  print -e $"[($packageName)]: newrev='($newrev)'"
  
  if $newrev != $verinfo.rev {
    print -e $"[($packageName)]: needs update!"
  
    do -c { ^sd -s $"($verinfo.sha256)" $"($fakeSha256)" $"($position)" }
    let newSha256 = (getBadHash $".#($packageName)")
    print -e $"[($packageName)]: newSha256='($newSha256)'"
    do -c { ^sd -s $"($fakeSha256)" $"($newSha256)" $"($position)" }
    
    if "vendorSha256" in ($verinfo | transpose | get column0) {
      do -c { ^sd -s $"($verinfo.vendorSha256)" $"($fakeSha256)" $"($position)" }
      let newVendorSha256 = (getBadHash $".#($packageName)")
      print -e $"[($packageName)]: newVendorSha256='($newVendorSha256)'"
      do -c { ^sd -s $"($fakeSha256)" $"($newVendorSha256)" $"($position)" }
    }
    if "cargoSha256" in ($verinfo | transpose | get column0) {
      do -c { ^sd -s $"($verinfo.cargoSha256)" $"($fakeSha256)" $"($position)" }
      let newCargoSha256 = (getBadHash $".#($packageName)")
      print -e $"[($packageName)]: newCargoSha256='($newCargoSha256)'"
      do -c { ^sd -s $"($fakeSha256)" $"($newCargoSha256)" $"($position)" }
    }
  }

  null
}

# nixargs=(--experimental-features 'nix-command flakes')
# buildargs=(
#   --option 'extra-binary-caches' 'https://cache.nixos.org https://nixpkgs-wayland.cachix.org'
#   --option 'trusted-public-keys' 'cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA='
#   --option 'build-cores' '0'
#   --option 'narinfo-cache-negative-ttl' '0'
# )
# ## the rest should be generic across repos that use `update.sh`+`metadata.nix`
# if [[ "${1:-""}" != "" ]]; then
#   ##
#   ## internal script (called in parallel)
#   ##
#   t="$(mktemp)"; trap "rm ${t}" EXIT;
#   m="$(mktemp)"; trap "rm ${m}" EXIT;
#   l="$(mktemp)"; trap "rm ${l}" EXIT;
#   pkg="${1}"
#   pkgname="$(basename "${pkg}")"
#   printf '\n%s\n' ">>> update: ${pkgname}"
#   if ! nix eval --json "..#packages.x86_64-linux.${pkgname}.passthru.verinfo" >"${t}" ; then
#     echo "NO VERINFO"
#     exit -1
#   fi
#   if ! nix eval --json "..#packages.x86_64-linux.${pkgname}.meta.position" >"${t}.position"; then
#     echo "NO POSITION"
#     exit -1
#   fi
#   metadata="$(cat "${t}.position" | jq -r)"
#   # trim off the filenumber
#   # trim off the store path (assume its in here)
#   metadata=$(echo "${metadata}" | cut -d':' -f1)
#   metadata="${DIR}/$(echo "${metadata}" | cut -d'/' -f6-)"
#   branch="$(cat "${t}" | jq -r .branch)"
#   rev="$(cat "${t}" | jq -r .rev)"
#   sha256="$(cat "${t}" | jq -r .sha256)"
#   upattr="$(cat "${t}" | jq -r .upattr)";  # optional, but set if not user-set
#   if [[ "${upattr}" == "null" ]]; then upattr="${pkgname}"; fi
#   url="$(cat "${t}" | jq -r .url)" # optional
#   cargoSha256="$(cat "${t}" | jq -r .cargoSha256)" # optional
#   vendorSha256="$(cat "${t}" | jq -r .vendorSha256)" # optional
#   skip="$(cat "${t}" | jq -r .skip)" # optional
#   repo_git="$(cat "${t}" | jq -r .repo_git)" # optional
#   repo_hg="$(cat "${t}" | jq -r .repo_hg)" # optional
#   if [[ "${skip}" == "true" ]]; then
#     echo "skipping (pinned to ${rev})"
#     exit 0
#   fi
#   # grab the latest rev from the repo (supports: git, merucurial)
#   if [[ "${repo_git}" != "null" ]]; then
#     repotyp="git";
#     repo="${repo_git}"
#     newrev="$(git ls-remote "${repo}" "refs/heads/${branch}" | awk '{ print $1}')"
#   elif [[ "${repo_hg}" != "null" ]]; then
#     repotyp="hg";
#     repo="${repo_hg}"
#   else
#     echo "unknown repo_typ"
#     exit 1;
#   fi
#   # early quit if we don't need to update
#   if [[ "${rev}" == "${newrev}" && "${FORCE_RECHECK:-""}" != "true" ]]; then
#     echo "up-to-date (${rev})"
#     exit 0
#   fi
#   echo "${rev} => ${newrev}"
#   # Update Sha256
#   set -x
#   sed -i "s|${rev}|${newrev}|" "${metadata}"; echo $?
#   sed -i "s|${sha256}|0000000000000000000000000000000000000000000000000000|" "${metadata}"
# fi
# ##
# ## main script
# ##
# # updates galore
# pkgslist=()
# for p in `ls -v -d -- ./*/ | sort -V`; do
#   "${0}" "${p}"
# done
# exit 0
