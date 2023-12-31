# --------------------------------------------------------------------------------------------------------------
# 在本工程下，基于工程名称、版本信息等配置，创建一个版本目标，用于提供版本头文件。
# --------------------------------------------------------------------------------------------------------------
# aoe_add_version(target include_pattern namespace)
#
# target: 该版本目标的名称
#
# include_pattern: 生成的版本头文件所在头文件目录的层级
#
# namespace: 命名空间
# --------------------------------------------------------------------------------------------------------------

function(aoe_add_version target include_pattern namespace)
    aoe_disable_extra_params()

    set(target_root        "${CMAKE_BINARY_DIR}/.aoe/${PROJECT_NAME}/version-targets/${target}")
    set(target_header_root "${target_root}/include/${include_pattern}")

    # Delete the entire contents of the already existing version target and recreate one
    file(REMOVE_RECURSE ${target_root})
    file(MAKE_DIRECTORY ${target_header_root})

    # Generate cmake files and header files for this version target
    # based on the project name, version number and version name, and namespace.
    set(_namespace_ ${namespace})
    __aoe_project_property(VERSION_NAME GET _version_name_)

    # Convert project name to C++ legal variable names with all-lowercase and all-uppercase formatting, respectively
    set(project_name ${PROJECT_NAME})
    string(REGEX REPLACE "[^a-z,A-Z,0-9,_]" "_" project_name ${project_name})
    string(SUBSTRING ${project_name} 0  1 project_name_head)
    string(SUBSTRING ${project_name} 1 -1 project_name_tail)
    string(REGEX REPLACE "[0-9]" "aoe_" project_name_head ${project_name_head})
    set(project_name "${project_name_head}${project_name_tail}")

    string(TOLOWER ${project_name} _project_name_lower_)
    string(TOUPPER ${project_name} _project_name_upper_)

    # Convert the project version to a number
    math(EXPR _version_number_
        "${PROJECT_VERSION_MAJOR} * 10000 + ${PROJECT_VERSION_MINOR} * 100 + ${PROJECT_VERSION_PATCH}")

    # Generate source files for this version target
    __aoe_common_property(TEMPLATE_DIRECTORY_PATH GET template_directory_path)

    configure_file(
        "${template_directory_path}/version_target_CMakeLists.txt.in"
        "${target_root}/CMakeLists.txt"
        @ONLY
    )
    configure_file(
        "${template_directory_path}/version_header.hpp.in"
        "${target_header_root}/version.hpp"
        @ONLY
    )

    add_subdirectory("${target_root}" "${target_root}.out")
endfunction()
