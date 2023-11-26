# --------------------------------------------------------------------------------------------------------------
# 检查是否存在互相冲突的参数，若有则产生错误。
# Check if there are conflicting parameters, and if so, an error is raised.
# --------------------------------------------------------------------------------------------------------------
# aoe_disable_conflicting_params(param_variable ...)
#
# param_variable: 传入 cmake_parse_arguments() 作为输出的变量名称。
#                 The output variable's name used by cmake_parse_arguments().
#
# ...: 需要检查的参数。
#      Parameters to be checked.
# --------------------------------------------------------------------------------------------------------------

function(aoe_disable_conflicting_params param_variable)
    if ("${ARGN}" STREQUAL "")
        message(FATAL_ERROR "no parameter is given for checking !")
    endif ()

    set(param_count "0")

    foreach(param ${ARGN})
        if (DEFINED ${param_variable}_${param} AND NOT "${${param_variable}_${param}}" STREQUAL "FALSE")
            math(EXPR param_count "${param_count} + 1")
        endif ()
    endforeach()

    if (${param_count} GREATER 1)
        message(FATAL_ERROR "Parameters ${ARGN} are conflicting with each other !")
    endif ()
endfunction(aoe_disable_conflicting_params)
