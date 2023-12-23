# --------------------------------------------------------------------------------------------------------------
# 定义工程执行安装命令后，各种制品的目录结构。
# Defines the directory structure of various installed files after the project executes the install command.
# --------------------------------------------------------------------------------------------------------------
# aoe_define_install_layout(name
#   [INCLUDE <relative path>]
#   [LIB     <relative path>]
#   [BIN     <relative path>]
#   [CMAKE   <relative path>]
# )
#
# name: 本安装目录结构的名称。
#       Name of this install layout.
#
# p.s. 参数中的路径均为相对于安装目录的相对路径。
#      The paths in the parameters are relative to the installation directory.
# --------------------------------------------------------------------------------------------------------------
# INCLUDE: 头文件目录。
#          Directory of headers.
#
# LIB: 库目录。
#      Directory of libraries.
#
# BIN: 可执行文件目录。
#      Directory of executables.
#
# CMAKE: cmake 配置的文件目录。
#        Directory of cmake config files.
# --------------------------------------------------------------------------------------------------------------
# 可用的上下文变量 (Available context variables):
#   @target@: 被安装的目标名称。
#             Name of the installed target.
#
#   其他的 cmake 内置变量，以及用户自定义变量。
#   Other cmake variables and user defined variables.
# --------------------------------------------------------------------------------------------------------------

function(aoe_define_install_layout name)
    # All configurable items and their default values
    aoe_list(options APPEND "INCLUDE" ".")
    aoe_list(options APPEND "LIB"     "lib")
    aoe_list(options APPEND "BIN"     "bin")
    aoe_list(options APPEND "CMAKE"   "lib/cmake/@PROJECT_NAME@")

    aoe_list(options LENGTH options_count)

    # Prepare parameters to parse the input arguments
    foreach (i RANGE 1 ${options_count})
        math(EXPR i "${i} - 1")
        aoe_list(options GET ${i} option default_value)

        list(APPEND value_params ${option})
    endforeach ()

    # Parse input arguments
    cmake_parse_arguments(config "" "${value_params}" "" ${ARGN})
    aoe_disable_unknown_params(config)

    # Record all items for this new layout
    foreach (i RANGE 1 ${options_count})
        math(EXPR i "${i} - 1")
        aoe_list(options GET ${i} option default_value)

        if (NOT DEFINED config_${option})
            set(config_${option} ${default_value})
        endif ()

        __aoe_layout_property(${name} INSTALL_${option} SET ${config_${option}})
    endforeach ()

    # Record the new layout's name
    __aoe_project_property(ALL_INSTALL_LAYOUTS APPEND ${name})
endfunction()
