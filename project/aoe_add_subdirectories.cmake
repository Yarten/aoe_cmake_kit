# --------------------------------------------------------------------------------------------------------------
# 添加指定目录下的所有子目录（非递归），将跳过不包含 CMakeLists.txt 的目录。
# Adding all subdirectories under the specified directory (non-recursively),
# will skip directories that do not contain CMakeLists.txt.
# --------------------------------------------------------------------------------------------------------------
# aoe_add_subdirectories([<dir> ...])
# --------------------------------------------------------------------------------------------------------------

function(aoe_add_subdirectories)
    # 初始化全部目录变量为空
    unset(all_subdirs)

    # 遍历所有目录，取出所有子目录
    foreach(dir ${ARGN})
        # 取出指定根目录下所有文件和目录
        file(GLOB subdirs ${dir}/*)

        # 取出目录
        foreach(subdir ${subdirs})
            if (EXISTS ${subdir}/CMakeLists.txt)
                list(APPEND all_subdirs ${subdir})
            endif ()
        endforeach()
    endforeach()

    # 包含所有子目录
    foreach(subdir ${all_subdirs})
        add_subdirectory(${subdir})
    endforeach()
endfunction()
