# --------------------------------------------------------------------------------------------------------------
# 编译 protobuf 文件并创建为库目标，生成的 include 目录与 protobuf 文件的目录保持一致。
# Compile the protobuf files and create them as a library target,
# whose include directory structure matches the directory structure of the protobuf files.
# --------------------------------------------------------------------------------------------------------------
# aoe_add_protobuf(target
#   [DEPEND             <other protobuf target>     ...]
#   [SOURCE_DIRECTORIES <protobuf files' directory> ...]
#   [NO_DEFAULT_SOURCES]
#   [SHARED | STATIC]
# )
#
# 本函数不会立即编译 protobuf 文件，并创建对应的库目标。全部的 protobuf 的生成将在
# aoe_project_complete() 函数中完成。
# This function dose not compile the protobuf files immediately and create the corresponding library target.
# All protobuf generation will be done in the aoe_project_complete() function.
#
# target: 该 protobuf 目标的名称。
#         Name of this protobuf target.
# --------------------------------------------------------------------------------------------------------------
# DEPEND: 本目标依赖的其他工程 protobuf 目标。
#         Other protobuf targets within the project that this target depends on.
#
# SOURCE_DIRECTORIES: 为本目标指定的 protobuf 目录。
#                     The protobuf directories specified for this target.
#
# NO_DEFAULT_SOURCES: 设置不要使用默认 protobuf 目录。
#                     Set not to use the default protobuf directories.
#
# SHARED: 将 protobuf 目标编译为动态库。
#         Compile this protobuf target into dynamic library.
#
# STATIC: 将 protobuf 目标编译为静态库。
#         Compile this protobuf target into static library.
# --------------------------------------------------------------------------------------------------------------

function(aoe_add_protobuf target)
    # 解析参数
    cmake_parse_arguments(config "NO_DEFAULT_SOURCES;SHARED;STATIC" "" "DEPEND;SOURCE_DIRECTORIES" ${ARGN})
    aoe_disable_unknown_params(config)
    aoe_disable_conflicting_params(config SHARED STATIC)

    # 不允许同名的 protobuf target 重定义
    __aoe_project_property(PROTOBUF_TARGETS CHECK ${target} CHECK_STATUS is_existed)

    if (${is_existed})
        message(FATAL_ERROR "A protobuf target named [${target}] has been defined !")
    endif ()

    __aoe_project_property(PROTOBUF_TARGETS APPEND ${target})

    # 设置默认源文件目录
    if (NOT ${config_NO_DEFAULT_SOURCES})
        __aoe_current_layout_property(TARGET_PROTOS GET default_source_patterns)

        foreach (pattern ${default_source_patterns})
            __aoe_configure(default_source ${pattern})
            list(APPEND config_SOURCE_DIRECTORIES ${CMAKE_CURRENT_LIST_DIR}/${default_source})
        endforeach ()
    endif ()

    # 记录本 protobuf 目标的基本信息，将在 aoe_project_complete() 函数中实现构建
    __aoe_protobuf_property(${target} SOURCE_DIRECTORIES SET ${config_SOURCE_DIRECTORIES})
    __aoe_protobuf_property(${target} DEPENDENCIES       SET ${config_DEPEND})

    if (DEFINED BUILD_SHARED_LIBS)
        set(default_build_shared ${BUILD_SHARED_LIBS})
    else ()
        set(default_build_shared OFF)
    endif ()

    if (${config_SHARED} OR (${default_build_shared} AND NOT ${config_STATIC}))
        __aoe_protobuf_property(${target} SHARED SET ON)
    else ()
        __aoe_protobuf_property(${target} SHARED SET OFF)
    endif ()
endfunction()
