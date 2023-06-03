#!/usr/bin/env nu

def header [ color: string text: string spacer="▒": string ] {
  let text = $"("" | fill -a r -c $spacer -w 2) ($text | fill -a l -c ' ' -w 80)"
  print -e $"(ansi $color)($text)(ansi reset)"
}

def evalFlakeRefs [ refs: list<string> ] {
  header "light_cyan_reverse" $"eval: ($refs)"

  let gcrootsdir = ([ $env.NIXLIB_OUTPUT_DIR "gcroots" ] | path join)
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

def buildDrvs [ options: record, drvs: table, doCache: bool ] {
  let archs = ($drvs | uniq-by system | get system)
  # let res = (for arch in $archs {
  $archs | par-each { |arch|
    let fdrvs = ($drvs | where {|it| $it.system == $arch })
    let builder = ($options.builders | get $arch)
    let nf = ($options.nixflags | append $builder.nixflags)
    let builder = ($builder | get url)

    let drvPaths = ($fdrvs | get drvPath)
    let outs = ($fdrvs | get outputs | get out)

    ## LOGGING
    let log = ([ $env.NIXLIB_OUTPUT_DIR "logs" ] | path join)
    mkdir $log
    let log = ([ $log $arch ] | path join)
    ^touch $"($log).out" $"($log).err"

    header "light_cyan_reverse" $"building on ($builder)"
    print -e { log: $log, builder: $builder }
    zellij action new-pane -c -d down -- bash -c $"tail -f ($log).err & echo $! > ($log).pid; wait"

    ## COPY DERIVATIONS
    loop {
      if ($builder != "") {
        let copycmd = ([
          nix copy
            --derivation
            --no-check-sigs
            --to $"ssh-ng://($builder)"
            $drvPaths
        ]
        | flatten
        #| str join ' '
        )

        # TODO: nushell bug: run-external should take list<string>
        
        with-env { LOG_OUT: $"($log).out", LOG_ERR: $"($log).err" } {
          ^./runlog.sh $copycmd
        }

        # don't keep looping if it looks like the copy was okay
        if (open $"($log).err" | find "Too many root" | length) <= 0 {
          rm $"($log).err" $"($log).out"
          break
        }
        print -e "($arch): retrying copy"
      }
    }
 
    ## BUILD
    ## note: use ssh so we are sure nix flags get used to fullest...
    # UGH: doesn't work with old nix...
    let buildPaths = ($drvPaths | each {|d| $"($d)^*" }) # FCCCCKKK
    let cmd = ([ $"nix" "build" $nf $buildPaths "--no-link" "--print-out-paths"] | flatten)
    let cmd = (^printf '%q ' $cmd)

    ## CACHING
    let cmd = if (not $doCache) { $cmd } else {
      # let outsStr = ($outs | str join $"(char nl)")
      # print -e $"CACHE STR: ($outsStr)"
          # $"set -e -o pipefail; x=$\(mktemp\); ($cmd) >$x; env CACHIX_SIGNING_KEY='($options.cachix.signkey)' "
          # $"nix-shell -I nixpkgs=($options.cachix.pkgs) -p cachix --command \"cat $x | cachix push ($options.cachix.cache)\""
      let cmd = ([
          $"set -e -o pipefail;" $cmd $" | env CACHIX_SIGNING_KEY='($env.CACHIX_SIGNING_KEY)' "
          $'nix-shell -I nixpkgs=($options.cachix.pkgs) -p cachix --command "cat $x | cachix push ($options.cachix.cache)"'
        ]
        |flatten
        | str join ' ')
      let cmd = (^printf '%q ' $cmd)
      $cmd
    }

    let cmd = (if $builder == "" { $cmd } else {
      ([ "ssh" $builder bash -c $cmd ] | flatten)
    })
    with-env { LOG_OUT: $"($log).out", LOG_ERR: $"($log).err" } {
      # TODO: connect to nushell bug above, this is awkward:
      # if $builder == "" {
      #   # ^sh -c $cmd out+err> $"($log)"
      #   (^sh -c $cmd
      #     | save -f $"($buildlog).out" --stderr $"($buildlog).err")
      # } else {
      #   (run-external --redirect-stdout --redirect-stderr
      #     ssh $builder $cmd
      #       | save -f $"($buildlog).out" --stderr $"($buildlog).err")
      # }
      ^./runlog.sh $cmd
    }
    let pid = (open $"($log).pid" | str trim)
    mut success = true
    if (open $"($log).err" | find "All done." | length) <= 0 {
      $success = false
    }

    # TODO: ???
    $success = true

    if $success {
      print -e $"DEBUG: kill ($pid) since success"
      ^kill $pid
    } else {
      error make { msg: $"build failed, check log ($log).err" }
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
