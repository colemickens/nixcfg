#!/usr/bin/env nu

def header [ color: string text: string spacer="▒": string ] {
  let text = $"("" | fill -a r -c $spacer -w 2) ($text | fill -a l -c ' ' -w 80)"
  print -e $"(ansi $color)($text)(ansi reset)"
}

def autoCacheDrvs [ options: record, arch: string, flakeRefs: list ] {
  let buildPaths = (autoBuildDrvs $options $arch $flakeRefs)
  cacheDrvs $options $arch $buildPaths
}

def autoBuildDrvs [ options: record, arch: string flakeRefs: list] {
  let buildHost = ($options.builders | get $arch)
  header "light_gray_reverse" $"build: ($arch): ($flakeRefs | length) drvs on ($buildHost)"
  print -e $flakeRefs
  
  mut nf = ($options.nixflags | append [ "--print-out-paths" ])
  if ($buildHost != "") {
    $nf = ($nf | append [ "--eval-store" "auto" "--store" $"ssh-ng://($buildHost)" ])

    nix copy --derivation --to $"ssh-ng://($buildHost)" --no-check-sigs $flakeRefs
  }
  
  let buildPaths = (^nix build $nf -L $flakeRefs | from ssv -n | get column1)

  $buildPaths
}

def cacheDrvs [ options: record, arch: string, outs: list ] {
  let buildHost = ($options.builders | get $arch)
  header "light_gray_reverse" $"cache: ($outs | length) paths: ($buildHost)"
  
  let outsStr = ($outs | str join $"(char nl)")
  print -e $"CACHE STR: ($outsStr)"
  let cmd = ([
      $"printf '%s' '($outsStr)' | env CACHIX_SIGNING_KEY='($options.cachix.signkey)' "
      $"nix-shell -I nixpkgs=($options.cachix.pkgs) -p cachix --command 'cachix push ($options.cachix.cache)'"
   ] | str join ' ')
    
  if $buildHost == "" {
    ^sh -c $cmd
  } else {
   ^ssh $buildHost $cmd
  }
  $outs
}
