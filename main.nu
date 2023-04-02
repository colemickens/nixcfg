#!/usr/bin/env nu

let cachixpkgs = "https://github.com/nixos/nixpkgs/archive/nixos-unstable.tar.gz" # used by nix-shell cachix
let nix = "./misc/nix.sh"
let nixopts = [ "--builders-use-substitutes" "--option" "narinfo-cache-negative-ttl" "0"
  "--option" "extra-substituters" "'https://cache.nixos.org https://colemickens.cachix.org https://nixpkgs-wayland.cachix.org https://unmatched.cachix.org https://nix-community.cachix.org'"
  "--option" "extra-trusted-public-keys" "'cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= colemickens.cachix.org-1:bNrJ6FfMREB4bd4BOjEN85Niu8VcPdQe4F4KxVsb/I4= nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA= unmatched.cachix.org-1:F8TWIP/hA2808FDABsayBCFjrmrz296+5CQaysosTTc= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs='"
];
let builder_x86 = (if ("BUILDER_X86" in $env) { $env.BUILDER_X86 | str trim } else { $"cole@localhost" })
let builder_a64 = (if ("BUILDER_A64" in $env) { $env.BUILDER_A64 | str trim } else { $"colemickens@aarch64.nixos.community" })
let-env BUILDER_X86 = $builder_x86 # lazy
let-env BUILDER_A64 = $builder_a64 # Todo: lazy
# let builder_r64 = (if ("BUILDER_R64" in $env) { $env.BUILDER_R64 | str trim } else { $"cole@(^tailscale ip --4 visionfive2 | str trim)" })

let cachix_cache = "colemickens"
let-env CACHIX_SIGNING_KEY = (open $"/run/secrets/cachix_signing_key_colemickens" | str trim)

def header [ color: string text: string spacer="▒": string ] {
  let text = $"("" | fill -a r -c $spacer -w 2) ($text) "
  let text = $"($text | fill -a l -c $spacer -w 50)"
  print -e $"(ansi $color)($text)(ansi reset)"
}

def evalDrv [ ref: string ] {
  header "light_cyan_reverse" $"eval: ($ref)"
  let eval = (^nix-eval-jobs
    --flake $ref
    --check-cache-status)
  # let out = ($eval
  #   | from ssv --noheaders
  #   | get column1
  #   | each { |it| ($it | from json ) })
  # $out
  $eval
    | from ssv --noheaders
    | get column1
    | each { |it| ($it | from json ) }
}

def buildDrvs [ drvs: table ] {
  let builds = [
    {builder: $builder_a64, drvs: ($drvs | where system == "aarch64-linux")}
    {builder: $builder_x86, drvs: ($drvs | where system == "x86_64-linux")}
  ]
  for build in $builds {
    print -e $build
    buildDrvs__ $build.builder $build.drvs
    # if ($env.LAST_EXIT_CODE != 0) { error make { msg: $"failed to buildRemoteDrvs" } }
  }
}

def buildDrvs__ [ buildHost: string drvs: list ] {
  header "light_blue_reverse" $"build: ($drvs | length) drvs on ($buildHost)]"
  if ($drvs | length) == 0 { return; } # TODO_NUSHELL: xxx
  let drvPaths = ($drvs | get "drvPath") # TODO_NUSHELL: feels like this should be easier to deal with than having to length==0 guard against it

  ^$nix copy --no-check-sigs --to $"ssh-ng://($buildHost)" --derivation $drvPaths

  ^$nix build $nixopts --store $"ssh-ng://($buildHost)" -L $drvPaths
}

def cacheDrvs [ drvs: list ] {
  let builds = [
    {builder: $builder_a64, drvs: ($drvs | filter {|x| $x.system == "aarch64-linux"})}
    {builder: $builder_x86, drvs: ($drvs | filter {|x| $x.system == "x86_64-linux"})}
  ]
  ($builds | par-each { |it| 
    if ($it.drvs | length) == 0 { return; }
    # TODO: we can do better, hunt for any downstream drvs and push them even if we failed o do full build
    let outs = ($it.drvs | get outputs | flatten | get out | flatten)
    let outsStr = ($outs | each {|it| $"($it)(char nl)"} | str collect)
    header "purple_reverse" $"cache: remote: ($outs | length) paths"
    (^ssh $it.builder
      ([
        $"printf '%s' '($outsStr)' | env CACHIX_SIGNING_KEY='($env.CACHIX_SIGNING_KEY)' "
        $"nix-shell -I nixpkgs=($cachixpkgs) -p cachix --command 'cachix push ($cachix_cache)'"
      ] | str join ' ')
    )
    # if ($env.LAST_EXIT_CODE != 0) { error make { msg: "failed to something..." } }
  })
}

def downDrvs [ drvs: table target: string ] {
  header "purple_reverse" $"download: ($target): $drvs"
  let builds = ($drvs | get outputs | get out)
  ^ssh $"cole@($target)" (([ "nix" "build" "--no-link" "-j0" $nixopts $builds ] | flatten) | str join ' ')
  # if ($env.LAST_EXIT_CODE != 0) {
  #   error make { msg: $"failed to down to ($target)"}
  # }
}

def deployHost [ host: string ] {
  let target = (tailscale ip --4 $host | str trim)
  header light_gray_reverse $"deploy: ($host) -> ($target)"
  let drvs = (evalDrv $"/home/cole/code/nixcfg#toplevels.($host)")
  # NUSHELL BUG:
  let drvs = ($drvs | where { |it| $it.isCached == false or $it.isCached == true})
  # print -e ($drvs | get outputs)
  buildDrvs $drvs
  cacheDrvs $drvs
  downDrvs $drvs $target
  let topout = ($drvs | get "outputs" | flatten | get "out" | flatten | first)
  let cs = (do -c { ^ssh $"cole@($target)" $"readlink -f /run/current-system" } | str trim)
  if ($cs == $topout) { header light_purple_reverse $"deploy: ($host): already up-to-date"; return }

  header light_purple_reverse $"deploy: ($host): apply and switch"
  ^ssh $"cole@($target)" (([ "sudo" "nix" "build" "--no-link" "-j0" $nixopts "--profile" "/nix/var/nix/profiles/system" $topout ] | flatten) | str join ' ')
  # if ($env.LAST_EXIT_CODE != 0) { error make { msg: $"failed to down to ($target)"} }
  ^ssh $"cole@($target)" $"sudo '($topout)/bin/switch-to-configuration' switch"
  # if ($env.LAST_EXIT_CODE != 0) {  error make { msg: $"failed to switch for ($host)"} }
}

def "main build" [ drv: string ] {
  let drvs = (evalDrv $drv)
  # NUSHELL BUG:
  let drvs = ($drvs | where { |it| $it.isCached == false or $it.isCached == true})
  buildDrvs $drvs
  downDrvs $drvs "localhost"
}
def "main cache" [ drv: string ] {
  let drvs = (evalDrv $drv)
  # NUSHELL BUG:
  let drvs = ($drvs | where { |it| $it.isCached == false or $it.isCached == true})
  buildDrvs $drvs
  cacheDrvs $drvs
}

# def "main deploy" [ h: list ] {
def "main deploy" [...h] {
  let h = ($h | flatten)
  let h = (if ($h | length) != 0 { $h } else {
    let ref = $".#deployConfigs"
    do -c { ^nix eval --json --apply "x: builtins.attrNames x" $ref }
      | complete | get stdout | from json
  })
  let h = ($h | flatten)
  header light_gray_reverse $"DEPLOY"
  print -e $h
  $h | flatten | each { |h| deployHost $h }
}

def "main inputup" [] {
  header yellow_reverse "inputup"
  let srcdirs = ([
    # nixpkgs and related branches
    "nixpkgs/master" "nixpkgs/cmpkgs"
    # BUG: temp disable
    # BUG: "nixpkgs/cmpkgs-cross" "nixpkgs/cmpkgs-cross-riscv64"
    
    # exclude rpipkgs/cmpkgs-rpipkgs, that is managed by `rpiup`
    
    # home manager master/cmhm
    "home-manager/master" "home-manager/cmhm"

    # tow-boot and friends
    "tow-boot/development" "tow-boot/development-flakes"
    # "tow-boot/rpi" "tow-boot/radxa-zero" "tow-boot/radxa-rock5b" "tow-boot/visionfive"

    # mobile-nixos and friends
    "mobile-nixos/master"
    "mobile-nixos/master-flakes"
    # "mobile-nixos/openstick" "mobile-nixos/pinephone-emmc" "mobile-nixos/reset-scripts" "mobile-nixos/sdm845-blue"
    
    # BUG: nixos-riscv64 - temporarily disabled
    # "nixos-riscv64"

    # flake-firefox-nightly (not checked out anymore unless troubleshooting)
    # "flake-firefox-nightly"
    
    # nixpkgs-wayland
    "nixpkgs-wayland/master"
  ] | each { |it1| $it1 | each {|it| $"($env.HOME)/code/($it)" } })

  let srcdirs = ($srcdirs | append (["linux/master"] | each {|it| $"($env.HOME)/code-ext/($it)"}))

  for dir in $srcdirs {
  # $srcdirs | each { |dir|
    print -e $"input: ($dir): (ansi yellow_dimmed)check(ansi reset)"

    # rebase, ignore if we're not rebasing
    do -i { ^git -C $dir rebase --abort }
    ^git -C $dir pull --rebase --no-gpg-sign
    ^git -C $dir push origin HEAD -f

    print -e $"input: ($dir): (ansi green)ok(ansi reset)"
  }

  print -e "input: finished inputup"
}

def "main pkgup_old" [] {
  header yellow_reverse "pkgup"
  do {
    cd pkgs
    ^./main.nu update
  }
}

def "main pkgup" [] {
  header yellow_reverse "pkgup2"

  let pkgs = (
    ^nix eval --json
      $".#packages.x86_64-linux"
      --apply 'x: builtins.attrNames x'
    | str trim
    | from json)

  for pkgname in $pkgs {
    print -e $"pkgup: ($pkgname)"
    (nix-update
      --flake
      --version branch
      $"pkgs.x86_64-linux.($pkgname)")

    ^git commit --no-gpg-sign $"./pkgs/($pkgname)"
  }

  let pkgs_ = ($pkgs | each {|p| $".#packages.x86_64-linux.($p)" })
  nix build $nixopts $pkgs_
}

def "main rpiup" [] {
  header yellow_reverse "rpiup"
  # ^./misc/rpi/rpi-update.nu
}
def "main lockup" [] {
  header yellow_reverse "lockup"
  ^$nix flake lock --recreate-lock-file
}
def "main cache_x86" [] {
  header yellow_reverse "cache_x86"
  main cache "'/home/cole/code/nixcfg#ciJobs.x86_64-linux.default'"
}
def "main cache_a64" [] {
  header yellow_reverse "cache_a64"
  main cache "'/home/cole/code/nixcfg#ciJobs.aarch64-linux.default'"
}
def "main up" [] {
  header red_reverse "up" "▒"

  main inputup
  main pkgup
  main rpiup
  main lockup
  main cache_x86
  main deploy
  main cache_a64
}

def "main selfdeploy" [] {
  nom build $nixopts $"/home/cole/code/nixcfg#toplevels.(^hostname | str trim)" --out-link /tmp/selfup
  sudo nix build --profile /nix/var/nix/profiles/system /tmp/selfup
  sudo /tmp/selfup/bin/switch-to-configuration switch
  rm /tmp/selfup
}
def "main selfup" [] {
  main inputup
  main pkgup
  main rpiup
  main lockup
  main selfdeploy
}
def main [] { main up }

## action-rpiup ###############################################################
def "main action-rpiup" [] {
  # TODO: we gotta clone repos and stuff, right?
  main rpiup
}

## action-nextci ###############################################################
def updateInput [ name: string baseBr: string newBr: string upRemoteName: string upstreamUrl: string upstreamBr: string ] {
  let originUrl = $"https://github.com/colemickens/($name)"
  let baseDir = $"($env.PWD)/../($name)/($baseBr)"
  let newDir = $"($env.PWD)/../($name)/($newBr)"
  if (not ($baseDir | path exists)) {
    do -c { mkdir $baseDir }
    do -c { git clone $originUrl -b $baseBr $baseDir }
  }
  if (not ($newDir | path exists)) {
    echo $"check ($newDir)"
    (git -C $baseDir remote add "$upRemoteName" $upstreamUrl)
    rm -rf $newDir
    (git -C $baseDir worktree prune)
    (git -C $baseDir branch -D $newBr)
    do -c { git -C $baseDir worktree add $newDir }
  }

  do -c {
    git -C $newDir reset --hard $baseBr
    git -C $newDir rebase $"($upRemoteName)/($upstreamBr)"
    git -C $newDir push origin HEAD
  }
}

def "main action-nextci" [] {
  let id = "xyz"
  updateInput $"home-manager" "cmhm" $"cmhm-next-($id)" "nix-community" "https://github.com/nix-community/home-manager" "master"
  updateInput $"nixpkgs" "cmpkgs" $"cmpkgs-next-($id)" "nixos" "https://github.com/nixos/nixpkgs" "nixos-unstable"
  
  let p = $"($env.PWD)/../nixcfg_main-next-($id)"
  if (not ($p | path exists)) {
    rm -rf $p
    git worktree prune
    git worktree add $p
  }
  
  do {
    git -C $p rebase main

    do {
      cd $p
      let args = [
        --recreate-lock-file
        --override-input 'nixpkgs' $"github:colemickens/nixpkgs/cmpkgs-next-($id)"
        --override-input 'home-manager' $"github:colemickens/home-manager/cmhm-next-($id)"
        --commit-lock-file
      ]
      nix flake lock $args
  
      ./main.nu ci eval
      ./main.nu ci build
      ./main.nu ci push
    }
    
    git push origin $"nixcfg_main-next-($id):main-next-($id)" -f
  }
}
