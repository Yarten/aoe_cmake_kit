# --------------------------------------------------------------------------------------------------------------
# 先尝试 find_package，后采用 pkg_config，查找指定的一个第三方库，并将头文件目录、库文件路径添加到对应变量中。
# Try find_package, then pkg_config, to find one of the specified third-party libraries,
# and add the header file directories and library files paths to the corresponding variables.
# --------------------------------------------------------------------------------------------------------------
# aoe_find_package(name
#   [COMPONENTS <component> ...]
# )
# --------------------------------------------------------------------------------------------------------------
# COMPONENTS: 需要被导入的该第三方库的组件。
#             The components of this third-party library that needs to be imported.
# --------------------------------------------------------------------------------------------------------------

function(aoe_find_package name)
    # 解析参数
    cmake_parse_arguments(config "" "" "COMPONENTS" ${ARGN})
    aoe_disable_unknown_params(config)

    if ("${components}" STREQUAL "")
        find_package(${name} QUIET)
    else()
        find_package(${name} COMPONENTS ${components} QUIET)
    endif ()

    if (NOT ${${name}_FOUND})
        # 若 find_package 找不到时，使用 pkg-config 来查找。
        find_package(PkgConfig REQUIRED)
        pkg_check_modules(${name} REQUIRED ${name}) # ${components}
    endif ()

    # 规整化该库导出的变量
    __aoe_standardize_includes_and_libraries(${name} "${components}")
endfunction()

# --------------------------------------------------------------------------------------------------------------
# 将指定第三方库的头文件目录变量与库文件变量整理得更加规范。
# --------------------------------------------------------------------------------------------------------------

macro(__aoe_standardize_includes_and_libraries name components)
    __aoe_clear_includes_and_libraries(__${name})

    string(TOUPPER ${name} upper_name)

    list(APPEND __${name}_LIBRARIES
        ${${name}_LIBRARIES}       ${${name}_LIBRARY}
        ${${upper_name}_LIBRARIES} ${${upper_name}_LIBRARY})
    list(APPEND __${name}_INCLUDE_DIRS
        ${${name}_INCLUDE_DIRS}       ${${name}_INCLUDE_DIR}
        ${${upper_name}_INCLUDE_DIRS} ${${upper_name}_INCLUDE_DIR})

    if ("${__${name}_LIBRARIES}" STREQUAL "")
        foreach(com ${components})
            list(APPEND __${name}_LIBRARIES "${name}::${com}")
        endforeach()
    endif ()

    list(REMOVE_DUPLICATES __${name}_LIBRARIES)
    list(REMOVE_DUPLICATES __${name}_INCLUDE_DIRS)

    aoe_output(${name}_LIBRARIES ${__${name}_LIBRARIES})
    aoe_output(${name}_LIBRARY   ${__${name}_LIBRARIES})

    aoe_output(${name}_INCLUDE_DIRS ${__${name}_INCLUDE_DIRS})
    aoe_output(${name}_INCLUDE_DIR  ${__${name}_INCLUDE_DIRS})
endmacro()

# --------------------------------------------------------------------------------------------------------------
# 清空指定第三方库的头文件目录变量与库文件变量
# --------------------------------------------------------------------------------------------------------------

macro(__aoe_clear_includes_and_libraries name)
    unset(${name}_LIBRARIES)
    unset(${name}_LIBRARY)
    unset(${name}_INCLUDE_DIRS)
    unset(${name}_INCLUDE_DIR)
endmacro()
