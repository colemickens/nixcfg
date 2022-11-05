# Nushell Environment Config File
# Use nushell functions to define your right and left prompt
def create_left_prompt [] {
    let hc = "@host_color@"
    let hcr = $"@host_color@_reverse"
    let hostname = (^hostname | str trim)
    let p1 = $"(ansi reset)(ansi $hc)╭(ansi $hcr)($hostname)(ansi reset)(ansi $hc)(ansi reset)";
    let p2 = $"(ansi reset)(ansi $hc)╰─▶ (ansi reset)";

    let path_segment = ($env.PWD | str replace $env.HOME "~")
    let path_segment = (if (is-admin) {
        $"(ansi red_bold)($path_segment)"
    } else {
      $"(ansi green_bold)($path_segment)"
    })

    let time = $"(ansi dark_gray)(date format '%T')(ansi reset)"
    let duration = (($env.CMD_DURATION_MS + "ms") | into duration --convert sec)
    let duration = $"(ansi reset)(ansi dark_gray_italic)($duration)(ansi reset)"
    
    let last_exit = if ($env.LAST_EXIT_CODE == 0) { [] } else {
      [ $"(ansi reset)(ansi red)(ansi red_reverse)($env.LAST_EXIT_CODE)(ansi reset)(ansi red)(ansi reset)" ]
    }
    
    let line1 = ([ $p1 $path_segment $last_exit $time $duration ] | flatten | str join ' ')
    let line2 = $p2
    $"($line1)\n($line2)"
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
