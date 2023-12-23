# --------------------------------------------------------------------------------------------------------------
# 将一个给定目录初始化为 ros 工作空间，并把添加为本工程的子目录
# Initialize a given directory as a ros workspace and add it as a subdirectory of this project.
# --------------------------------------------------------------------------------------------------------------
# __aoe_use_ros_at(target path version)
#
# target: 接口目标的名称，其将设置由 ros 工作空间内的包生成的通信头文件。
#         Name of the interface target,
#         which holds communication headers generated by packages in the ros workspace.
#
# path: 初始化为 ros 工作空间的目录。
#       Directory initialized to the ros workspace.
#
# version: ros's version number (1 only)
# --------------------------------------------------------------------------------------------------------------

macro(__aoe_use_ros_at target path version)
    # -------------------------------------------------------------
    # Cache the BUILD_SHARED_LIBS option, because ros 1 may change it.
    set(__aoe_use_ros_at_BUILD_SHARED_LIBS ${BUILD_SHARED_LIBS})

    # Get script directory
    __aoe_common_property(SCRIPT_DIRECTORY_PATH GET __aoe_use_ros_script_root)

    # Create an interface target to hold the communication headers
    add_library(${target} INTERFACE)

    # -------------------------------------------------------------
    macro(ros1)
        # Perform ros 1 workspace initialization for the specified directory
        # and obtains the ros version name
        aoe_execute_process("${__aoe_use_ros_script_root}/init_ros_1_workspace.bash" "${path}"
            RESULT __aoe_use_ros_version_name
        )

        # Set the catkin generation directory
        set(CATKIN_DEVEL_PREFIX "${CMAKE_BINARY_DIR}/.aoe/${PROJECT_NAME}/ros1/devel")

        # Record the generated header file directory into the interface target
        target_include_directories(${target} INTERFACE "${CATKIN_DEVEL_PREFIX}/include")

        # Import ros 1 environment
        list(APPEND CMAKE_PREFIX_PATH "/opt/ros/${__aoe_use_ros_version_name}")
    endmacro()

    # -------------------------------------------------------------
    # Import ros workspace
    if (${version} EQUAL 1)
        ros1()
    else ()
        message(FATAL_ERROR "Unsupported ros version: ${version} !")
    endif ()

    add_subdirectory("${path}")

    # Restore the BUILD_SHARED_LIBS variable
    set(BUILD_SHARED_LIBS ${__aoe_use_ros_at_BUILD_SHARED_LIBS})
endmacro()
