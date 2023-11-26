# --------------------------------------------------------------------------------------------------------------
# 在指定的目录下，递归寻找所有的 c++ 源代码，并添加到输出变量中。
# Recursively finds all c++ source code in the specified directories and adds it to the output variable.
# --------------------------------------------------------------------------------------------------------------
# aoe_source_directories(result ...)
#
# result: 输出变量。
#         The output variable.
#
# ...: 源码目录。
#      Source directories.
# --------------------------------------------------------------------------------------------------------------

function(aoe_source_directories result)
    foreach(dir ${ARGN})
        file(GLOB_RECURSE files ${dir}/*.cpp ${dir}/*.cc ${dir}/*.c)
        list(APPEND ${result} ${files})
    endforeach()

    aoe_output(${result})
endfunction()
