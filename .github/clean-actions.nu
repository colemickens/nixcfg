#!/usr/bin/env nu

let-env NO_PAGER = 1
let-env GH_PAGER = "cat"
let USER = "colemickens"
let REPO = "nixcfg"

for i in 1..20 {
  let runs = (^gh api $"repos/($USER)/($REPO)/actions/runs" | from json)
  print -e $runs
  let ids = ($runs.workflow_runs
    | where ($it.name != "default" && $it.name != "clean")
    | get "id")
  
  $ids | window 4 --stride 4 --remainder | each { |it1|
    par-each { |it2|
      print -e $"(ansi red)delete ($it2)(ansi reset)"
      let res = (do -i { ^gh api $"repos/($USER)/($REPO)/actions/runs/($it2)" -X DELETE } | complete)
      { id:$it2, exit:$res.exit_code, stderr:($res.stderr | str trim) }
    }
  } | flatten
}