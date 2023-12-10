#!/bin/bash

# -------------------------------------------------------------
# 第一个参数：git 仓库所在根目录
git_root=$1

# -------------------------------------------------------------
# 基本的有效性检查
type "git" >/dev/null 2>&1

if [[ $? -ne 0 || ! -d "$git_root/.git" ]]; then
    exit 1
fi

# -------------------------------------------------------------
# 获取当前提交的 hash 值，作为版本信息并输出
cd $git_root

hash_version="$(git rev-list HEAD -n 1 | cut -c 1-14)"

echo -n $hash_version
