#!/bin/bash

# -------------------------------------------------------------
# The root directory of '.git'
git_root=$1

# -------------------------------------------------------------
# Some basic checks
type "git" >/dev/null 2>&1

if [[ $? -ne 0 || ! -d "$git_root/.git" ]]; then
    exit 1
fi

# -------------------------------------------------------------
# Get the hash value of the current commit and output it as version name
cd $git_root

hash_version="$(git rev-list HEAD -n 1 | cut -c 1-14)"

echo -n $hash_version
