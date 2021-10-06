#!/usr/bin/env bash

mkdir actions-runner && cd actions-runner
case $(uname -m) in aarch64) ARCH="arm64" ;; amd64|x86_64) ARCH="x64" ;; esac && export RUNNER_ARCH=${ARCH}
useradd -m runner
gpasswd --add runner wheel || true
gpasswd --add runner admin || true
gpasswd --add runner root || true
cd /home/runner
su runner -c "curl -O -L https://github.com/actions/runner/releases/download/v2.280.3/actions-runner-linux-${RUNNER_ARCH}-2.280.3.tar.gz"
su runner -c "tar xzf ./actions-runner-linux-\${RUNNER_ARCH}-2.280.3.tar.gz"
su runner -c "env DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1 ./config.sh --unattended --url @URL@ --token @RUNNER_TOKEN@ --labels @LABEL@ --ephemeral"
su runner -c "env DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1 ./run.sh"
