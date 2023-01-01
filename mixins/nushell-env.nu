# Nushell Environment Config File
# Use nushell functions to define your right and left prompt

def create_left_prompt [] {
    let hc = "@host_color@"
    let hcr = $"@host_color@_reverse"
    let hnseg = $"(ansi reset)(ansi $hcr) (^hostname | str trim) (ansi reset)"
    
    let line1 = $"(ansi reset)(ansi $hc)╭($hnseg)";
    let line2 = $"(ansi reset)(ansi $hc)╰─▶ (ansi reset)";
    
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

    let duration = (($env.CMD_DURATION_MS + "ms") | into duration --convert sec | str replace " sec" "s" | str trim)
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
      # $jj
      # $git
      $duration
      $last_exit
    ] | flatten | str join $"(ansi reset) ")
    $"\n($line1)\n($line2)(ansi reset)"
}
let-env PROMPT_COMMAND = { create_left_prompt }
let-env PROMPT_COMMAND_RIGHT = { "" }
# The prompt indicators are environmental variables that represent
# the state of the prompt
let-env PROMPT_INDICATOR = { $"" } 
let-env PROMPT_INDICATOR_VI_INSERT = { ": " }
let-env PROMPT_INDICATOR_VI_NORMAL = { "→ " }
let-env PROMPT_MULTILINE_INDICATOR = { "::: " }
# <starship>
# let-env STARSHIP_SHELL = "nu"
# let-env STARSHIP_SESSION_KEY = (random chars -l 16)
# let-env PROMPT_MULTILINE_INDICATOR = (^starship prompt --continuation)

# # Does not play well with default character module.
# # TODO: Also Use starship vi mode indicators?
# let-env PROMPT_INDICATOR = ""

# let-env PROMPT_COMMAND = {
#     # jobs are not supported
#     let width = (term size -c | get columns | into string)
#     ^starship prompt $"--cmd-duration=($env.CMD_DURATION_MS)" $"--status=($env.LAST_EXIT_CODE)" $"--terminal-width=($width)"
# }

# Not well-suited for `starship prompt --right`.
# Built-in right prompt is equivalent to $fill$right_format in the first prompt line.
# Thus does not play well with default `add_newline = True`.
# let-env PROMPT_COMMAND_RIGHT = { "" }
# </starship>

# Specifies how environment variables are:
# - converted from a string to a value on Nushell startup (from_string)
# - converted from a value back to a string when running external commands (to_string)
# Note: The conversions happen *after* config.nu is loaded
let-env ENV_CONVERSIONS = {
  "PATH": {
    from_string: { |s| $s | split row (char esep) | path expand -n }
    to_string: { |v| $v | path expand -n | str join (char esep) }
  }
  "Path": {
    from_string: { |s| $s | split row (char esep) | path expand -n }
    to_string: { |v| $v | path expand -n | str join (char esep) }
  }
}
# Directories to search for scripts when calling source or use
#
# By default, <nushell-config-dir>/scripts is added
let-env NU_LIB_DIRS = [
    ($nu.config-path | path dirname | path join 'scripts')
]
# Directories to search for plugin binaries when calling register
#
# By default, <nushell-config-dir>/plugins is added
let-env NU_PLUGIN_DIRS = [
    ($nu.config-path | path dirname | path join 'plugins')
]
# To add entries to PATH (on Windows you might use Path), you can use the following pattern:
# let-env PATH = ($env.PATH | split row (char esep) | prepend '/some/path')
