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
    # Get the current used install layout
    __aoe_load_current_install_layout(include lib bin cmake build)
    set(cmake "${cmake}/targets")

    # -------------------------------------------------------------
    # Configure the installation directories
    install(
        TARGETS ${target} EXPORT ${target}Targets
        LIBRARY  DESTINATION "${lib}"
        ARCHIVE  DESTINATION "${lib}"
        RUNTIME  DESTINATION "${bin}"
        INCLUDES DESTINATION "${include}"
    )

    # -------------------------------------------------------------
    # If this target is executable, we stop here.
    get_target_property(target_type ${target} TYPE)

    if ("${target_type}" STREQUAL "EXECUTABLE")
        return()
    endif ()

    # -------------------------------------------------------------
    # Add this target to the list of installed targets that will be used when install the project
    __aoe_project_property(INSTALLED_LIBRARIES APPEND ${target})

    # -------------------------------------------------------------
    # Some information about this target for setting up the installation
    __aoe_target_property(${target} EGO_INCLUDES             GET target_ego_includes)
    __aoe_target_property(${target} DEPENDENCIES             GET target_dependencies)
    __aoe_target_property(${target} THIRD_PARTIES            GET target_third_parties)
    __aoe_target_property(${target} THIRD_PARTIES_COMPONENTS GET target_third_parties_components)

    # -------------------------------------------------------------
    # Install this target's own header file directories
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
    # Export the target
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
    # Install the custom post-processing cmake files
    aoe_install_cmake(TARGET ${target} POST ${config_EXTRA_CMAKE_POST})

    # -------------------------------------------------------------
    # Generate the version configuration file
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
    # Generate configuration file
     # (to define dependencies on other targets within the project, as well as dependencies on third-party libraries).
    set(config_file_path "${build}/${target}Config.cmake")

    __aoe_common_property(TEMPLATE_DIRECTORY_PATH GET template_directory_path)

    configure_file(
        "${template_directory_path}/install_target.cmake.in"
        "${config_file_path}"
        @ONLY
    )

    # -------------------------------------------------------------
    # Install the configuration files
    install(
        FILES       ${version_file_path} ${config_file_path}
        DESTINATION ${cmake}
        COMPONENT   Devel
    )

    # END
endfunction()
