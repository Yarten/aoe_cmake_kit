# --------------------------------------------------------------------------------------------------------------
# 导出一个指定目标，将根据该目标的类型（可执行的、库）来自动配置导出内容。
# Exporting a given target,
# will automatically configure the export contents based on the type of that target (executable, library).
# --------------------------------------------------------------------------------------------------------------
# aoe_install_target(target
#   [EXTRA_CMAKE_POST <cmake file> ...]
# )
#
# target: 被导出的目标。
#         The target to install.
# --------------------------------------------------------------------------------------------------------------
# EXTRA_CMAKE_POST: 将被一起安装，且在目标加载时最后执行的自定义 cmake 文件。
#                   The custom cmake files that will be installed together
#                   and executed last when the target is loaded.
# --------------------------------------------------------------------------------------------------------------

function(aoe_install_target target)
    cmake_parse_arguments(config "" "" "EXTRA_CMAKE_POST" ${ARGN})
    aoe_disable_unknown_params(config)

    # -------------------------------------------------------------
    # 获取当前工作空间定义的安装配置
    __aoe_load_current_install_layout(include lib bin cmake build)
    set(cmake "${cmake}/targets")

    # -------------------------------------------------------------
    # 安装常规目标文件
    install(
        TARGETS ${target} EXPORT ${target}Targets
        LIBRARY  DESTINATION "${lib}"
        ARCHIVE  DESTINATION "${lib}"
        RUNTIME  DESTINATION "${bin}"
        INCLUDES DESTINATION "${include}"
    )

    # -------------------------------------------------------------
    # 获取目标的类型
    get_target_property(target_type ${target} TYPE)

    # 或当前为可执行目标，则不再执行后续的步骤
    if (${target_type} STREQUAL "EXECUTABLE")
        return()
    endif ()

    # -------------------------------------------------------------
    # 追加已经安装的目标列表，将在打包工程时使用
    __aoe_project_property(INSTALLED_LIBRARIES APPEND ${target})

    # -------------------------------------------------------------
    # 获取该目标的一些信息，用于设置安装
    __aoe_target_property(${target} EGO_INCLUDES             GET target_ego_includes)
    __aoe_target_property(${target} DEPENDENCIES             GET target_dependencies)
    __aoe_target_property(${target} THIRD_PARTIES            GET target_third_parties)
    __aoe_target_property(${target} THIRD_PARTIES_COMPONENTS GET target_third_parties_components)

    # -------------------------------------------------------------
    # 安装本目标自己的头文件目录
    foreach (ego_include ${target_ego_includes})
        if (IS_DIRECTORY "${ego_include}")
            install(
                DIRECTORY   "${ego_include}"
                DESTINATION "${include}"
                COMPONENT   Devel
                PATTERN     ".svn" EXCLUDE
            )
        endif ()
    endforeach ()

    # -------------------------------------------------------------
    # 导出目标文件
    set(target_file       "${target}Targets.cmake")
    set(target_file_path  "${build}/${target_file}")
    set(project_namespace "${PROJECT_NAME}::")

    if ("${CMAKE_VERSION}" VERSION_LESS "3.0.0")
        if (NOT EXISTS ${target_file_path})
            export(TARGETS ${target} APPEND FILE "${target_file_path}" NAMESPACE "${project_namespace}")
        else()
            export(EXPORT ${target}Targets FILE "${target_file_path}" NAMESPACE "${project_namespace}")
        endif ()
    endif ()

    install(
        EXPORT      "${target}Targets"
        FILE        "${target_file}"
        NAMESPACE   "${project_namespace}"
        DESTINATION "${cmake}"
    )

    # -------------------------------------------------------------
    # 导出自定义的后处理 cmake 文件
    aoe_install_cmake(TARGET ${target} POST ${config_EXTRA_CMAKE_POST})

    # -------------------------------------------------------------
    # 生成版本文件
    if (DEFINED PROJECT_VERSION)
        set(version_file_path "${build}/${target}ConfigVersion.cmake")

        include(CMakePackageConfigHelpers)
        write_basic_package_version_file("${version_file_path}"
            VERSION       ${PROJECT_VERSION}
            COMPATIBILITY AnyNewerVersion
        )
    else ()
        unset(version_file_path)
    endif ()

    # -------------------------------------------------------------
    # 生成配置文件（定义对工程内其他目标的依赖，以及对第三方库的依赖。）
    set(config_file_path "${build}/${target}Config.cmake")

    __aoe_common_property(TEMPLATE_DIRECTORY_PATH GET template_directory_path)

    configure_file(
        "${template_directory_path}/install_target.cmake.in"
        "${config_file_path}"
        @ONLY
    )

    # -------------------------------------------------------------
    # 安装版本文件与配置文件
    install(
        FILES       ${version_file_path} ${config_file_path}
        DESTINATION ${cmake}
        COMPONENT   Devel
    )

    # 结束安装过程。
endfunction()
