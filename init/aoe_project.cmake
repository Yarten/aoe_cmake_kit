# --------------------------------------------------------------------------------------------------------------
# Create an aoe project.
# --------------------------------------------------------------------------------------------------------------
# aoe_project(
#   < NAME <project name>
#   | NAME_FROM_GIT
#   >
#   < VERSION <project version>
#   | VERSION_FROM_GIT
#   >
#   [ VERSION_NAME <project version name>
#   | VERSION_NAME_FROM_GIT
#   ]
#   [GIT_ROOT <project git root>]
# )
# --------------------------------------------------------------------------------------------------------------
# NAME: Project name.
#
# NAME_FROM_GIT: 从 git 信息中提取工程名字。
#                Extract the project name from the git message.
#
# VERSION: Project version.
#
# VERSION_FROM_GIT: 从 git 信息中提取工程版本（别用）。
#                   Extract the project version from the git message (don't use it).
#
# VERSION_NAME: Project version name.
#
# VERSION_NAME_FROM_GIT: 从 git 信息中提取工程版本名称（哈希值）。
#                        Extract the project version name (hash) from the git message.
#
# GIT_ROOT: 设置代码工程的 git 目录。
#           Set the git directory for your code project.
# --------------------------------------------------------------------------------------------------------------

macro(aoe_project)
    # Parse parameters
    cmake_parse_arguments(
        __aoe_project_config
        "NAME_FROM_GIT;VERSION_FROM_GIT;VERSION_NAME_FROM_GIT"
        "NAME;VERSION;VERSION_NAME;GIT_ROOT"
        ""
        ${ARGN}
    )
    aoe_disable_unknown_params(__aoe_project_config)
    aoe_disable_conflicting_params(__aoe_project_config NAME         NAME_FROM_GIT)
    aoe_disable_conflicting_params(__aoe_project_config VERSION      VERSION_FROM_GIT)
    aoe_disable_conflicting_params(__aoe_project_config VERSION_NAME VERSION_NAME_FROM_GIT)
    aoe_expect_related_param(__aoe_project_config NAME_FROM_GIT         GIT_ROOT)
    aoe_expect_related_param(__aoe_project_config VERSION_FROM_GIT      GIT_ROOT)
    aoe_expect_related_param(__aoe_project_config VERSION_NAME_FROM_GIT GIT_ROOT)

    # Get project information (make sure the version name is handled last)
    if (${__aoe_project_config_NAME_FROM_GIT})
        aoe_manifest(GIT_ROOT ${__aoe_project_config_GIT_ROOT} NAME_FROM_GIT __aoe_project_config_NAME)
    endif ()

    if (${__aoe_project_config_VERSION_FROM_GIT})
        aoe_manifest(GIT_ROOT ${__aoe_project_config_GIT_ROOT} VERSION_FROM_GIT __aoe_project_config_VERSION)
    endif ()

    if (${__aoe_project_config_VERSION_NAME_FROM_GIT})
        aoe_manifest(GIT_ROOT ${__aoe_project_config_GIT_ROOT} VERSION_NAME_FROM_GIT)
    else ()
        aoe_manifest(VERSION_NAME ${__aoe_project_config_VERSION_NAME})
    endif ()

    # Create project
    if ("${__aoe_project_config_VERSION}" STREQUAL "")
        project(${__aoe_project_config_NAME})
    else ()
        project(${__aoe_project_config_NAME} VERSION ${__aoe_project_config_VERSION})
    endif ()

    # Initialize aoe cmake kit for the project
    aoe_project_init(DEFAULT_BUILD_OPTIONS)
endmacro()
