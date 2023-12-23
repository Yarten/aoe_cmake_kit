# --------------------------------------------------------------------------------------------------------------
# 解析编译目标的参数（用于 aoe_add_<xxx>() 函数的开头解析参数之用）。
# Parse arguments for aoe target (for parsing arguments at the beginning of the aoe_add_<xxx>() function).
# --------------------------------------------------------------------------------------------------------------
# __aoe_parse_target_arguments(
#   modes
#   config_variable
#   optional_parameters
#   single_value_parameters
#   multi_values_parameters
# )
#
# modes: 给本宏函数的参数列表。
#        Parameters for this macro.
#  - LIB: 表明正在为库目标处理参数。
#         Indicates that parameters are being processed for the library target.
#
#  - MOD: 表明正在为模块目标处理参数（非测试目标）。
#         Indicates that parameters are being processed for the module targets (not test targets).
#
# config_variable: 参数变量前缀。
#                  Parameter variables' prefix.
# --------------------------------------------------------------------------------------------------------------

macro(__aoe_parse_target_arguments
    modes config_variable optional_parameters single_value_parameters multi_values_parameters)
    unset(__aoe_parse_target_arguments_optional_parameters)
    unset(__aoe_parse_target_arguments_single_value_parameters)
    unset(__aoe_parse_target_arguments_multi_values_parameters)

    # Add parameters that are only available given some of the target options
    cmake_parse_arguments(__aoe_parse_target_arguments_config "LIB;MOD" "" "" ${modes})

    if (${__aoe_parse_target_arguments_config_LIB})
        list(APPEND __aoe_parse_target_arguments_optional_parameters
            SHARED
            STATIC
            PRIVATE_DEFAULT_INCLUDES
        )
        list(APPEND __aoe_parse_target_arguments_multi_values_parameters
            PRIVATE_DEPEND
            PRIVATE_IMPORT
            PRIVATE_INCLUDES
            PRIVATE_LIBRARIES
        )
    else ()
        set(${config_variable}_PRIVATE_DEFAULT_INCLUDES ON)
        list(APPEND __aoe_parse_target_arguments_optional_parameters
            AUX
        )
        list(APPEND __aoe_parse_target_arguments_multi_values_parameters
            FORCE_DEPEND
        )
    endif ()

    if (${__aoe_parse_target_arguments_config_MOD})
        list(APPEND __aoe_parse_target_arguments_optional_parameters
            NO_INSTALL
            NO_DEFAULT_SOURCES
        )
        list(APPEND __aoe_parse_target_arguments_single_value_parameters
            ALIAS
        )
    else ()
        set(${config_variable}_NO_INSTALL         ON)
        set(${config_variable}_NO_DEFAULT_SOURCES ON)
    endif ()

    # Add common parameters that all targets have, together with the additional parameters passed in
    list(APPEND __aoe_parse_target_arguments_optional_parameters
        ${optional_parameters}
        NO_DEFAULT_INCLUDES
    )

    list(APPEND __aoe_parse_target_arguments_single_value_parameters
        ${single_value_parameters}
    )

    list(APPEND __aoe_parse_target_arguments_multi_values_parameters
        ${multi_values_parameters}
        DEPEND
        BUILD_DEPEND
        IMPORT
        COMPONENTS
        SOURCES
        SOURCE_DIRECTORIES
        INCLUDES
        LIBARIES
    )

    # Parse the parameters passed to the function that creates the target
    list(REMOVE_DUPLICATES __aoe_parse_target_arguments_optional_parameters)
    list(REMOVE_DUPLICATES __aoe_parse_target_arguments_single_value_parameters)
    list(REMOVE_DUPLICATES __aoe_parse_target_arguments_multi_values_parameters)

    cmake_parse_arguments(
        ${config_variable}
        "${__aoe_parse_target_arguments_optional_parameters}"
        "${__aoe_parse_target_arguments_single_value_parameters}"
        "${__aoe_parse_target_arguments_multi_values_parameters}"
        ${ARGN}
    )
    aoe_disable_unknown_params(${config_variable})
    aoe_disable_conflicting_params(${config_variable} SHARED STATIC)
    aoe_disable_conflicting_params(${config_variable} AUX SOURCES)
    aoe_disable_conflicting_params(${config_variable} AUX SOURCE_DIRECTORIES)
endmacro()
