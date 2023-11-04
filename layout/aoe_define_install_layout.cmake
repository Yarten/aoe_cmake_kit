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
    # 所有的可配置项及其默认值
    aoe_list(options APPEND "INCLUDE" "include")
    aoe_list(options APPEND "LIB"     "lib")
    aoe_list(options APPEND "BIN"     "bin")
    aoe_list(options APPEND "CMAKE"   "lib/cmake/@PROJECT_NAME@")

    aoe_list(options LENGTH options_count)

    # 组装解析参数
    foreach (i RANGE 1 ${options_count})
        math(EXPR i "${i} - 1")
        aoe_list(options GET ${i} option default_value)

        list(APPEND value_params ${option})
    endforeach ()

    # 解析输入参数
    cmake_parse_arguments(config "" "${value_params}" "" ${ARGN})
    aoe_disable_unknown_params(config)

    # 注册所有选项
    foreach (i RANGE 1 ${options_count})
        math(EXPR i "${i} - 1")
        aoe_list(options GET ${i} option default_value)

        # 为没有给定值的选项设置默认值
        if (NOT DEFINED config_${option})
            set(config_${option} ${default_value})
        endif ()

        # 记录布局选项
        __aoe_layout_property(${name} INSTALL_${option} SET ${config_${option}})
    endforeach ()

    # 追加本布局名称
    __aoe_project_property(ALL_INSTALL_LAYOUTS APPEND ${name})
endfunction()
