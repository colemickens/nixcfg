- bootspec
- systemd stage-1
- no perl
- no python
- Azure / Oracle / AWS Support
- Build Farm
- Esoteric Platforms


Tech Choices
- prefer rust where possible and feasible
- otherwise, choose the best option(s)



- bootloader = systemd (reason: not a lot of better choices, `bootctl` for the `-ctl` ness)
- ttys = kmscon (reason: no better alternative) (future: maybe `Smithay-rs` and/or `drm-rs` will lead to `kmscon-rs`))
- deskenv = anodium (alts: Arcan+Durden, so fucking cool I can look past non-Rust, though I'd probably never get to hack on my desktop then :( )
- shell = nushell (alts: `ion`)
- shprompt = starship-rs
  -
  -
