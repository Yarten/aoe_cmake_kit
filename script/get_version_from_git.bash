#!/bin/bash

# -------------------------------------------------------------
# The root directory of '.git'
git_root=$1

# -------------------------------------------------------------
# Some basic checks
type "git" >/dev/null 2>&1

if [[ $? -ne 0 || ! -f "$git_root/.git/config" ]]; then
    exit 1
fi

# -------------------------------------------------------------
# Get the main branch commit count, and use it as the version number
cd $git_root

git_hash_file=$(mktemp)

git rev-list main | sort > $git_hash_file

main_commit_count=$(wc -l $git_hash_file | awk '{print $1}')

if [[ $main_commit_count -gt 0 ]]; then
    current_commit_count=$(git rev-list HEAD | sort | join $git_hash_file - | wc -l | awk '{print $1}')

    major_version=$(expr ${main_commit_count} / 100)
    minor_version=$(expr ${main_commit_count} % 100)
    patch_version="$(($main_commit_count - $current_commit_count))"
else
    major_version=0
    minor_version=0
    patch_version=0
fi

version="$major_version.$minor_version.$patch_version"

# -------------------------------------------------------------
# Final output
error_code=$?

echo -n $version
rm $git_hash_file
exit $error_code
