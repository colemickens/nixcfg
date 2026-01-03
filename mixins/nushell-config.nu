
# host_color injected above here ^

$env.config.show_banner = false;

let carapace_completer = {|spans|
    carapace $spans.0 nushell ...$spans | from json
}
$env.config.completions.external.completer = $carapace_completer

let nix_direnv_hook = { ||
    if (which direnv | is-empty) {
        return
    }
    direnv export json | from json | default {} | load-env
};

$env.config = ($env.config | upsert hooks.pre_prompt { append $nix_direnv_hook })

##
## PROMPT STUFFS
##

def create_left_prompt [] {
    let hsc = { # host slug color
      fg: $"($host_color)_reverse"
      attr: "br"
    }

    let line1 = $"(ansi reset)(ansi $host_color)╭(ansi $hsc) (hostname) (ansi reset)";
    let line2 = $"(ansi reset)(ansi $host_color)╰🡒 (ansi reset)";

    let nixshell = (if ("name" in $env) { $"(ansi red)($env.name)(ansi reset)" } else { "" })

    let jj = try {
      with-env { PAGER: "cat" } {
        let jjs = (do { ^jj log ...[
          -r 'trunk()..@ & branches()'
          -T 'branches.join("\n") ++ "\n"'
          --no-graph
          --ignore-working-copy ] } | complete)
        if ($jjs.exit_code == 0) {
          $"(ansi purple)($jjs.stdout | str trim | str replace --all --multiline '\n' ' ')(ansi reset)"
        } else {
          ""
        }
      }
    } catch {
      ""
    }

    let psc = if (is-admin) { "red_bold" } else { "default_bold" }
    let pathseg = $"(ansi default_underline)(ansi $psc)($env.PWD | str replace $env.HOME "~")"

    let duration = (($env.CMD_DURATION_MS + "ms") | into duration)
    let duration = $"(ansi dark_gray_italic)($duration)"

    let last_exit = if ($env.LAST_EXIT_CODE == 0) { [] } else {
      [ $"(ansi light_red_bold)✘($env.LAST_EXIT_CODE)" ]
    }
    
    let line1 = ([
      $line1
      $pathseg
      $nixshell
      $duration
      $jj
      $last_exit
    ] | flatten | str join $"(ansi reset) ")
    $"\n($line1)\n($line2)(ansi reset)"
}
$env.PROMPT_COMMAND = { || create_left_prompt }
$env.PROMPT_COMMAND_RIGHT = { || "" }

$env.PROMPT_INDICATOR = {|| " " }
$env.PROMPT_INDICATOR_VI_INSERT = {|| ": " }
$env.PROMPT_INDICATOR_VI_NORMAL = {|| "> " }
$env.PROMPT_MULTILINE_INDICATOR = {|| "::: " }
