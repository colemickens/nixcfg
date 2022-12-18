#!/usr/bin/env nu

let-env NO_PAGER = 1
let-env GH_PAGER = "cat"
let USER = "colemickens"
let REPO = "nixcfg"

loop {
  let runs = (^gh api $"repos/($USER)/($REPO)/actions/runs?per_page=100&page=2" | from json)
  let runs = ($runs.workflow_runs)
  let runs = ($runs | select name id status node_id)
  let runs = ($runs | where status == "completed")
  $runs | get "id" | each { |it|
    print -e $"(ansi red)delete ($it)(ansi reset)"
    ^gh api $"repos/($USER)/($REPO)/actions/runs/($it)" -X DELETE
    if ($env.LAST_EXIT_CODE != 0) {
      error make { msg: "failed" }
    }
    sleep 1sec
  }
}