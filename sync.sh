#!/usr/bin/env bash

set -e

printf "\033[0;32mSyncing updates from GitHub...\033[0m\n"

git pull origin master

cd public && git pull origin master

echo "done!"