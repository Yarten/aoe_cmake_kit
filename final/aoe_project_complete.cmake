# --------------------------------------------------------------------------------------------------------------
# 配合工具箱实现 aoe 工程的收尾工作，并设置一些导出选项。
# Finalize the aoe project and set some export options.
# --------------------------------------------------------------------------------------------------------------
# aoe_project_complete(
#   [DEFAULT_EXPORTS_ALL]
#   [ALWAYS_EXPORTS        [<component>           ...] ]
#   [DEFAULT_EXPORTS       [<component>           ...] ]
#   [EXPORTED_MODULE_PATHS [<relative cmake path> ...] ]
# )
# --------------------------------------------------------------------------------------------------------------
# DEFAULT_EXPORTS_ALL: 本工程被其他工程导入时，若用户没有指定组件，则默认导入全部组件。
#                      When this project is imported by another project,
#                      all components are imported by default if the user does not specify them.
#
# ALWAYS_EXPORTS: 总是导出的组件。
#                 Components that are always exported.
#
# DEFAULT_EXPORTS: 默认导出的组件。
#                  Components that are exported by default.
#
# EXPORTED_MODULE_PATHS: 工程内的第三方库的 cmake 配置文件目录，应相对于安装目录，将一同记录在本工程的配置文件中。
#                        The cmake configuration file directories for third-party libraries within the project,
#                        relative to the installation directory,
#                        should be recorded together in the configuration file for this project.
# --------------------------------------------------------------------------------------------------------------

function(aoe_project_complete)
    # Parse parameters
    cmake_parse_arguments(config
        "DEFAULT_EXPORTS_ALL"
        ""
        "ALWAYS_EXPORTS;DEFAULT_EXPORTS;EXPORTED_MODULE_PATHS"
        ${ARGN}
    )
    aoe_disable_unknown_params(config)

    # Build all protobuf targets
    __aoe_build_all_protobuf_targets()

    # Generate install() for the project
    unset(is_default_exports_all)

    if (${config_DEFAULT_EXPORTS_ALL})
        set(is_default_exports_all "DEFAULT_ALL")
    endif()

    __aoe_install_project(
        ${is_default_exports_all}
        BASIC        ${config_ALWAYS_EXPORTS}
        DEFAULT      ${config_DEFAULT_EXPORTS}
        MODULE_PATHS ${config_EXPORTED_MODULE_PATHS}
    )

    # Do some closing work of ros
    __aoe_ros_package_complete()

    # Summarize all information about this aoe project
    # and write to the file defined by the specified environment variable (if it is set)
    __aoe_summarize_project()
endfunction()
