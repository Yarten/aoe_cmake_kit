# --------------------------------------------------------------------------------------------------------------
# 定义所有 aeo target  的默认目录，包括源文件目录、头文件目录等。
# Define the default directories for all aeo targets,
# including source file directories, header file directories, etc.
# --------------------------------------------------------------------------------------------------------------
# aoe_define_target_layout(name
#   [INCLUDES              <relative path> ...]
#   [SOURCES               <relative path> ...]
#   [PROTOS                <relative path> ...]
#   [TESTS                 <relative path> ...]
#   [TESTS_OF_CASE         <relative path> ...]
#   [TEST_FILES            <relative path> ...]
#   [TEST_FILES_OF_CASE    <relative path> ...]
#   [EXAMPLE_FILES         <relative path> ...]
#   [EXAMPLE_FILES_OF_CASE <relative path> ...]
#   [NO_DEFAULT_INCLUDES]
#   [NO_DEFAULT_SOURCES]
#   [NO_DEFAULT_PROTOS]
#   [NO_DEFAULT_TESTS]
#   [NO_DEFAULT_TESTS_OF_CASE]
#   [NO_DEFAULT_TEST_FILES]
#   [NO_DEFAULT_TEST_FILES_OF_CASE]
#   [NO_DEFAULT_EXAMPLE_FILES]
#   [NO_DEFAULT_EXAMPLE_FILES_OF_CASE]
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
#           Directories of header files. Used by aoe_add_library() and aoe_add_executable().
#
# SOURCES: 源文件目录。
#          Directories of source files. Used by aoe_add_library() and aoe_add_executable().
#
# PROTOS: protobuf 文件目录。
#         Directories of protobuf files. Used by aoe_add_protobuf()
#
# TESTS: 测试 target 的源文件目录。
#        The source directories of the test target. Used by aoe_add_executable_test()
#
# TESTS_OF_CASE: 指定了 CASE 参数的测试 target 的源文件目录。
#                The source directories of the test target for which the CASE parameter is specified.
#                Used by aoe_add_executable_test()
#
# TEST_FILES: 测试 target 的源文件列表。
#             The source files of the test target. Used by aoe_add_test().
#
# TEST_FILES_OF_CASE: 指定了 CASE 参数的测试 target 的源文件列表。
#                     The source files of the test target for which the CASE parameter is specified.
#                     Used by aoe_add_test().
#
# EXAMPLE_FILES: 例子 target 的源文件列表。
#                The source files of the example target. Used by aoe_add_example().
#
# EXAMPLE_FILES_OF_CASE: 指定了 CASE 参数的例子 target 的源文件列表。
#                        The source files of the example target for which the CASE parameter is specified.
#                        Used by aoe_add_example().
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
    # All configurable items and their default values
    aoe_list(options APPEND "INCLUDES"      "include")
    aoe_list(options APPEND "SOURCES"       "src/@target@")
    aoe_list(options APPEND "PROTOS"        "proto/@target@")
    aoe_list(options APPEND "TESTS"         "test/@target@")
    aoe_list(options APPEND "TESTS_OF_CASE" "test/@target@-@case@")
    aoe_list(options APPEND "TEST_FILES"            "test/@target@.cpp")
    aoe_list(options APPEND "TEST_FILES_OF_CASE"    "test/@target@-@case@.cpp")
    aoe_list(options APPEND "EXAMPLE_FILES"         "example/@target@.cpp")
    aoe_list(options APPEND "EXAMPLE_FILES_OF_CASE" "example/@target@-@case@.cpp")

    aoe_list(options LENGTH options_count)

    # Prepare parameters to parse the input arguments
    foreach (i RANGE 1 ${options_count})
        math(EXPR i "${i} - 1")
        aoe_list(options GET ${i} option default_value)

        list(APPEND no_default_params NO_DEFAULT_${option})
        list(APPEND value_params ${option})
    endforeach ()

    # Parse input arguments
    cmake_parse_arguments(config "${no_default_params}" "" "${value_params}" ${ARGN})
    aoe_disable_unknown_params(config)

    # Record all items for this new layout
    foreach (i RANGE 1 ${options_count})
        math(EXPR i "${i} - 1")
        aoe_list(options GET ${i} option default_value)

        if (NOT DEFINED config_${option} AND NOT ${config_NO_DEFAULT_${option}})
            set(config_${option} ${default_value})
        endif ()

        __aoe_layout_property(${name} TARGET_${option} SET ${config_${option}})
    endforeach ()

    # Record the new layout's name
    __aoe_project_property(ALL_TARGET_LAYOUTS APPEND ${name})
endfunction()
