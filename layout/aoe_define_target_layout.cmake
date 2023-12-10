# --------------------------------------------------------------------------------------------------------------
# 定义所有 aeo target  的默认目录，包括源文件目录、头文件目录等。
# Define the default directories for all aeo targets,
# including source file directories, header file directories, etc.
# --------------------------------------------------------------------------------------------------------------
# aoe_define_target_layout(name
#   [INCLUDES      <relative path> ...]
#   [SOURCES       <relative path> ...]
#   [PROTOS        <relative path> ...]
#   [TESTS         <relative path> ...]
#   [TESTS_OF_CASE <relative path> ...]
#   [NO_DEFAULT_INCLUDES]
#   [NO_DEFAULT_SOURCES]
#   [NO_DEFAULT_PROTOS]
#   [NO_DEFAULT_TESTS]
#   [NO_DEFAULT_TESTS_OF_CASE]
# )
#
# name: 本 aoe target 目录结构的名称。
#       Name of this aoe target layout.
#
# p.s. 参数中的路径均为相对于定义 target 的 CMakeLists.txt 所在目录的相对路径。
#      The paths in the parameters are relative to the directory
#      where the CMakeLists.txt file defining the target is located.
# --------------------------------------------------------------------------------------------------------------
# INCLUDES: 头文件目录。
#           Directories of header files.
#
# SOURCES: 源文件目录。
#          Directories of source files.
#
# PROTOS: protobuf 文件目录。
#         Directories of protobuf files.
#
# TESTS: 测试 target 的源文件目录。
#        The source directories of the test target.
#
# TESTS_OF_CASE: 指定了 CASE 参数的测试 target 的源文件目录。
#                The source directories of the test target for which the CASE parameter is specified.
# --------------------------------------------------------------------------------------------------------------
# 可用的上下文变量 (Available context variables):
#   @target@: 目标的名称。
#             Name of the target.
#
#   @case@: test target 的 CASE 名称。
#           CASE name of the test target.
#
#   其他的 cmake 内置变量，以及用户自定义变量。
#   Other cmake variables and user defined variables.
# --------------------------------------------------------------------------------------------------------------

function(aoe_define_target_layout name)
    # 所有的可配置项及其默认值
    aoe_list(options APPEND "INCLUDES"      "include")
    aoe_list(options APPEND "SOURCES"       "src/@target@")
    aoe_list(options APPEND "PROTOS"        "proto/@target@")
    aoe_list(options APPEND "TESTS"         "test/@target@")
    aoe_list(options APPEND "TESTS_OF_CASE" "test/@target@-@case@")

    aoe_list(options LENGTH options_count)

    # 组装解析参数
    foreach (i RANGE 1 ${options_count})
        math(EXPR i "${i} - 1")
        aoe_list(options GET ${i} option default_value)

        list(APPEND no_default_params NO_DEFAULT_${option})
        list(APPEND value_params ${option})
    endforeach ()

    # 解析输入参数
    cmake_parse_arguments(config "${no_default_params}" "" "${value_params}" ${ARGN})
    aoe_disable_unknown_params(config)

    # 注册所有选项
    foreach (i RANGE 1 ${options_count})
        math(EXPR i "${i} - 1")
        aoe_list(options GET ${i} option default_value)

        # 为没有给定值的选项设置默认值（如果允许的话）
        if (NOT DEFINED config_${option} AND NOT ${config_NO_DEFAULT_${option}})
            set(config_${option} ${default_value})
        endif ()

        # 记录布局选项
        __aoe_layout_property(${name} TARGET_${option} SET ${config_${option}})
    endforeach ()

    # 追加本布局名称
    __aoe_project_property(ALL_TARGET_LAYOUTS APPEND ${name})
endfunction()
