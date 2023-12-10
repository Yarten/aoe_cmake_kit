# --------------------------------------------------------------------------------------------------------------
# 封装 cmake_parse_arguments()，以支持可空的单值参数与多值参数。
# Wraps cmake_parse_arguments() to support nullable single-valued and multi-valued arguments.
# --------------------------------------------------------------------------------------------------------------

macro(__aeo_cmake_parse_nullable_arguments
    param_variable optional_parameters single_value_parameters multi_values_parameters)

    # 解析参数
    cmake_parse_arguments(
        ${param_variable}
        "${optional_parameters}"
        "${single_value_parameters}"
        "${multi_values_parameters}"
        ${ARGN}
    )

    # 找出空值的参数
    unset(__aeo_cmake_parse_nullable_arguments_null_single_value_parameters)
    unset(__aeo_cmake_parse_nullable_arguments_null_multi_values_parameters)

    foreach (i ${single_value_parameters})
        if (NOT DEFINED ${param_variable}_${i})
            list(APPEND __aeo_cmake_parse_nullable_arguments_null_single_value_parameters ${i})
        endif ()
    endforeach ()

    foreach (i ${multi_values_parameters})
        if (NOT DEFINED ${param_variable}_${i})
            list(APPEND __aeo_cmake_parse_nullable_arguments_null_multi_values_parameters ${i})
        endif ()
    endforeach ()

    # 再次尝试解析这些可能空的值
    cmake_parse_arguments(
        __aeo_cmake_parse_nullable_arguments_config
        "${__aeo_cmake_parse_nullable_arguments_null_single_value_parameters};${__aeo_cmake_parse_nullable_arguments_null_multi_values_parameters}"
        ""
        ""
        ${ARGN}
    )

    # 检查这些空值参数是否存在
    foreach (i ${__aeo_cmake_parse_nullable_arguments_null_single_value_parameters})
        if (${__aeo_cmake_parse_nullable_arguments_config_${i}})
            set(${param_variable}_${i})
        endif ()
    endforeach ()

    foreach (i ${__aeo_cmake_parse_nullable_arguments_null_multi_values_parameters})
        if (${__aeo_cmake_parse_nullable_arguments_config_${i}})
            set(${param_variable}_${i} "")
        endif ()
    endforeach ()
endmacro()
