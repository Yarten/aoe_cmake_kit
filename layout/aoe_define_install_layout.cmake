# --------------------------------------------------------------------------------------------------------------
# 定义工程执行安装命令后，各种制品的目录结构。
# Defines the directory structure of various installed files after the project executes the install command.
# --------------------------------------------------------------------------------------------------------------
# aoe_define_install_layout(name include lib bin cmake)
#
# name: 本安装目录结构的名称。
#       Name of this install layout.
#
# include: 头文件目录。
#          Directory of headers.
#
# lib: 库目录。
#      Directory of libraries.
#
# bin: 可执行文件目录。
#      Directory of executables.
#
# cmake: cmake 配置的文件目录。
#        Directory of cmake config files.
# --------------------------------------------------------------------------------------------------------------
# 可用的上下文变量 (Available context variables):
#   @target@: 被安装的目标名称。
#             Name of the installed target.
# --------------------------------------------------------------------------------------------------------------

function(aoe_define_install_layout name include lib bin cmake)
    aoe_disable_extra_params()

    __aoe_layout_property(${name} INSTALL_INCLUDE SET ${include})
    __aoe_layout_property(${name} INSTALL_LIB     SET ${lib})
    __aoe_layout_property(${name} INSTALL_BIN     SET ${bin})
    __aoe_layout_property(${name} INSTALL_CMAKE   SET ${cmake})

    __aoe_project_property(ALL_INSTALL_LAYOUTS APPEND ${name})
endfunction()
