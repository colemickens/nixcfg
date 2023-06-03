#!/usr/bin/env bash

set -x

# TODO: remove this when output redir in nushell can handle this

"${@}" >>${LOG_OUT} 2>>${LOG_ERR}
