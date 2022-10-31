#!/usr/bin/env nu

let buildName = "test"
^nix-eval-jobs --flake '.#toplevels_pc' --gc-roots-dir $"./gcroots/($buildName)"
