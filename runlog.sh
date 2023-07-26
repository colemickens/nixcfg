#!/usr/bin/env bash

# TODO: remove this when output redir in nushell can handle this

"${@}" >>${LOG_FILE} 2>&1
