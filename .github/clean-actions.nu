#!/usr/bin/env nu

let-env NO_PAGER = 1
let-env GH_PAGER = "cat"

let runurl = $"repos/($env.GITHUB_REPOSITORY)/actions/runs"

loop {
  let runs = (^gh api $"($runurl)?per_page=100&status=completed" | from json)
  print -e $runs
  if $runs.total_count == 0 {
    break
  }
  ($runs
    | get -i workflow_runs
    | select name id status node_id
    | each { |it|
      sleep 1sec
      let id = $it.id
      let delurl = $"($runurl)/($id)"
      print -e $"(ansi red)delete ($delurl)(ansi reset)"
      ^gh api $"($delurl)" -X DELETE
      if ($env.LAST_EXIT_CODE != 0) {
        error make { msg: "failed" }
      }
    }
  )
}

print -e $"(ansi green_reverse)all done(ansi reset)"
