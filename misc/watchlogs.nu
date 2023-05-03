#!/usr/bin/env nu

loop {
  let f = ../.outputs/logs/latest/err
  tail -f $f
}
