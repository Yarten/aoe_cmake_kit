#!/bin/bash

# The root directory of '.git'
git_root=$1

# Get the name of the repository in the url
name=$(cd $git_root && basename -s .git `git config --get remote.origin.url`)

if [ $? -eq 0 ]; then
    echo -n $name
    exit 0
else
    exit 1
fi
