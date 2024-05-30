# Nushell Config File
#
# version = "0.93.1"

# source-env ~/.config/nushell/stock.nu;
# const s = $"($env.FILE_PWD)/stock.nu";
source-env ~/.config/nushell/stock.nu

let carapace_completer = {|spans|
    carapace $spans.0 nushell ...$spans | from json
}

let nix_direnv_hook = { ||
    if (which direnv | is-empty) {
        return
    }
    direnv export json | from json | default {} | load-env
};

# $env.config = ($env.config |
#     upsert completions.external.completer $carapace_completer)

# $env.config = ($env.config |
#     upsert hooks.pre_prompt $nix_direnv_hook)
$env.config.hooks.pre_prompt = [$nix_direnv_hook];
