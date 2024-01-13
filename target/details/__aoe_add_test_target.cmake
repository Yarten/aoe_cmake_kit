# --------------------------------------------------------------------------------------------------------------
# A partial implementation of aoe_add_test() and aoe_add_executable_test() functions.
# --------------------------------------------------------------------------------------------------------------

macro(__aoe_add_test_target)
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

    __aoe_project_property(TEST_TARGETS APPEND ${target})
    __aoe_add_target("executable")
endmacro()
