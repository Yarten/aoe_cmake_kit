# --------------------------------------------------------------------------------------------------------------
# 选择指定的安装布局。
# Select the specified install layout.
# --------------------------------------------------------------------------------------------------------------
# aoe_use_install_layout(name)
#
# name: 指定的布局名称。
#       Name of the specified layout.
# --------------------------------------------------------------------------------------------------------------

function(aoe_use_install_layout name)
    aoe_disable_extra_params()

    __aoe_project_property(ALL_INSTALL_LAYOUTS CHECK ${name} CHECK_STATUS is_valid)

    if (NOT ${is_valid})
        __aoe_project_property(ALL_INSTALL_LAYOUTS GET all_install_layouts)
        message(FATAL_ERROR "Undefined install layout [${name}]! (only [${all_install_layouts}] available)")
    endif ()

    __aoe_project_property(INSTALL_LAYOUT SET ${name})
endfunction()
