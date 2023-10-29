# --------------------------------------------------------------------------------------------------------------
# 处理未知参数，经由 cmake_parse_arguments 函数处理后，若存在未适当展开的参数，则报错。
# Check if there are any unknown parameters reported by cmake_parse_arguments(),
# and if so, an error is raised.
# --------------------------------------------------------------------------------------------------------------
# aoe_disable_unknown_params(param_variable)
#
# param_variable: 传入 cmake_parse_arguments() 作为输出的变量名称。
#                 The output variable's name used by cmake_parse_arguments().
# --------------------------------------------------------------------------------------------------------------

macro(aoe_disable_unknown_params param_variable)
    if (NOT "${${param_variable}_UNPARSED_ARGUMENTS}" STREQUAL "")
        message(FATAL_ERROR "Unknown parameters: ${${param_variable}_UNPARSED_ARGUMENTS}")
    endif ()
endmacro()
