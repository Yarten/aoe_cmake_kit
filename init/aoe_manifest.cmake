# --------------------------------------------------------------------------------------------------------------
# 在 aoe project 开始构建之前，配置一些 aoe cmake kit 选项。
# Configure some aoe cmake kit options before the aoe project starts building.
# --------------------------------------------------------------------------------------------------------------
# aoe_manifest(
#   [GIT_ROOT              <project's git root> ]
#   [NAME_FROM_GIT         <output name>        ]
#   [VERSION_FROM_GIT      <output version>     ]
#   [VERSION_NAME_FROM_GIT [output version name]]
#
#   [VERSION_NAME <version name>]
# )
# --------------------------------------------------------------------------------------------------------------
# GIT_ROOT: 设置代码工程的 git 目录。
#           Set the git directory for your code project.
#
# NAME_FROM_GIT: 从 git 信息中提取工程名字。
#                Extract the project name from the git message.
#
# VERSION_FROM_GIT: 从 git 信息中提取工程版本（别用）。
#                   Extract the project version from the git message (don't use it).
#
# VERSION_NAME_FROM_GIT: 从 git 信息中提取工程版本名称（哈希值）。
#                        Extract the project version name (hash) from the git message.
#
# VERSION_NAME: 自定义版本名称。
#               Customized version name.
# --------------------------------------------------------------------------------------------------------------

function(aoe_manifest)
    # Parse parameters. Start by treating VERSION_NAME_FROM_GIT as a single-valued parameter.
    cmake_parse_arguments(
        config ""
        "GIT_ROOT;NAME_FROM_GIT;VERSION_FROM_GIT;VERSION_NAME_FROM_GIT;VERSION_NAME"
        ""
        ${ARGN}
    )
    aoe_disable_unknown_params(config)
    aoe_expect_related_param(config NAME_FROM_GIT         GIT_ROOT)
    aoe_expect_related_param(config VERSION_FROM_GIT      GIT_ROOT)
    aoe_expect_related_param(config VERSION_NAME_FROM_GIT GIT_ROOT)
    aoe_disable_conflicting_params(config VERSION_NAME_FROM_GIT VERSION_NAME)

    # Handle the case where VERSION_NAME_FROM_GIT is an option parameter
    if (DEFINED config_VERSION_NAME_FROM_GIT)
        set(should_read_version_name_from_git ON)
    else ()
        cmake_parse_arguments(another_config "VERSION_NAME_FROM_GIT" "VERSION_NAME" "" ${ARGN})
        aoe_disable_conflicting_params(config VERSION_NAME_FROM_GIT VERSION_NAME)
        set(should_read_version_name_from_git ${another_config_VERSION_NAME_FROM_GIT})
    endif ()

    # Get script directory
    __aoe_common_property(SCRIPT_DIRECTORY_PATH GET script_directory_path)

    # Handle the reading of project name
    if (DEFINED config_NAME_FROM_GIT)
        aoe_execute_process(
            "${script_directory_path}/get_project_name_from_git.bash" ${config_GIT_ROOT}
            RESULT ${config_NAME_FROM_GIT}
        )
        aoe_output(${config_NAME_FROM_GIT})
    endif ()

    # Handle the reading of project version
    if (DEFINED config_VERSION_FROM_GIT)
        aoe_execute_process(
            "${script_directory_path}/get_version_from_git.bash" ${config_GIT_ROOT}
            RESULT ${config_VERSION_FROM_GIT}
        )
        aoe_output(${config_VERSION_FROM_GIT})
    endif ()

    # Prepare to initialize the project version name, which is nullable
    unset(version_name)

    # Handle the setting of the project version name
    if (DEFINED config_VERSION_NAME)
        set(version_name ${config_VERSION_NAME})
    endif ()

    # Handle the reading of the project version name
    if (${should_read_version_name_from_git})
        aoe_execute_process(
            "${script_directory_path}/get_version_name_from_git.bash" ${config_GIT_ROOT}
            RESULT version_name
        )

        if (DEFINED config_VERSION_NAME_FROM_GIT)
            aoe_output(${config_VERSION_NAME_FROM_GIT} ${version_name})
        endif ()
    endif ()

    # Staging the version name, which will be used when the project is initialized
    __aoe_common_property(META_VERSION_NAME SET ${version_name})
endfunction()
