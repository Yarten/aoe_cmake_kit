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

# 为了本函数的参数的名称、临时变量的名称，与调用处的上下文变量雷同，因此我们加了一些前缀。
function(__aoe_configure __aoe_configure_result __aoe_configure_expr)
    # 临时的文件路径
    set(__aoe_configure_temp_out_file "${CMAKE_BINARY_DIR}/.aoe/__aoe_configure.cmake")
    set(__aoe_configure_temp_in_file  "${__aoe_configure_temp_in_file}.in")

    # 将变量表达式写入到输入文件中
    file(WRITE "${__aoe_configure_temp_in_file}" ${__aoe_configure_expr})

    # 根据上下文变量，替换输入文件中的内容，并输出到输出文件中
    configure_file(
        "${__aoe_configure_temp_in_file}"
        "${__aoe_configure_temp_out_file}"
        @ONLY
    )

    # 将输出文件的内容，读取到结果变量中
    file(READ "${__aoe_configure_temp_out_file}" __aoe_configure_value)
    aoe_output(${__aoe_configure_result} ${__aoe_configure_value})

    # 删除临时文件
    file(REMOVE "${__aoe_configure_temp_in_file}" "${__aoe_configure_temp_out_file}")
endfunction()
