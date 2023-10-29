# --------------------------------------------------------------------------------------------------------------
# 将变量导出到调用域之外。
# Output the variable to its parent scope.
# --------------------------------------------------------------------------------------------------------------
# aoe_output(variable [...])
#
# variable: 需要导出的变量。
#           The variable to be output.
#
# ...: 若给定值，则先将这些值设置给指定变量，再导出该变量。
#      Optional values that are set to the variable.
# --------------------------------------------------------------------------------------------------------------

macro(aoe_output variable)
    if (NOT "${ARGN}" STREQUAL "")
        set(${variable} ${ARGN})
    endif ()

    set(${variable} ${${variable}} PARENT_SCOPE)
endmacro()
