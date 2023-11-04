# --------------------------------------------------------------------------------------------------------------
# 选择指定的 aeo target 文件布局。
# Select the specified aoe target layout.
# --------------------------------------------------------------------------------------------------------------
# aoe_use_target_layout(name)
#
# name: 指定的布局名称。
#       Name of the specified layout.
# --------------------------------------------------------------------------------------------------------------

function(aoe_use_target_layout name)
    aoe_disable_extra_params()

    __aoe_project_property(ALL_TARGET_LAYOUTS CHECK ${name} CHECK_STATUS is_valid)

    if (NOT ${is_valid})
        __aoe_project_property(ALL_TARGET_LAYOUTS GET all_target_layouts)
        message(FATAL_ERROR "Undefined target layout ${name}! (only ${all_target_layouts} available)")
    endif ()

    __aoe_project_property(TARGET_LAYOUT SET ${name})
endfunction()
