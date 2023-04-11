#!/usr/bin/env nu

let-env NO_PAGER = 1
let-env GH_PAGER = "cat"

let keep_runs = 10

let runurl = $"repos/($env.GITHUB_REPOSITORY)/actions/runs"

loop {
  let runs = (^gh api $"($runurl)?per_page=100&status=completed" | from json)

  let wf_runs = ($runs | get -i workflow_runs | skip $keep_runs)

  if ($wf_runs | length) == 0 {
    print -e "nothing to do!"
    break
  }

  ($wf_runs
    | select name id status node_id
    | each { |it|
      sleep 1sec
      let id = $it.id
      let delurl = $"($runurl)/($id)"
      print -e $"(ansi red)delete ($delurl)(ansi reset)"
      ^gh api $"($delurl)" -X DELETE
    }
  )
}

print -e $"(ansi green_reverse)all done(ansi reset)"
