# Nushell Config File
#
# version = "0.93.1"

# source-env ~/.config/nushell/stock.nu;
# const s = $"($env.FILE_PWD)/stock.nu";
source-env ~/.config/nushell/stock.nu

let carapace_completer = {|spans|
    carapace $spans.0 nushell ...$spans | from json
}

$env.config.completions.external.completer = cararpace_completer;

$env.hooks.pre_prompt = [{ ||
  if (which direnv | is-empty) {
    return
  }
  direnv export json | from json | default {} | load-env
}];
