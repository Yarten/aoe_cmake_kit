cmake_minimum_required(VERSION 3.16)

# --------------------------------------------------------------------------------------------------------------
# 加载给定多个目录下的所有 cmake 文件，以递归形式搜索
# Include all cmake files in every given directory recursively.
# --------------------------------------------------------------------------------------------------------------
# aoe_include_cmake_files(
#   [<directory> ...]
# )
# --------------------------------------------------------------------------------------------------------------

function(aoe_include_cmake_files)
    # 遍历所有目录，取出所有 cmake 文件
    set(all_files)

    foreach(dir ${ARGN})
        file(GLOB_RECURSE files ${dir}/*.cmake)
        list(APPEND all_files ${files})
    endforeach()

    # include 所有 cmake 文件
    foreach(cmake_file ${all_files})
        include(${cmake_file})
    endforeach()
endfunction()

# --------------------------------------------------------------------------------------------------------------
# 本 cmake-kit 的入点，加载所有的工具函数。
# The entrypoint of this cmake kit, which loads all tool functions and macros.
# --------------------------------------------------------------------------------------------------------------

# 加载所有的 cmake 文件
aoe_include_cmake_files(
    ${CMAKE_CURRENT_LIST_DIR}/param
    ${CMAKE_CURRENT_LIST_DIR}/utils
)
