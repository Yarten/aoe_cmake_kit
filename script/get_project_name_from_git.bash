#!/bin/bash

# 第一个参数：git 仓库所在根目录
git_root=$1

# 获取 url 中的仓库名称
name=$(cd $git_root && basename -s .git `git config --get remote.origin.url`)

# 检查是否获取成功，实则导出结果
if [ $? -eq 0 ]; then
    echo -n $name
    exit 0
else
    exit 1
fi
