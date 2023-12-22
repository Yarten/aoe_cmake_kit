# --------------------------------------------------------------------------------------------------------------
# Partial implementation of the aoe_add_xxx() functions.
#
# type: executable | library
# --------------------------------------------------------------------------------------------------------------

macro(__aoe_add_target type)
    # -------------------------------------------------------------
    # 追加模块默认源文件目录
    if (NOT ${config_NO_DEFAULT_SOURCES})
        __aoe_current_layout_property(TARGET_SOURCES GET default_source_patterns)

        foreach (pattern ${default_source_patterns})
            __aoe_configure(default_source ${pattern})
            aoe_source_directories(target_sources ${CMAKE_CURRENT_LIST_DIR}/${default_source})
        endforeach ()
    endif ()

    # -------------------------------------------------------------
    # 追加传入的源文件，以及给定源文件目录下的所有源文件
    aoe_source_directories(target_sources ${config_SOURCE_DIRECTORIES})
    list(APPEND target_sources ${config_SOURCES})

    # -------------------------------------------------------------
    # 处理 AUX 参数
    if (${config_AUX})
        __aoe_common_property(TEMPLATE_DIRECTORY_PATH GET template_directory_path)
        set(target_sources "${template_directory_path}/empty.cpp")
    endif ()

    # -------------------------------------------------------------
    # 如果没有给定源码，将处于接口模式。（可执行目标无效）
    if ("${target_sources}" STREQUAL "")
        set(is_interface ON)
    else ()
        set(is_interface OFF)
    endif ()

    macro(this_target_include_directories is_private items)
        if (${is_interface})
            set(option "INTERFACE")
        elseif (${is_private})
            set(option "PRIVATE")
        else ()
            set(option "PUBLIC")
        endif ()

        foreach (dir ${items})
            if ("${dir}" MATCHES "^\\$<.*>$")
                # 传入的是生成表达式，则只能直接使用它
                target_include_directories(${target} ${option} "${dir}")
            else ()
                # 若传入的头文件目录在本模块目录下，则记录为本模块自己的头文件目录，并将安装它
                get_filename_component(full_path "${dir}" ABSOLUTE BASE_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
                file(RELATIVE_PATH relative_path "${CMAKE_CURRENT_SOURCE_DIR}" "${full_path}")

                if ("${relative_path}" MATCHES "^\\.\\.")
                    target_include_directories(${target} ${option} "${full_path}")
                else ()
                    target_include_directories(${target} ${option}
                        $<BUILD_INTERFACE:${full_path}>
                        $<INSTALL_INTERFACE:${relative_path}>
                    )
                    __aoe_target_property(${target} EGO_INCLUDES APPEND "${full_path}")
                endif ()
            endif ()
        endforeach ()
    endmacro()

    macro(this_target_link_directories is_private items)
        if (${is_interface})
            set(option "INTERFACE")
        elseif (${is_private})
            set(option "PRIVATE")
        else ()
            set(option "PUBLIC")
        endif ()

        target_link_libraries(${target} ${option} ${items})
    endmacro()

    # -------------------------------------------------------------
    # 创建目标
    aoe_message("TARGET" ${target})
    __aoe_project_property(TARGETS APPEND ${target})

    if ("${type}" STREQUAL "executable")
        # 创建为可执行目标
        add_executable(${target} ${target_sources})
        set(target_output_name ${target})
    elseif ("${type}" STREQUAL "library")
        # 创建为库目标
        if (${is_interface})
            # 无源码时，自动创建为接口库目标
            add_library(${target} INTERFACE)
            aoe_message("INTERFACE" TAB MAYBE_EMPTY)
        else ()
            if (DEFINED BUILD_SHARED_LIBS)
                set(default_build_shared ${BUILD_SHARED_LIBS})
            else ()
                set(default_build_shared OFF)
            endif ()

            if (${config_SHARED} OR (${default_build_shared} AND NOT ${config_STATIC}))
                add_library(${target} SHARED ${target_sources})

                if (DEFINED PROJECT_VERSION)
                    set_target_properties(${target} PROPERTIES VERSION ${PROJECT_VERSION} SOVERSION ${PROJECT_VERSION})
                endif ()
            else ()
                add_library(${target} STATIC ${target_sources})
            endif ()
        endif ()

        # 设置库的输出名字，需要加上命名空间（与组名），以防止被其他工程导入使用时，出现同名冲突
        set(target_output_name ${PROJECT_NAME}_${target})
    else ()
        message(FATAL_ERROR "unknown target type (internal error): ${type}")
    endif ()

    # 设置编译结果的输出名称
    if (NOT ${is_interface})
        if (DEFINED config_ALIAS)
            set(target_output_name ${config_ALIAS})
        endif ()

        aoe_message("OUTPUT NAME" TAB ${target_output_name})
        set_target_properties(${target} PROPERTIES OUTPUT_NAME ${target_output_name})
    endif ()

    # -------------------------------------------------------------
    # 设置默认头文件目录，同时，也记录为本目标自己的头文件目录
    if (NOT ${config_NO_DEFAULT_INCLUDES})
        __aoe_current_layout_property(TARGET_INCLUDES GET default_include_patterns)

        foreach (pattern ${default_include_patterns})
            __aoe_configure(default_include ${pattern})
            this_target_include_directories(${config_PRIVATE_DEFAULT_INCLUDES} "${default_include}")
        endforeach ()
    endif ()

    # -------------------------------------------------------------
    # 设置依赖的其他本工程内的库目标
    aoe_message("DEPEND"         TAB ${config_DEPEND})
    aoe_message("PRIVATE DEPEND" TAB ${config_PRIVATE_DEPEND})
    aoe_message("FORCE DEPEND"   TAB ${config_FORCE_DEPEND})
    aoe_message("BUILD DEPEND"   TAB ${config_BUILD_DEPEND})

    # 记录库依赖，将在 install 时导出
    __aoe_target_property(${target} DEPENDENCIES SET ${config_DEPEND} ${config_PRIVATE_DEPEND} ${config_FORCE_DEPEND})

    # 设置编译顺序的依赖
    set(build_depends ${config_DEPEND} ${config_PRIVATE_DEPEND} ${config_FORCE_DEPEND} ${config_BUILD_DEPEND})

    if (NOT "${build_depends}" STREQUAL "")
        add_dependencies(${target} ${build_depends})
    endif ()

    # 设置链接库
    this_target_link_directories(OFF "${config_DEPEND}")
    this_target_link_directories(ON  "${config_PRIVATE_DEPEND}")

    # 处理强制链接
    list(REMOVE_DUPLICATES config_FORCE_DEPEND)

    if ("${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang")
        foreach (depend ${config_FORCE_DEPEND})
            this_target_link_directories(ON "-Wl,-force-load,${depend}")
        endforeach ()
    elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
        if (NOT "${config_FORCE_DEPEND}" STREQUAL "")
            this_target_link_directories(ON "-Wl,--whole-archive;${config_FORCE_DEPEND};-Wl,--no-whole-archive")
        endif ()
    else ()
        message(FATAL_ERROR "CANNOT use FORCE_DEPEND with unsupported compiler ${CMAKE_CXX_COMPILER_ID} !")
    endif ()

    # -------------------------------------------------------------
    # 导入第三方库
    aoe_message("IMPORT"               TAB ${config_IMPORT})
    aoe_message("PRIVATE IMPORT"       TAB ${config_PRIVATE_IMPORT})

    aoe_find_packages(${config_IMPORT}         AS imported         COMPONENTS ${config_COMPONENTS})
    aoe_find_packages(${config_PRIVATE_IMPORT} AS private_imported COMPONENTS ${config_COMPONENTS})

    __aoe_target_property(${target} THIRD_PARTIES            SET ${config_IMPORT} ${config_PRIVATE_IMPORT})
    __aoe_target_property(${target} THIRD_PARTIES_COMPONENTS SET ${config_COMPONENTS})

    this_target_include_directories(OFF "${imported_INCLUDE_DIRS}")
    this_target_include_directories(ON  "${private_imported_INCLUDE_DIRS}")

    this_target_link_directories(OFF "${imported_LIBRARIES}")
    this_target_link_directories(ON  "${private_imported_LIBRARIES}")

    # -------------------------------------------------------------
    # 设置给定的头文件目录与库目录
    this_target_include_directories(OFF "${config_INCLUDES}")
    this_target_include_directories(ON  "${config_PRIVATE_INCLUDES}")

    this_target_link_directories(OFF "${config_LIBARIES}")
    this_target_link_directories(ON  "${config_PRIVATE_LIBRARIES}")

    # -------------------------------------------------------------
    # 配置 install
    if (NOT ${config_NO_INSTALL})
        aoe_install_target(${target})
    else ()
        aoe_message("NO_INSTALL" TAG MAYBE_EMPTY)
    endif ()

    # END
endmacro()
