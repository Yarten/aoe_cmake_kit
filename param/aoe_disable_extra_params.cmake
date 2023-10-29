# --------------------------------------------------------------------------------------------------------------
# 检查是否有变长多余的参数，若有则产生错误。
# Check if there are any extra parameters, and if so, an error is raised.
# --------------------------------------------------------------------------------------------------------------
# aoe_disable_extra_params()
# --------------------------------------------------------------------------------------------------------------

macro(aoe_disable_extra_params)
    if (NOT "${ARGN}" STREQUAL "")
        message(FATAL_ERROR "Unknown parameters: ${ARGN}")
    endif ()
endmacro()
