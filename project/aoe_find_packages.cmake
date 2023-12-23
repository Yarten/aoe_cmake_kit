# --------------------------------------------------------------------------------------------------------------
# 查找指定多个第三库，并将头文件目录、库文件路径添加到对应或指定变量中。
# Finds the specified multiple third libraries,
# and adds the header file directories and library file paths to the corresponding or specified variables.
# --------------------------------------------------------------------------------------------------------------
# aoe_find_packages(
#   [<name> ...]
#   [AS <result>]
#   [COMPONENTS [<name> <name-component> ...]]
# )
#
# 可传入多个 name 参数，代表查找多个第三方库，并将头文件目录写入到 ${name}_INCLUDE_DIRS、${name}_INCLUDE_DIR 变量中，将库文件
# 路径写入到 ${name}_LIBRARIES、${name}_LIBRARY 变量中。
# The paths to the header file directories of the third-party library 'name' are set to
# ${name}_INCLUDE_DIRS and ${name}_INCLUDE_DIR,
# while the paths to the library files are set to ${name}_LIBRARIES、${name}_LIBRARY.
# --------------------------------------------------------------------------------------------------------------
#
# AS: 将找到的所有头文件目录、库文件路径，记录到 ${result}_INCLUDE_DIRS、${result}_INCLUDE_DIR、${result}_LIBRARIES、
#     ${result}_LIBRARY 变量中。
#     Set all paths to the header file directories to ${result}_INCLUDE_DIRS and${result}_INCLUDE_DIR,
#     while set all paths to the library files to ${result}_LIBRARIES and ${result}_LIBRARY.
#
# COMPONENTS: 各个待导入的第三方库的组件，使用各个第三方库的名称进行分组。
#             The components of each third-party library to be imported.
#             They are grouped using the name of each third-party library.
# --------------------------------------------------------------------------------------------------------------
# @example
#
# aoe_find_packages(
#   eigen3 Boost
#   COMPONENTS
#       Boost system thread
#   AS result
# )
# message(${Boost_INCLUDE_DIRS} ${result_LIBRARIES})
# --------------------------------------------------------------------------------------------------------------

function(aoe_find_packages)
    # Parse the input parameters
    cmake_parse_arguments(config "" "AS" "COMPONENTS" ${ARGN})
    set(packages ${config_UNPARSED_ARGUMENTS})

    # Parse the COMPONENTS parameters to get the respective components of all third-party libraries
    # which are separated by the libraries' names
    cmake_parse_arguments(components "" "" "${packages}" ${config_COMPONENTS})

    foreach(package ${packages})
        aoe_find_package(${package} COMPONENTS ${components_${package}})
    endforeach()

    # If the AS parameter is specified,
    # all header file directories and library file paths are summarized together in the output variable defined by AS
    if (DEFINED config_AS)
        __aoe_clear_includes_and_libraries(${config_AS})

        foreach(package ${packages})
            list(APPEND ${config_AS}_LIBRARIES    ${${package}_LIBRARIES})
            list(APPEND ${config_AS}_INCLUDE_DIRS ${${package}_INCLUDE_DIRS})
        endforeach()

        __aoe_standardize_includes_and_libraries(${config_AS} "")
    endif ()
endfunction()
