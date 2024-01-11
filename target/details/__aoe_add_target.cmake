# --------------------------------------------------------------------------------------------------------------
# Partial implementation of the aoe_add_xxx() functions.
#
# type: executable | library
# --------------------------------------------------------------------------------------------------------------

macro(__aoe_add_target type)
    # -------------------------------------------------------------
    # Add source files in the module's default source directories
    if (NOT ${config_NO_DEFAULT_SOURCES})
        __aoe_current_layout_property(TARGET_SOURCES GET default_source_patterns)

        foreach (pattern ${default_source_patterns})
            __aoe_configure(default_source ${pattern})
            aoe_source_directories(target_sources ${CMAKE_CURRENT_LIST_DIR}/${default_source})
        endforeach ()
    endif ()

    # -------------------------------------------------------------
    # Add the given source files and source files in the given source directories
    aoe_source_directories(target_sources ${config_SOURCE_DIRECTORIES})
    list(APPEND target_sources ${config_SOURCES})

    # -------------------------------------------------------------
    # If AUX is set, use an empty source file as the unique source file input.
    if (${config_AUX})
        __aoe_common_property(TEMPLATE_DIRECTORY_PATH GET template_directory_path)
        set(target_sources "${template_directory_path}/empty.cpp")
    endif ()

    # -------------------------------------------------------------
    # If no source file is given, it will be in interface mode. (Invalid for executable target)
    if ("${target_sources}" STREQUAL "")
        set(is_interface ON)
    else ()
        set(is_interface OFF)
    endif ()

    # -------------------------------------------------------------
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
                # Can only use it directly if it is a generation expression
                target_include_directories(${target} ${option} "${dir}")
            else ()
                # If the incoming header file directory is in the module's directory,
                # it is recorded as the module's own header file directory and it will be installed.
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

    # -------------------------------------------------------------
    macro(this_target_link_libraries is_private items)
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
    # Create the target
    aoe_message("TARGET" ${target})
    __aoe_project_property(TARGETS APPEND ${target})

    if ("${type}" STREQUAL "executable")
        # .. as executable target
        add_executable(${target} ${target_sources})
        set(target_output_name ${target})
    elseif ("${type}" STREQUAL "library")
        # .. as library target
        if (${is_interface})
            # Automatically created as an interface library target when no source file is available
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

        # Set the library output name in order to prevent the same name conflict when imported by other projects.
        set(target_output_name ${PROJECT_NAME}_${target})
    else ()
        message(FATAL_ERROR "unknown target type (internal error): ${type}")
    endif ()

    # Set the output name
    if (NOT ${is_interface})
        if (DEFINED config_ALIAS)
            set(target_output_name ${config_ALIAS})
        endif ()

        aoe_message("OUTPUT NAME" TAB ${target_output_name})
        set_target_properties(${target} PROPERTIES OUTPUT_NAME ${target_output_name})
    endif ()

    # -------------------------------------------------------------
    # Set the default header file directories and also records them as the target's own.
    if (NOT ${config_NO_DEFAULT_INCLUDES})
        __aoe_current_layout_property(TARGET_INCLUDES GET default_include_patterns)

        foreach (pattern ${default_include_patterns})
            __aoe_configure(default_include ${pattern})
            this_target_include_directories(${config_PRIVATE_DEFAULT_INCLUDES} "${default_include}")
        endforeach ()
    endif ()

    # -------------------------------------------------------------
    # Set dependencies on other library targets within the project
    aoe_message("DEPEND"         TAB ${config_DEPEND})
    aoe_message("PRIVATE DEPEND" TAB ${config_PRIVATE_DEPEND})
    aoe_message("FORCE DEPEND"   TAB ${config_FORCE_DEPEND})
    aoe_message("BUILD DEPEND"   TAB ${config_BUILD_DEPEND})

    # Record library dependencies that will be exported at install time
    __aoe_target_property(${target} DEPENDENCIES SET ${config_DEPEND} ${config_PRIVATE_DEPEND} ${config_FORCE_DEPEND})

    # Set the build order dependencies
    set(build_depends ${config_DEPEND} ${config_PRIVATE_DEPEND} ${config_FORCE_DEPEND} ${config_BUILD_DEPEND})

    if (NOT "${build_depends}" STREQUAL "")
        add_dependencies(${target} ${build_depends})
    endif ()

    # Set the libraries to be linked
    this_target_link_libraries(OFF "${config_DEPEND}")
    this_target_link_libraries(ON  "${config_PRIVATE_DEPEND}")

    # Handle the forced links
    list(REMOVE_DUPLICATES config_FORCE_DEPEND)

    if (NOT "${config_FORCE_DEPEND}" STREQUAL "")
        this_target_link_libraries(ON "-Wl,--whole-archive;${config_FORCE_DEPEND};-Wl,--no-whole-archive")
    endif ()

    # -------------------------------------------------------------
    # Import the third-party libraries
    aoe_message("IMPORT"               TAB ${config_IMPORT})
    aoe_message("PRIVATE IMPORT"       TAB ${config_PRIVATE_IMPORT})

    aoe_find_packages(${config_IMPORT}         AS imported         COMPONENTS ${config_COMPONENTS})
    aoe_find_packages(${config_PRIVATE_IMPORT} AS private_imported COMPONENTS ${config_COMPONENTS})

    __aoe_target_property(${target} THIRD_PARTIES            SET ${config_IMPORT} ${config_PRIVATE_IMPORT})
    __aoe_target_property(${target} THIRD_PARTIES_COMPONENTS SET ${config_COMPONENTS})

    this_target_include_directories(OFF "${imported_INCLUDE_DIRS}")
    this_target_include_directories(ON  "${private_imported_INCLUDE_DIRS}")

    this_target_link_libraries(OFF "${imported_LIBRARIES}")
    this_target_link_libraries(ON  "${private_imported_LIBRARIES}")

    # -------------------------------------------------------------
    # Set the given header file directories and linked libraries
    this_target_include_directories(OFF "${config_INCLUDES}")
    this_target_include_directories(ON  "${config_PRIVATE_INCLUDES}")

    this_target_link_libraries(OFF "${config_LIBARIES}")
    this_target_link_libraries(ON  "${config_PRIVATE_LIBRARIES}")

    # -------------------------------------------------------------
    # Config install() for this target
    if (NOT ${config_NO_INSTALL})
        aoe_install_target(${target})
    else ()
        aoe_message("NO_INSTALL" TAB MAYBE_EMPTY)
    endif ()

    # END
endmacro()
