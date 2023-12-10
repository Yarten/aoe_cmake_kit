# --------------------------------------------------------------------------------------------------------------
# 加载当前使用的安装布局。
# Loads the currently used installation layout.
# --------------------------------------------------------------------------------------------------------------
# __aoe_load_current_install_layout(include lib bin cmake build)
#
# include: 用于设置头文件目录的输出变量。
#          Output variable used to set the header file directory.
#
# lib: 用于设置库目录的输出变量。
#      Output variable used to set the library directory.
#
# bin: 用于设置可执行文件目录的输出变量。
#      Output variable used to set the directory of the executable file.
#
# cmake: 用于设置 cmake 配置文件目录的输出变量。
#        Output variable used to set the directory of cmake configuration files.
#
# build: 用于设置临时目录的输出变量。
#        Output variable used to set the temporary directory.
# --------------------------------------------------------------------------------------------------------------

function(__aoe_load_current_install_layout include lib bin cmake build)
    aoe_disable_extra_params()

    __aoe_current_layout_property(INSTALL_INCLUDE GET include_)
    __aoe_current_layout_property(INSTALL_LIB     GET lib_)
    __aoe_current_layout_property(INSTALL_BIN     GET bin_)
    __aoe_current_layout_property(INSTALL_CMAKE   GET cmake_)

    __aoe_configure(include_ ${include_})
    __aoe_configure(lib_     ${lib_})
    __aoe_configure(bin_     ${bin_})
    __aoe_configure(cmake_   ${cmake_})

    aoe_output(${include} ${include_})
    aoe_output(${lib}     ${lib_})
    aoe_output(${bin}     ${bin_})
    aoe_output(${cmake}   ${cmake_})
    aoe_output(${build}  "${CMAKE_BINARY_DIR}/.aoe/${PROJECT_NAME}/install")
endfunction()
