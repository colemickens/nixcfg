#!/usr/bin/env nu

# source ./main.nu

def "main ci update" [] {
  git switch -c $env.NIXCFG_CI_BRANCH

  ## TODO: use git-repo-manager to instantiate INPUTUP dirs and SWITCH to suffixed branches
  
  print "::group::inputup"
  main inputup
  print "::endgroup::"

  ## TODO: use git-repo-manager to push suffixed branches

  print "::group::lockup"
  main lockup
  print "::endgroup::"

  ## TODO: APPLY ALL LOCAL OVERRIDES FOR INPUTUPS

  print "::group::pkgup"
  main pkgup
  print "::endgroup::"

  print "::group::ciattrs"
  main ciattrs
  print "::endgroup::"

  print "::group::git-push"
  git push origin HEAD -f
  print "::endgroup::"
}

def "main ci precache" [host: string] {
  let drvs = (evalFlakeRef $".#toplevels.($host)")
  let drvs = ($drvs | where { true })
  buildDrvs $drvs true
  let out = ($drvs | get outputs | get out | first)
  deployHost false $host $out
}

