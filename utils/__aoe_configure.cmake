# --------------------------------------------------------------------------------------------------------------
# 将给定的变量表达式，基于本函数调用处的上下文，展开为最终的值。
# Expands a given variable expression to its final value based on the context at which this function is called.
# --------------------------------------------------------------------------------------------------------------
# __aoe_configure(result expr)
#
# result: 接收输出的变量。
#         The output variable.
#
# expr: 变量表达式，使用 @xx@ 来表示一个需要被展开的上下文变量。
#       Variable expression, use @xx@ to indicate a context variable that needs to be expanded.
# --------------------------------------------------------------------------------------------------------------

# In order to avoid that the names of the parameters of this function, and the names of the temporary variables,
# are identical to the context variables at the call, we have added some prefixes.
function(__aoe_configure __aoe_configure_result __aoe_configure_expr)
    # Temporary file paths
    set(__aoe_configure_temp_out_file "${CMAKE_BINARY_DIR}/.aoe/${PROJECT_NAME}/__aoe_configure.cmake")
    set(__aoe_configure_temp_in_file  "${__aoe_configure_temp_out_file}.in")

    # Write variable expressions to the input file
    file(WRITE "${__aoe_configure_temp_in_file}" ${__aoe_configure_expr})

    # Replace the contents of the input file according to the context variables and output it to the output file
    configure_file(
        "${__aoe_configure_temp_in_file}"
        "${__aoe_configure_temp_out_file}"
        @ONLY
    )

    # Read the contents of the output file into the result variable.
    file(READ "${__aoe_configure_temp_out_file}" __aoe_configure_value)
    string(STRIP ${__aoe_configure_value} __aoe_configure_value)
    aoe_output(${__aoe_configure_result} ${__aoe_configure_value})

    # Remove the temporary files
    file(REMOVE "${__aoe_configure_temp_in_file}" "${__aoe_configure_temp_out_file}")
endfunction()
