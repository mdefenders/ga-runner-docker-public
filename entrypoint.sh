#!/bin/env bash

REG_TOKEN=$(curl -sLX POST -H "Authorization: Bearer ${GITHUB_TOKEN}" -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" https://api.github.com/orgs/"${GITHUB_ORGANIZATION}"/actions/runners/registration-token | jq .token --raw-output)

if [ ! -e /home/docker/actions-runner/bin ]
then
  echo "Downloading the runner"
  curl -o actions-runner-linux-x64-"${RUNNER_VERSION}".tar.gz -L \
  https://github.com/actions/runner/releases/download/v"${RUNNER_VERSION}"/actions-runner-linux-x64-"${RUNNER_VERSION}".tar.gz
  tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz
  rm ./actions-runner-linux-x64-"${RUNNER_VERSION}".tar.gz
else
    echo "actions-runner/bin was found. Skipping the download step."
fi

if [ ! -e /home/docker/actions-runner/.credentials ]
then
  echo "Getting tokens and configs"
  /home/docker/actions-runner/config.sh --disableupdate --replace --unattended --name $(hostname -f)-"${RUNNER_NAME}" --labels $(hostname -f),"${RUNNER_LABELS}" --url https://github.com/"${GITHUB_ORGANIZATION}" --token "${REG_TOKEN}"
else
    echo ".credentials was found. Skipping init step."
fi

cleanup() {
  echo "Removing runner..."
  RM_TOKEN=$(curl -sLX POST -H "Authorization: Bearer ${GITHUB_TOKEN}" -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" https://api.github.com/orgs/"${GITHUB_ORGANIZATION}"/actions/runners/remove-token | jq .token --raw-output)
  /home/docker/actions-runner/config.sh remove --token ${RM_TOKEN}
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

/home/docker/actions-runner/run.sh & wait $!