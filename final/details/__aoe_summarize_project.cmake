# --------------------------------------------------------------------------------------------------------------
# 若指定了环境变量 AOE_CMAKE_KIT_SUMMARY ，将输出本工程的所有信息，到该变量指定的文件中。
# 会根据路径的后缀，决定输出的格式。
# If the environment variable AOE_CMAKE_KIT_SUMMARY is specified,
# all the information of this project will be output to the file specified by this variable.
# The format of the output is determined by the suffix of the path.
#
# Support style: xml, json, yaml/yml, toml
# --------------------------------------------------------------------------------------------------------------

function(__aoe_summarize_project)
    if (NOT DEFINED ENV{AOE_CMAKE_KIT_SUMMARY})
        return()
    endif ()

    # Take the output summary file path from the environment variable,
    # user can use @PROJECT_NAME@ to distinguish the output of different projects.
    __aoe_configure(summary_file_path "$ENV{AOE_CMAKE_KIT_SUMMARY}")

    # Determine the output format based on the suffix of the path,
    # the 'style' variable will be used in all later write marcos.
    get_filename_component(style "${summary_file_path}" LAST_EXT)

    if ("${style}" STREQUAL ".xml")
        set(style "xml")
    elseif ("${style}" STREQUAL ".json")
        set(style "json")
    elseif ("${style}" STREQUAL ".yaml" OR "${style}" STREQUAL ".yml")
        set(style "yaml")
    elseif ("${style}" STREQUAL ".toml")
        set(style "toml")
    else ()
        message(FATAL_ERROR "Unknown style for aoe cmake kit summary: [${summary_file_path}]")
    endif ()

    # Prepare a variable for setting the content of the output,
    # it will be used in all later write macros.
    set(out_str "")

    # Write the begin of the summary
    __aoe_write_summary_begin()

    # Write some important cmake variables
    __aoe_summarize_cmake_variables("PROJECT_NAME;PROJECT_VERSION")

    # Write the aoe global properties defined in this project
    __aoe_summarize_global_properties("COMMON")
    __aoe_summarize_global_properties("PROJECT")

    # Write the aoe instances' properties defined in this project
    __aoe_project_property(TARGETS GET target_instances)
    __aoe_summarize_instance_properties("TARGET" "${target_instances}" "")

    __aoe_project_property(PROTOBUF_TARGETS GET protobuf_target_instances)
    __aoe_summarize_instance_properties("PROTOBUF" "${protobuf_target_instances}" "")

    __aoe_project_property(ALL_INSTALL_LAYOUTS GET install_layout_instances)
    __aoe_project_property(ALL_TARGET_LAYOUTS  GET target_layout_instances)
    set(layout_instances "${install_layout_instances};${target_layout_instances}")
    list(REMOVE_DUPLICATES layout_instances)

    __aoe_summarize_instance_properties("LAYOUT" "${layout_instances}" "")

    # Write the end of the summary
    __aoe_write_summary_end()

    # Write the summary content to the specified file
    file(WRITE "${summary_file_path}" "${out_str}")

    # Unset the variables that may be propagated to the parent scope
    # because of the use of some internal marcos.
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
            # The PROJECT properties have been bind to ${PROJECT_NAME} instance,
            # that's why we're specializing here.
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
    # Get aoe properties of the given ${type}
    __aoe_all_properties(properties ${type})

    __aoe_write_summary_key_begin(1 ${type} OFF)

    foreach (instance ${instances})
        __aoe_write_summary_key_begin(2 ${instance} OFF)

        # Write the aoe properties
        foreach (property ${properties})
            __aoe_write_summary_key_begin(3 ${property} ON)

            unset(values)
            __aoe_property(${type} ${property} INSTANCE ${PROJECT_NAME}-${instance} GET values)
            __aoe_write_summary_values(4 "${values}")

            __aoe_write_summary_key_end(3 ${property} ON)
        endforeach ()

        # Write the cmake properties (only TARGET properties are supported)
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
    set(str "")

    if ("${style}" STREQUAL "xml")
        set(str "<aoe-cmake-kit-summary>")
    elseif ("${style}" STREQUAL "json")
        set(str "{")
    elseif ("${style}" STREQUAL "yaml")
        set(str "aoe-cmake-kit-summary:")
    endif ()

    string(APPEND out_str "${str}")

    # Use a stack to store the keys path formed along the levels
    set(keys "")
endmacro()


macro(__aoe_write_summary_end)
    set(str "")

    if ("${style}" STREQUAL "xml")
        set(str "</aoe-cmake-kit-summary>")
    elseif ("${style}" STREQUAL "json")
        set(str "}")
    endif ()

    string(APPEND out_str "\n${str}\n")
endmacro()


# --------------------------------------------------------------------------------------------------------------
# Write one property element
# --------------------------------------------------------------------------------------------------------------

macro(__aoe_write_summary_key_begin level key is_leaf)
    # Check if this item is an intermediate item in this level, and if so, add a separator
    if (NOT DEFINED is_middle_at_level_${level})
        set(is_middle_at_level_${level} ON)
    else ()
        __aoe_write_summary_separator(OFF)
    endif ()

    # Unset the "is it in the middle" flag of the next level
    # to ensure that the first item of the next level is not preceded by a separator
    math(EXPR next_level "${level} + 1")
    unset(is_middle_at_level_${next_level})

    set(old_keys ${keys})
    list(APPEND keys ${key})
    set(is_tree_like ON)
    set(str "")

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

    elseif ("${style}" STREQUAL "toml")
        set(is_tree_like OFF)

        if (${is_leaf})
            # Ensure all toml values from the same property share one table
            if (NOT DEFINED at_toml_leaf)
                set(at_toml_leaf ON)

                string(APPEND out_str "[")
                set(is_first ON)

                foreach (i ${old_keys})
                    if (${is_first})
                        set(is_first OFF)
                    else ()
                        string(APPEND out_str ".")
                    endif ()
                    string(APPEND out_str "\"${i}\"")
                endforeach ()

                string(APPEND out_str "]\n\n")
            endif ()

            string(APPEND out_str "\"${key}\" = [")
        endif ()

    endif ()

    if (${is_tree_like})
        string(REPEAT "  " ${level} tabs)
        string(APPEND out_str "\n${tabs}${str}")
    endif ()
endmacro()


macro(__aoe_write_summary_key_end level key is_leaf)
    set(old_keys ${keys})
    list(POP_BACK keys)
    set(is_tree_like ON)
    set(str "")

    if ("${style}" STREQUAL "xml")
        set(str "</prop>")

    elseif ("${style}" STREQUAL "json")
        if (${is_leaf})
            set(str "]")
        else ()
            set(str "}")
        endif ()

    elseif ("${style}" STREQUAL "toml")
        set(is_tree_like OFF)
        if (${is_leaf})
            string(APPEND out_str "\n]\n\n")
        else ()
            # Ensure the next property create a new toml table
            unset(at_toml_leaf)
        endif ()

    endif ()

    if (${is_tree_like})
        string(REPEAT "  " ${level} tabs)
        string(APPEND out_str "\n${tabs}${str}")
    endif ()
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
            __aoe_write_summary_separator(ON)
        endif ()

        __aoe_write_summary_value(${level} ${value})
    endforeach ()
endmacro()


macro(__aoe_write_summary_value level value)
    set(is_tree_like ON)
    set(str "")

    if ("${style}" STREQUAL "xml")
        set(str "<value>${value}</value>")

    elseif ("${style}" STREQUAL "json")
        set(str "\"${value}\"")

    elseif ("${style}" STREQUAL "yaml")
        set(str "- ${value}")

    elseif ("${style}" STREQUAL "toml")
        set(is_tree_like OFF)
        string(APPEND out_str "\n  \"${value}\"")

    endif ()

    if (${is_tree_like})
        string(REPEAT "  " ${level} tabs)
        string(APPEND out_str "\n${tabs}${str}")
    endif ()
endmacro()


macro(__aoe_write_summary_separator is_between_values)
    set(str "")

    if ("${style}" STREQUAL "json")
        set(str ",")
    elseif ("${style}" STREQUAL "toml")
        if (${is_between_values})
            set(str ",")
        endif ()
    endif ()

    string(APPEND out_str "${str}")
endmacro()
