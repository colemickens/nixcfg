# Nushell Config File

source-env ~/.config/nushell/stock.nu

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

