# --------------------------------------------------------------------------------------------------------------
# 若指定了环境变量 AOE_CMAKE_KIT_SUMMARY ，将输出本工程的所有信息，到该变量指定的文件中。
# 会根据路径的后缀，决定输出的格式。
# If the environment variable AOE_CMAKE_KIT_SUMMARY is specified,
# all the information of this project will be output to the file specified by this variable.
# The format of the output is determined by the suffix of the path.
#
# Support style: xml, json, yaml/yml
# --------------------------------------------------------------------------------------------------------------

function(__aoe_summarize_project)
    if (NOT DEFINED ENV{AOE_CMAKE_KIT_SUMMARY})
        return()
    endif ()

    # 从环境变量中，取出总结文件的输出路径
    __aoe_configure(summary_file_path "$ENV{AOE_CMAKE_KIT_SUMMARY}")

    # 从该文件的后缀，决定总结输出的格式
    get_filename_component(style "${summary_file_path}" LAST_EXT)

    if ("${style}" STREQUAL ".xml")
        set(style "xml")
    elseif ("${style}" STREQUAL ".json")
        set(style "json")
    elseif ("${style}" STREQUAL ".yaml" OR "${style}" STREQUAL ".yml")
        set(style "yaml")
    else ()
        message(FATAL_ERROR "Unknown style for aoe cmake kit summary: [${summary_file_path}]")
    endif ()

    # 准备输出的字符串，它将在后续的所有总结函数中使用
    set(out_str "")

    # 开始构建总结
    __aoe_write_summary_begin()

    # 写入一些重要的 cmake 变量
    __aoe_summarize_cmake_variables("PROJECT_NAME;PROJECT_VERSION")

    # 写入全局属性
    __aoe_summarize_global_properties("COMMON")
    __aoe_summarize_global_properties("PROJECT")

    # 写入各种实例属性
    __aoe_project_property(TARGETS GET target_instances)
    __aoe_summarize_instance_properties("TARGET" "${target_instances}" "")

    __aoe_project_property(PROTOBUF_TARGETS GET protobuf_target_instances)
    __aoe_summarize_instance_properties("PROTOBUF" "${protobuf_target_instances}" "")

    __aoe_project_property(ALL_INSTALL_LAYOUTS GET install_layout_instances)
    __aoe_project_property(ALL_TARGET_LAYOUTS  GET target_layout_instances)
    set(layout_instances "${install_layout_instances};${target_layout_instances}")
    list(REMOVE_DUPLICATES layout_instances)

    __aoe_summarize_instance_properties("LAYOUT" "${layout_instances}" "")

    # 结束构建总结
    __aoe_write_summary_end()

    # 将总结内容写入到指定文件路径下
    file(WRITE "${summary_file_path}" "${out_str}")

    # 由于总结宏里边，可能会导出 values 变量，我们在此拦截掉它
    unset(values)
endfunction()

# --------------------------------------------------------------------------------------------------------------
# Write all cmake visible variables
# --------------------------------------------------------------------------------------------------------------

macro(__aoe_summarize_cmake_variables variables)
    __aoe_write_summary_key_begin(1 "CMAKE" OFF)

    foreach (var ${variables})
        __aoe_write_summary_key_begin(2 ${var} ON)
        __aoe_write_summary_values(3 "${${var}}")
        __aoe_write_summary_key_end(2 ${var} ON)
    endforeach ()

    __aoe_write_summary_key_end(1 "CMAKE" OFF)
endmacro()


# --------------------------------------------------------------------------------------------------------------
# Write all global aoe properties in this project
# --------------------------------------------------------------------------------------------------------------

macro(__aoe_summarize_global_properties type)
    __aoe_write_summary_key_begin(1 ${type} OFF)

    __aoe_all_properties(properties ${type})
    foreach (property ${properties})
        __aoe_write_summary_key_begin(2 ${property} ON)

        unset(values)

        if ("${type}" STREQUAL "PROJECT")
            # PROJECT 属性比较特殊，虽然是全局属性，但仅在工程内全局
            __aoe_project_property(${property} GET values)
        else ()
            __aoe_property(${type} ${property} GET values)
        endif ()

        __aoe_write_summary_values(3 "${values}")

        __aoe_write_summary_key_end(2 ${property} ON)
    endforeach ()

    __aoe_write_summary_key_end(1 ${type} OFF)
endmacro()


# --------------------------------------------------------------------------------------------------------------
# Write all aoe instances' properties of one type
# --------------------------------------------------------------------------------------------------------------

macro(__aoe_summarize_instance_properties type instances extra_target_properties)
    # aoe 的属性
    __aoe_all_properties(properties ${type})

    __aoe_write_summary_key_begin(1 ${type} OFF)

    foreach (instance ${instances})
        __aoe_write_summary_key_begin(2 ${instance} OFF)

        # 写入 aoe 的属性
        foreach (property ${properties})
            __aoe_write_summary_key_begin(3 ${property} ON)

            unset(values)
            __aoe_property(${type} ${property} INSTANCE ${PROJECT_NAME}-${instance} GET values)
            __aoe_write_summary_values(4 "${values}")

            __aoe_write_summary_key_end(3 ${property} ON)
        endforeach ()

        # 写入 cmake 的属性（目前仅支持 TARGET 的）
        foreach (property ${extra_target_properties})
            __aoe_write_summary_key_begin(3 ${property} ON)

            unset(values)
            get_property(values TARGET ${instance} PROPERTY ${property})
            __aoe_write_summary_values(4 "${values}")

            __aoe_write_summary_key_end(3 ${property} ON)
        endforeach ()

        __aoe_write_summary_key_end(2 ${instance} OFF)
    endforeach ()

    __aoe_write_summary_key_end(1 ${type} OFF)
endmacro()


# --------------------------------------------------------------------------------------------------------------
# Write the root element of the summary
# --------------------------------------------------------------------------------------------------------------

macro(__aoe_write_summary_begin)
    if ("${style}" STREQUAL "xml")
        set(str "<aoe-cmake-kit-summary>")
    elseif ("${style}" STREQUAL "json")
        set(str "{")
    elseif ("${style}" STREQUAL "yaml")
        set(str "aoe-cmake-kit-summary:")
    else ()
        set(str "")
    endif ()

    string(APPEND out_str "${str}")
endmacro()


macro(__aoe_write_summary_end)
    if ("${style}" STREQUAL "xml")
        set(str "</aoe-cmake-kit-summary>")
    elseif ("${style}" STREQUAL "json")
        set(str "}")
    else ()
        set(str "")
    endif ()

    string(APPEND out_str "\n${str}\n")
endmacro()


# --------------------------------------------------------------------------------------------------------------
# Write one property element
# --------------------------------------------------------------------------------------------------------------

macro(__aoe_write_summary_key_begin level key is_leaf)
    # 检查本项是否为本层级的中间项，如果是，则加分隔符
    if (NOT DEFINED is_middle_at_level_${level})
        set(is_middle_at_level_${level} ON)
    else ()
        __aoe_write_summary_separator()
    endif ()

    # 将下一个层级的“是否在中间”的标志重置，确保下一个层级的第一项之前不会加分隔符
    math(EXPR next_level "${level} + 1")
    unset(is_middle_at_level_${next_level})

    if ("${style}" STREQUAL "xml")
        set(str "<prop key=\"${key}\">")
    elseif ("${style}" STREQUAL "json")
        set(str "\"${key}\": ")
        if (${is_leaf})
            set(str "${str}[")
        else ()
            set(str "${str}{")
        endif ()
    elseif ("${style}" STREQUAL "yaml")
        set(str "${key}:")
    else ()
        set(str "")
    endif ()

    string(REPEAT "  " ${level} tabs)
    string(APPEND out_str "\n${tabs}${str}")
endmacro()


macro(__aoe_write_summary_key_end level key is_leaf)
    if ("${style}" STREQUAL "xml")
        set(str "</prop>")
    elseif ("${style}" STREQUAL "json")
        if (${is_leaf})
            set(str "]")
        else ()
            set(str "}")
        endif ()
    else ()
        set(str "")
    endif ()

    string(REPEAT "  " ${level} tabs)
    string(APPEND out_str "\n${tabs}${str}")
endmacro()


# --------------------------------------------------------------------------------------------------------------
# Write values of one property, and separators between values and properties
# --------------------------------------------------------------------------------------------------------------

macro(__aoe_write_summary_values level values)
    set(is_first ON)
    foreach (value ${values})
        if (${is_first})
            set(is_first OFF)
        else ()
            __aoe_write_summary_separator()
        endif ()

        __aoe_write_summary_value(${level} ${value})
    endforeach ()
endmacro()


macro(__aoe_write_summary_value level value)
    if ("${style}" STREQUAL "xml")
        set(str "<value>${value}</value>")
    elseif ("${style}" STREQUAL "json")
        set(str "\"${value}\"")
    elseif ("${style}" STREQUAL "yaml")
        set(str "- ${value}")
    else ()
        set(str "")
    endif ()

    string(REPEAT "  " ${level} tabs)
    string(APPEND out_str "\n${tabs}${str}")
endmacro()


macro(__aoe_write_summary_separator)
    if ("${style}" STREQUAL "json")
        set(str ",")
    else ()
        set(str "")
    endif ()

    string(APPEND out_str "${str}")
endmacro()
