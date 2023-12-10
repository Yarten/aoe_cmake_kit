#!/bin/bash

# -------------------------------------------------------------
# 第一个参数：git 仓库所在根目录
git_root=$1

# -------------------------------------------------------------
# 基本的有效性检查
type "git" >/dev/null 2>&1

if [[ $? -ne 0 || ! -f "$git_root/.git/config" ]]; then
    exit 1
fi

# -------------------------------------------------------------
# 进入 git 目录所在根目录，调用相关命令，获取主分支提交次数，
# 并利用它来充当版本号
cd $git_root

git_hash_file=$(mktemp)

git rev-list master | sort > $git_hash_file

master_commit_count=$(wc -l $git_hash_file | awk '{print $1}')

if [[ $master_commit_count -gt 0 ]]; then
    current_commit_count=$(git rev-list HEAD | sort | join $git_hash_file - | wc -l | awk '{print $1}')

    major_version=$(expr ${master_commit_count} / 100)
    minor_version=$(expr ${master_commit_count} % 100)
    patch_version="$(($master_commit_count - $current_commit_count))"
else
    major_version=0
    minor_version=0
    patch_version=0
fi

version="$major_version.$minor_version.$patch_version"

# -------------------------------------------------------------
# 最终输出

# 以上全部过程的处理结果
error_code=$?

echo -n $version
rm $git_hash_file
exit $error_code
