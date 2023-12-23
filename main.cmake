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
    foreach(dir ${ARGN})
        file(GLOB_RECURSE files "${dir}/*.cmake")

        foreach (cmake_file ${files})
            include("${cmake_file}")
        endforeach ()
    endforeach()
endfunction()

# --------------------------------------------------------------------------------------------------------------
# 本 cmake-kit 的入点，加载所有的工具函数。
# The entrypoint of this cmake kit, which loads all tool functions and macros.
# --------------------------------------------------------------------------------------------------------------

aoe_include_cmake_files(
    ${CMAKE_CURRENT_LIST_DIR}/utils
    ${CMAKE_CURRENT_LIST_DIR}/collection
    ${CMAKE_CURRENT_LIST_DIR}/layout
    ${CMAKE_CURRENT_LIST_DIR}/param
    ${CMAKE_CURRENT_LIST_DIR}/property
    ${CMAKE_CURRENT_LIST_DIR}/ros
    ${CMAKE_CURRENT_LIST_DIR}/target
    ${CMAKE_CURRENT_LIST_DIR}/project
    ${CMAKE_CURRENT_LIST_DIR}/init
    ${CMAKE_CURRENT_LIST_DIR}/final
)

__aoe_common_property(TEMPLATE_DIRECTORY_PATH SET "${CMAKE_CURRENT_LIST_DIR}/template")
__aoe_common_property(SCRIPT_DIRECTORY_PATH   SET "${CMAKE_CURRENT_LIST_DIR}/script")
