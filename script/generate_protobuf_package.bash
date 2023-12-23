#!/bin/bash

# The name of the protobuf target
name=$1

# The root directory where the protobuf C++ files is generated
root=$2

# Source file directories used by protoc
proto_paths=$3

# The protobuf files used by protoc
proto_files=$4

# Prepare a temporary generation directory, if the compiled result is identical to the existing files,
# the existing C++ package will not be updated.
tmp_root="$root.tmp"

rm    -rf "$tmp_root"
mkdir -p  "$tmp_root"
cd "$tmp_root" || exit 1

mkdir -p include
mkdir -p src/"$name"

# Execute protoc, all generated files are now in the 'include' directory
protoc $proto_paths --cpp_out=./include $proto_files

if [ $? -ne 0 ]; then
    >&2 echo "target: $name"
    exit 1
fi

# Move all C++ source files to 'src' directory while keeping their directories structures
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

# Compare the generated result with the original to see if it is the same, and if it is different, then update it.
# Delete CMakeLists.txt before comparison
rm "$root/CMakeLists.txt"

diff -r "$root" "$tmp_root" &> /dev/null

if [ $? -ne 0 ]; then
    rm -rf "$root"
    mv "$tmp_root" "$root"
fi
