# --------------------------------------------------------------------------------------------------------------
# 创建一个可执行目标。
# Create an executable target.
# --------------------------------------------------------------------------------------------------------------
# aoe_add_executable(target
#   [DEPEND         <other library target> ...]
#   [FORCE_DEPEND   <other library target> ...]
#   [BUILD_DEPEND   <other target>         ...]
#
#   [IMPORT         <3rd> ...]
#   [COMPONENTS [<3rd> <3rd component> ...]]
#
#   [ALIAS <alias>]
#   [NO_INSTALL]
#
#   [INCLUDES         <dir> ...]
#   [NO_DEFAULT_INCLUDES]
#
#   [SOURCES            <file> ...]
#   [SOURCE_DIRECTORIES <dir>  ...]
#   [NO_DEFAULT_SOURCES]
#   [AUX]
#
#   [LIBARIES          <path> ...]
# )
# --------------------------------------------------------------------------------------------------------------
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
# ALIAS: 设置编译制品的别名。
#        Set the alias of the compiled product.
#
# NO_INSTALL: 设置该库不要导出。
#             Set this library not to export.
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
# SOURCE_DIRECTORIES: 为本目标导入指定源文件目录下的所有源文件。
#                     Import all source files in the specified source file directories for this target.
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

function(aoe_add_executable target)
    __aoe_parse_target_arguments("MOD" config "" "" "" ${ARGN})
    __aoe_add_target("executable")
endfunction()
