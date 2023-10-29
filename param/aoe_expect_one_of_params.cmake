# --------------------------------------------------------------------------------------------------------------
# 检查是否设置了给定参数的其中一个（有且仅有一个）
# Check if one of the given parameters is set.
# --------------------------------------------------------------------------------------------------------------
# aoe_expect_one_of_params(param_variable ...)
#
# param_variable: 传入 cmake_parse_arguments() 作为输出的变量名称。
#                 The output variable's name used by cmake_parse_arguments().
#
# ...: 需要检查的参数。
#      Parameters to be checked.
# --------------------------------------------------------------------------------------------------------------

function(aoe_expect_one_of_params param_variable)
    if ("${ARGN}" STREQUAL "")
        message(FATAL_ERROR "no parameter is given for checking !")
    endif ()

    set(param_count "0")

    foreach(param ${ARGN})
        if (DEFINED ${param_variable}_${param} AND NOT "${${param_variable}_${param}}" STREQUAL "FALSE")
            math(EXPR param_count "${param_count} + 1")
        endif ()
    endforeach()

    if (NOT ${param_count} EQUAL 1)
        message(FATAL_ERROR "Exactly one parameter of ${ARGN} should be given !")
    endif ()
endfunction()
