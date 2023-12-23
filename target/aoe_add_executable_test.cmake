# --------------------------------------------------------------------------------------------------------------
# 创建一个可执行的测试目标。若刚好存在同名的库目标，将会强制依赖它。
# Create an executable test target.
# If a library target with the same name exists, it will FORCE_DEPEND on it.
# --------------------------------------------------------------------------------------------------------------
# aoe_add_executable_test(target
#   [CASE <case name>]
#
#   [DEPEND         <other library target> ...]
#   [FORCE_DEPEND   <other library target> ...]
#   [BUILD_DEPEND   <other target>         ...]
#
#   [IMPORT         <3rd> ...]
#   [COMPONENTS [<3rd> <3rd component> ...]]
#
#   [INCLUDES         <dir> ...]
#   [NO_DEFAULT_INCLUDES]
#
#   [SOURCES            <file> ...]
#   [SOURCE_DIRECTORIES <dir>  ...]
#   [NO_DEFAULT_TEST_SOURCES]
#   [AUX]
#
#   [LIBARIES          <path> ...]
# )
# --------------------------------------------------------------------------------------------------------------
# CASE: 给本测试目标设置的测试样例名称。
#       The name of the test case set for this test target.
#
# DEPEND: 本目标依赖的工程内的其他库目标，将自动导入它们的头文件目录与库文件。
#         Other library targets within the project that this target depends on,
#         will automatically import their header file directories and library files.
#
# FORCE_DEPEND: 类似 DEPEND，但使用编译器链接选项，使它们必定被用上。
#               Similar to DEPEND, but use linking options to make sure that they are bound to be linked.
#
# BUILD_DEPEND: 本目标依赖的工程内的其他目标，仅用于控制编译顺序。
#               Other targets within the project that this target depends on,
#               they are used only to control the order of compilation.
#
# IMPORT: 本目标依赖的第三方库，将自动导入它们的头文件目录与库文件。若导入过程比较特殊，请自行导入，
#         并通过 INCLUDES 和 LIBARIES 参数手动设置。
#         Third-party libraries that this target depends on,
#         will automatically import their header file directory and library file.
#         If the import process is special, please import it by yourself,
#         and set manually with the INCLUDES and LIBARIES parameters.
#
# COMPONENTS: 各个导入的第三方库（也即由 IMPORT 与 PRIVATE_IMPORT 参数指定的第三方依赖）的组件，
#             需要使用各个第三方库的名称进行组件分组。
#             Components of each imported third-party library
#             (i.e., third-party dependencies specified by the IMPORT and PRIVATE_IMPORT parameters),
#             need to be grouped using the name of each third-party library.
#
# INCLUDES: 为本目标导入头文件目录。
#           Import the header file directories for this target.
#
# NO_DEFAULT_INCLUDES: 设置不要导入默认头文件目录。
#                      Set not to import the default header file directories.
#
# SOURCES: 为本目标导入源文件。
#          Import source files for this target.
#
# NO_DEFAULT_TEST_SOURCES: 为本目标导入指定测试源文件目录下的所有源文件。
#                          Import all source files in the specified testing source file directories for this target.
#
# NO_DEFAULT_SOURCES: 设置不要导入默认源文件目录下的源文件。
#                     Set not to import source files from the default source files directories.
#
# AUX: 标识该可执行目标没有源文件。一般需要与 FORCE_DEPEND 参数配合。
#      Identifies that this executable target has no source files.
#      Generally used with the FORCE_DEPEND parameter.
#
# LIBARIES: 为本目标导入库文件。
#           Import libraries for this target.
# --------------------------------------------------------------------------------------------------------------

function(aoe_add_executable_test target)
    __aoe_parse_target_arguments("" config "NO_DEFAULT_TEST_SOURCES" "CASE" "" ${ARGN})

    # Add the source files in default source directories
    if (NOT ${config_NO_DEFAULT_TEST_SOURCES})
        # If CASE is set, a different default option will be used
        if (DEFINED config_CASE)
            set(case ${config_CASE})
            __aoe_current_layout_property(TARGET_TESTS_OF_CASE GET default_test_source_patterns)
        else ()
            unset(case)
            __aoe_current_layout_property(TARGET_TESTS GET default_test_source_patterns)
        endif ()

        # Add the source files
        foreach (pattern ${default_test_source_patterns})
            __aoe_configure(default_test_source ${pattern})
            aoe_source_directories(target_sources ${CMAKE_CURRENT_LIST_DIR}/${default_test_source})
        endforeach ()
    endif ()

    # Force link the existed library target that has the same name with this test target
    if (TARGET ${target})
        get_target_property(same_name_target_type ${target} TYPE)

        if (NOT "${same_name_target_type}" STREQUAL "EXECUTABLE")
            list(APPEND config_FORCE_DEPEND ${target})
        endif ()
    endif()

    # Rename the test target and begin to create it
    if (DEFINED config_CASE)
        set(target ${target}-TEST-${config_CASE})
    else ()
        set(target ${target}-TEST)
    endif ()

    __aoe_add_target("executable")
endfunction()
