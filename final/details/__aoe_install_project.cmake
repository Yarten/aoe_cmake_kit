# --------------------------------------------------------------------------------------------------------------
# 导出本工程的 install 目标以及 uninstall 目标。该函数需要在所有工程内目标都定义之后使用。
# Exports the install target and the uninstall target of the project.
# This function needs to be used after all the targets in the project have been defined.
# TODO: uninstall
# --------------------------------------------------------------------------------------------------------------
# __aoe_install_project(
#   [BASIC   <component> ...]
#   [DEFAULT <component> ...]
#   [DEFAULT_ALL]
#   [MODULE_PATHS <relative cmake path> ...]
# )
# --------------------------------------------------------------------------------------------------------------
# BASIC: 总是会引入的组件。
#        Components that will always be imported.
#
# DEFAULT: 若用户没有指定引入的组件时，默认会引入的组件。
#          The components that will be imported by default
#          if the user does not specify the components to be introduced.
#
# DEFAULT_ALL: 设置若用户没有指定引入的组件时，默认引入全部组件。
#              Sets all components to be imported by default
#              if the user does not specify which components to import.
#
# MODULE_PATHS: 工程内的第三方库的 cmake 配置文件目录，应相对于安装目录，将一同记录在本工程的配置文件中。
#               The cmake configuration file directories for third-party libraries within the project,
#               relative to the installation directory,
#               will be recorded together in the configuration file for this project.
# --------------------------------------------------------------------------------------------------------------

function(__aoe_install_project)
    # -------------------------------------------------------------
    # 获取当前工作空间定义的安装配置
    __aoe_load_current_install_layout(include lib bin cmake build)

    # -------------------------------------------------------------
    # 解析输入的参数
    cmake_parse_arguments(config "DEFAULT_ALL;EXPORTED" "" "BASIC;DEFAULT;MODULE_PATHS" ${ARGN})
    aoe_disable_unknown_params(config)
    aoe_disable_conflicting_params(config DEFAULT_ALL DEFAULT)

    # -------------------------------------------------------------
    # 设置工程默认导入的组件，以及必须导入的组件
    set(basic_libraries ${config_BASIC})

    if (${config_DEFAULT_ALL})
        __aoe_project_property(INSTALLED_LIBRARIES GET default_libraries)
    else()
        set(default_libraries ${config_DEFAULT})
    endif()

    __aoe_project_property(BASIC_EXPORTED_COMPONENTS   SET ${basic_libraries})
    __aoe_project_property(DEFAULT_EXPORTED_COMPONENTS SET ${default_libraries})

    # -------------------------------------------------------------
    # 处理一起安装的工程内第三方库的配置文件寻找目录
    # 默认传入的配置文件目录，是相对于安装根目录的；由于该目录的导入，放在了本工程的配置文件中，因此须从
    # 本工程的配置文件所在目录开始，向前寻找到安装根目录：
    file(RELATIVE_PATH relative_install_root "/${cmake}" "/")

    set(module_paths "${config_MODULE_PATHS}")

    # -------------------------------------------------------------
    # 生成配置文件（扫描本工程内的其他组件）
    set(config_file_path "${build}/${PROJECT_NAME}Config.cmake")

    __aoe_common_property(TEMPLATE_DIRECTORY_PATH GET template_directory_path)

    configure_file(
        "${template_directory_path}/install_project.cmake.in"
        "${config_file_path}"
        @ONLY
    )

    # -------------------------------------------------------------
    # 生成版本文件
    if (DEFINED PROJECT_VERSION)
        set(version_file_path "${build}/${PROJECT_NAME}ConfigVersion.cmake")

        include(CMakePackageConfigHelpers)
        write_basic_package_version_file(
            "${version_file_path}"
            VERSION       ${PROJECT_VERSION}
            COMPATIBILITY AnyNewerVersion
        )
    else ()
        unset(version_file_path)
    endif ()

    # -------------------------------------------------------------
    # 安装配置文件与版本文件
    install(
        FILES       ${config_file_path} ${version_file_path}
        DESTINATION ${cmake}
        COMPONENT   Devel
    )

    # 结束工程安装
endfunction()
