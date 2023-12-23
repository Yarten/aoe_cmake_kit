# --------------------------------------------------------------------------------------------------------------
# 对 FetchContent 的简单封装，用于导入一个外部 cmake 工程。
# Simple wrapper for FetchContent to import an external cmake project.
# --------------------------------------------------------------------------------------------------------------
# aoe_import(url tag
#   [USE <target> ...]
#   [ALL]
#   [TO <appended list>]
# )
#
# url: 被导入的工程的 git 仓库首页地址、或者可以 git clone 的地址。
#      The address of the home page of the git repository of the imported project,
#      or the address where you can git clone the project.
#
# tag: 指定的分支。
#      The specified branch.
# --------------------------------------------------------------------------------------------------------------
# USE: 需要从该工程中取用的库目标。
#      The library targets that need to be fetched from the project.
#
# ALL: 设置从该工程中取出全部的库目标。
#      Set to take all library targets from the project.
#
# TO: 将取出的库目标名称写入到给定的列表变量中。
#     Append the names of the required library targets to the given list variable.
# --------------------------------------------------------------------------------------------------------------

function(aoe_import url tag)
    cmake_parse_arguments(config "ALL" "TO" "USE" ${ARGN})
    aoe_disable_unknown_params(config)

    # Get the name of the imported package
    string(REGEX REPLACE ".*\\.com[:/]" ""  name "${url}")
    string(REGEX REPLACE "\\.git$"     ""  name "${name}")
    string(REPLACE       "/"           "-" name "${name}")

    # Append the .git suffix to url if it doesn't have one
    string(REGEX MATCH "\\.git$" git_suffix "${url}")

    if ("${git_suffix}" STREQUAL "")
        set(url "${url}.git")
    endif ()

    # Fetch the package
    include(FetchContent)
    FetchContent_Declare("${name}" GIT_REPOSITORY "${url}" GIT_TAG "${tag}")
    FetchContent_MakeAvailable("${name}")

    if (NOT DEFINED config_TO)
        return()
    endif ()

    # Get all library targets belonging to the package
    FetchContent_GetProperties("${name}" SOURCE_DIR dir)
    get_property(all_targets DIRECTORY "${dir}" PROPERTY BUILDSYSTEM_TARGETS)

    unset(targets)
    foreach (i ${all_targets})
        get_target_property(target_type ${i} TYPE)

        if ("${target_type}" STREQUAL "STATIC_LIBRARY" OR
            "${target_type}" STREQUAL "SHARED_LIBRARY" OR
            "${target_type}" STREQUAL "INTERFACE_LIBRARY")
            list(APPEND targets ${i})
        endif ()
    endforeach ()

    # Get the required library targets
    unset(required_targets)
    if (${config_ALL})
        set(required_targets ${targets})
    else ()
        foreach (i ${config_USE})
            list(FIND targets ${i} index)

            if (${index} EQUAL -1)
                message(FATAL_ERROR "CAN NOT find the [${i}] component in [${name}] !")
            endif ()

            list(APPEND required_targets ${i})
        endforeach ()
    endif ()

    # Append the required components from the package to the output list
    list(APPEND ${config_TO} ${required_targets})
    list(REMOVE_DUPLICATES ${config_TO})
    aoe_output(${config_TO})
endfunction()
