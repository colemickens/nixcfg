# Nushell Environment Config File
# Use nushell functions to define your right and left prompt

def create_left_prompt [] {
    let hc = "@host_color@"
    let hcr = $"@host_color@_reverse"
    let hnseg = $"(ansi reset)(ansi $hcr) (^hostname | str trim) (ansi reset)"

    let nixshell = (if ("name" in $env) { $"(ansi red)($env.name)(ansi reset)" } else { "" })

    let line1 = $"(ansi reset)(ansi $hc)╭($hnseg)";
    let line2 = $"(ansi reset)(ansi $hc)╰─▶(ansi reset)";
    
    # let jj = (do -i { ^jj log --no-commit-working-copy --no-graph -T '"x"' }
    #   | complete 
    #   | get -i stdout
    #   | str trim
    #   | where ($it != $nothing)
    #   | each { |j|
    #     let cc =  (($j | size).chars)
    #     let c1 = "light_yellow_bold"; let c2 = "light_yellow"
    #     let msg = $"($cc)"
    #     # $"(ansi $"($c)_bold")jj(ansi reset) (ansi $c)($msg)"
    #     $"(ansi $c1)│(ansi reset)(ansi $c2)($msg)"
    #   }
    # )
    # let git = (do -i { ^git branch --show-current }
    #   | complete 
    #   # | where $it.exit_code == 0
    #   | get -i stdout
    #   | str trim
    #   | where ($it != $nothing)
    #   | each { |branch|
    #     let e = (^git diff-index --quiet HEAD '--' | complete | get exit_code)
    #     let i = (if ($e == 0) { "" } else { "*" })
    #     let c = (if ($e == 0) { "green" } else { "yellow" }); let c1 = $"light_($c)_dimmed"; let c2 = $"light_($c)_dimmed"
    #     $"(ansi $c1)│(ansi reset)(ansi $c2)($branch)($i)"
    #   }
    # )

    let psc = if (is-admin) { "red_bold" } else { "default_bold" }
    let pathseg = $"(ansi default_underline)(ansi $psc)($env.PWD | str replace $env.HOME "~")"

    # let duration = (($env.CMD_DURATION_MS + "ms") | into duration --convert sec | str replace " sec" "s" | str trim) # TODO?
    let duration = (($env.CMD_DURATION_MS + "ms") | into duration | str trim)
    let duration = $"(ansi dark_gray_italic)($duration)"

    # let builder1 = $"x86:($env.BUILDER_X86 | string split "." | string replace "(.+)@" "")"
    # let builder2 = $"a64:($env.BUILDER_A64 | string split "." | string replace "(.+)@" "")"
    # let builder = $"($builder1) ($builder2)"
    
    let last_exit = if ($env.LAST_EXIT_CODE == 0) { [] } else {
      [ $"(ansi light_red_bold)✘($env.LAST_EXIT_CODE | str trim)" ]
    }
    
    let line1 = ([
      $line1
      $pathseg
      $nixshell
      # $jj
      # $git
      $duration
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
