# --------------------------------------------------------------------------------------------------------------
# 运行外部指令，可将结果写到指定变量；若指令报错，则本函数也报错，终止 cmake 过程。
# Execute one external process and get its output. If error occurs, this cmake process will be broken.
# --------------------------------------------------------------------------------------------------------------
# aoe_execute_process(
#   command ...
#   RESULT <result>
# )
#
# command: 进程的执行指令。
#          The process command line.
#
# ...: 传入进程的参数
#      Arguments passed to the process.
# --------------------------------------------------------------------------------------------------------------
# RESULT: 输出结果指定变量。
#         Declare a variable to take standard output of the process.
# --------------------------------------------------------------------------------------------------------------

function(aoe_execute_process command)
    cmake_parse_arguments(config "" "RESULT" "" ${ARGN})

    execute_process(
        COMMAND         ${command} ${config_UNPARSED_ARGUMENTS}
        OUTPUT_VARIABLE result
        ERROR_VARIABLE  error
        RESULT_VARIABLE code
    )

    if (NOT ${code} EQUAL 0)
        message(FATAL_ERROR "Error occurs when execute ${command}: ${error}")
    endif ()

    if (DEFINED config_RESULT)
        aoe_output(${config_RESULT} ${result})
    endif ()
endfunction()
