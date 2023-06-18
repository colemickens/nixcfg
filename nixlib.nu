#!/usr/bin/env nu

def header [ color: string text: string spacer="▒": string ] {
  let text = $"("" | fill -a r -c $spacer -w 2) ($text | fill -a l -c ' ' -w 80)"
  print -e $"(ansi $color)($text)(ansi reset)"
}

def evalFlakeRefs [ refs: list<string> ] {
  header "light_cyan_reverse" $"eval: ($refs)"

  let gcrootsdir = ([ $env.LOGDIR "gcroots" ] | path join)
  mkdir $gcrootsdir
  let o = (^nix-eval-jobs $refs
    --flake
    --gc-roots-dir $gcrootsdir
    --log-format bar-with-logs
    --force-recurse
    --check-cache-status
    | from json --objects)
  let o = ($o | where { true })
  $o
}

def buildDrvs [ drvs: table, doCache: bool ] {
  let archs = ($drvs | uniq-by system | get system)
  $archs | par-each { |arch|
    ## FILTER DRVS
    let fdrvs = ($drvs | where {|it| $it.system == $arch })
    let drvPaths = ($fdrvs | get drvPath)
    let outs = ($fdrvs | get outputs | get out)

    ## BUILDER
    let bp = $".builder.($arch)"
    let builder = (
      if ($bp | path exists) { (open $bp | str trim) }
      else { "localhost" })

    ## LOGGING
    let logdir = ([ $env.LOGDIR "logs" ] | path join)
    mkdir $logdir
    let log = ([ $logdir $arch ] | path join)
    let-env LOG_FILE = $log
    ^touch $log

    header "light_cyan_reverse" $"building on ($builder)"
    print -e { log: $log, builder: $builder }
    print -e ( $drvs | get drvPath )

    ## COPY DERIVATIONS
    loop {
      if ($builder != "") {
        let copycmd = ([
          nix copy
            --derivation
            --no-check-sigs
            --to $"ssh-ng://($builder)"
            $drvPaths
        ] | flatten)

        # TODO: nushell bug: run-external should take list<string>
        ^./runlog.sh $copycmd

        # don't keep looping if it looks like the copy was okay
        if (open $"($log)" | find "Too many root" | length) <= 0 {
          rm $"($log)"
          break
        }
        print -e "($arch): retrying copy"
      }
    }
 
    ## BUILD
    ## note: use ssh so we are sure nix flags get used to fullest...
    # UGH: doesn't work with old nix...
    let buildPaths = ($drvPaths | each {|d| $"($d)^*" }) # FCCCCKKK
    let cmd = ([ $"nix" "build" $nixflags $buildPaths "--no-link" "--print-out-paths"] | flatten)
    let cmd = (^printf '%q ' $cmd)

    ## CACHING
    let cmd = (if (not $doCache) { $cmd } else {
      let cmd = ([
          $"set -e -o pipefail;" $cmd $" | env CACHIX_SIGNING_KEY='($cachix_signing_key)' "
          $'nix-shell -I nixpkgs=($cachixpkgs_url) -p cachix --command "cat $x | cachix push ($cachix_cache)"'
        ] | flatten | str join ' ')
      let cmd = (^printf '%q ' $cmd)
      $cmd
    })

    let cmd = (if $builder == "localhost" { $cmd } else {
      ([ "ssh" $builder bash -c $cmd ] | flatten)
    })

    ^./runlog.sh $cmd

    mut success = true
    if (open $"($log)" | find "All done." | length) <= 0 {
      $success = false
    }

    # TODO: ???
    $success = true

    if $success {
      do -i {
        let pid = (open $"($log).pid" | str trim)
        print -e $"DEBUG: kill ($pid) since success"
        ^kill $pid
      }
    } else {
      error make { msg: $"build failed, check log ($log)" }
    }

    # let out_size = ((^stat -c "%s" $out | complete).stdout | str trim);
    # print -e $out_size
    # if ($out_size == "0") {
    #   cat $err out> /dev/stderr
    #   error make { msg: "probably failed build" }
    # }
    let x = ($outs | each { |o| { arch: $arch, out: $o } })
    print -e $x
    $x
    print -e $":: done ok? on ($builder)"
  }

  header "light_cyan_reverse" $"builds finished"
  # let res = ($res | flatten)
  # print -e $res
  # $res
}
