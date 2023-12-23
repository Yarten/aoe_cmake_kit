# --------------------------------------------------------------------------------------------------------------
# 添加指定目录下的所有子目录（非递归），将跳过不包含 CMakeLists.txt 的目录。
# Adding all subdirectories under the specified directory (non-recursively),
# will skip directories that do not contain CMakeLists.txt.
# --------------------------------------------------------------------------------------------------------------
# aoe_add_subdirectories([<dir> ...])
# --------------------------------------------------------------------------------------------------------------

function(aoe_add_subdirectories)
    foreach(dir ${ARGN})
        file(GLOB subdirs ${dir}/*)

        foreach(subdir ${subdirs})
            if (EXISTS "${subdir}/CMakeLists.txt")
                add_subdirectory("${subdir}")
            endif ()
        endforeach()
    endforeach()
endfunction()
