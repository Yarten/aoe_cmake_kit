# --------------------------------------------------------------------------------------------------------------
# 检查是否在给定主参数的情况下，是否同时给定了相关的副参数。
# Check if the main parameter is given together with the relevant parameter.
# --------------------------------------------------------------------------------------------------------------
# aoe_expect_related_param(param_variable main_param related_param)
#
# param_variable: 传入 cmake_parse_arguments() 作为输出的变量名称。
#                 The output variable's name used by cmake_parse_arguments().
#
# main_param: 需要检查的主参数
#             The main parameter to be checked.
#
# related_param: 需要与主参数同时使用的相关参数
#                The related parameter that need to be used together with the main parameter.
# --------------------------------------------------------------------------------------------------------------

function(aoe_expect_related_param param_variable main_param related_param)
    if (
        (DEFINED ${param_variable}_${main_param}  AND NOT "${${param_variable}_${main_param}}"  STREQUAL "FALSE")
        AND NOT
        (DEFINED ${param_variable}_${related_param} AND NOT "${${param_variable}_${related_param}}" STREQUAL "FALSE")
    )
        message(FATAL_ERROR
            "Parameter ${main_param} is given but its related parameter ${related_param} is not given !")
    endif ()
endfunction()
