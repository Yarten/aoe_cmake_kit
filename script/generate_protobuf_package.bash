#!/bin/bash

# 第一个参数：protobuf 工程包名称
name=$1

# 第二个参数：protobuf 工程包的生成根目录
root=$2

# 第三个参数：protoc 使用的源文件目录参数
proto_paths=$3

# 第四个参数：protoc 使用的源文件参数
proto_files=$4

# 准备临时生成目录，若生成的结果与已有的结果完全相同时，
# 将不会更新已有的工程包（即使删掉再生成，可能也会触发重编译）
tmp_root="$root.tmp"

rm    -rf "$tmp_root"
mkdir -p  "$tmp_root"
cd "$tmp_root" || exit 1

mkdir -p include
mkdir -p src/"$name"

# 执行 protoc ，将生成目暂时放在 include 目录下
protoc $proto_paths --cpp_out=./include $proto_files

if [ $? -ne 0 ]; then
    >&2 echo "target: $name"
    exit 1
fi

# 将生成在头文件同个目录下的所有源文件，拷贝到 src 目录下
function move_cxx(){
    local header_dir=$1
    local source_dir=$2

    mkdir -p "$source_dir"              2> /dev/null
    mv "$header_dir"/*.cc "$source_dir" 2> /dev/null

    for sub_path in `ls "$header_dir"`
    do
        if [ -d "$header_dir/$sub_path" ]
        then
            move_cxx "$header_dir/$sub_path" "$source_dir/$sub_path"
        fi
    done
}

move_cxx include src/"$name"

# 比较生成结果与原有的是否相同，若不同时，再进行更新，
# 比较前，先删掉在外部创建的 CMakeLists.txt
rm "$root/CMakeLists.txt"

diff -r "$root" "$tmp_root" &> /dev/null

if [ $? -ne 0 ]; then
    rm -rf "$root"
    mv "$tmp_root" "$root"
fi
