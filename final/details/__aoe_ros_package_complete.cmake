# --------------------------------------------------------------------------------------------------------------
# Do some closing works of ros
# --------------------------------------------------------------------------------------------------------------

function(__aoe_ros_package_complete)
    __aoe_project_property(ROS_VERSION GET ros_version)

    if ("${ros_version}" STREQUAL "2")
        ament_package()
    endif ()
endfunction()
