only include one, 

* `core.nix` is the minimal user, editor, ssh+gpg config
* `interactive.nix` is what I'd expect out of a dev VM at least (includes `core.nix`)
* `gui.nix` is my daily driver laptop setup (sway, etc) (includes `interactive.nix`)