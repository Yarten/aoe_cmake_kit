# --------------------------------------------------------------------------------------------------------------
# 将本工程当做 ros package 来引入 ros 支持
# Introducing ros support by treating this project as a ros package.
# --------------------------------------------------------------------------------------------------------------
# __aoe_use_ros_as_is(target version ...)
#
# target: 接口目标的名称，其将承接需要依赖的其他 ros package 的头文件目录、库列表等信息。
#         Name of the interface target, which holds dependencies info of the given other ros packages.
#
# version: ros's version number (1 or 2)
#
# ...: 需要依赖的其他 ros packages，已经默认依赖了一些基础的包。
#      Other ros packages that need to be relied on, some basic packages will be relied on by default.
# --------------------------------------------------------------------------------------------------------------

macro(__aoe_use_ros_as_is target version)
    # -------------------------------------------------------------
    # 用户给定的依赖列表
    set(__aoe_use_ros_depends ${ARGN})

    # ros 的基础依赖
    set(__aoe_use_ros_1_basic_depends
        roscpp message_generation message_runtime)

    set(__aoe_use_ros_2_basic_depends
        ament_cmake ament_index_cpp rclcpp rclcpp_action rosidl_default_generators)

    # 从用户给定的依赖中，删除不同 ros 版本的基础依赖后，再根据当前给定的版本，重新加回来
    list(REMOVE_ITEM       __aoe_use_ros_depends ${__aoe_use_ros_1_basic_depends} ${__aoe_use_ros_2_basic_depends})
    list(REMOVE_DUPLICATES __aoe_use_ros_depends)
    list(APPEND            __aoe_use_ros_depends ${__aoe_use_ros_${version}_basic_depends})

    # 创建虚拟目标
    add_library(${target} INTERFACE)

    # -------------------------------------------------------------
    ## 处理 ros1 的过程
    macro(ros1)
        find_package(catkin REQUIRED COMPONENTS ${__aoe_use_ros_depends})

        __aoe_get_ros_1_comm_files(__aoe_use_ros_message_files msg)
        if (NOT "${__aoe_use_ros_message_files}" STREQUAL "")
            add_message_files(FILES ${__aoe_use_ros_message_files})
        endif ()

        __aoe_get_ros_1_comm_files(__aoe_use_ros_service_files srv)
        if (NOT "${__aoe_use_ros_service_files}" STREQUAL "")
            add_service_files(FILES ${__aoe_use_ros_service_files})
        endif ()

        __aoe_get_ros_1_comm_files(__aoe_use_ros_action_files action)
        if (NOT "${__aoe_use_ros_action_files}" STREQUAL "")
            add_action_files(FILES ${__aoe_use_ros_action_files})
        endif ()

        if (NOT "${__aoe_use_ros_message_files}${__aoe_use_ros_service_files}${__aoe_use_ros_action_files}" STREQUAL "")
            generate_messages(DEPENDENCIES ${__aoe_use_ros_depends})
        endif ()

        catkin_package(
            # INCLUDE_DIRS
            # LIBRARIES
            # CATKIN_DEPENDS
            # DEPENDS
        )

        target_include_directories(${target} INTERFACE ${catkin_INCLUDE_DIRS})
        target_link_libraries(${target} INTERFACE ${catkin_LIBRARIES})
    endmacro()

    # -------------------------------------------------------------
    ## 处理 ros2 的过程
    macro(ros2)
        foreach(i ${__aoe_use_ros_depends})
            find_package(${i} REQUIRED)
        endforeach()

        ament_target_dependencies(${target} INTERFACE ${__aoe_use_ros_depends})

        __aoe_get_ros_2_comm_files(__aoe_use_ros_message_files msg)
        __aoe_get_ros_2_comm_files(__aoe_use_ros_service_files srv)
        __aoe_get_ros_2_comm_files(__aoe_use_ros_action_files  action)

        if (NOT "${__aoe_use_ros_message_files}${__aoe_use_ros_service_files}${__aoe_use_ros_action_files}" STREQUAL "")
            rosidl_generate_interfaces(${PROJECT_NAME}
                ${__aoe_use_ros_message_files} ${__aoe_use_ros_service_files} ${__aoe_use_ros_action_files})
            rosidl_target_interfaces(${target} ${PROJECT_NAME} "rosidl_typesupport_cpp")
        endif ()

        ament_package() # FIXME: 也许得放在 final 中
    endmacro()

    # -------------------------------------------------------------
    # 根据 ros 的不同版本，调用相应过程进行处理
    if (${version} EQUAL 1)
        ros1()
    elseif (${version} EQUAL 2)
        ros2()
    else ()
        message(FATAL_ERROR "Unsupported ros version: ${version} !")
    endif ()

    # 删除临时变量
    unset(__aoe_use_ros_message_files)
    unset(__aoe_use_ros_service_files)
    unset(__aoe_use_ros_action_files)
endmacro()

# --------------------------------------------------------------------------------------------------------------
# 根据 ros 1 的规则，获取指定类型的 ros 通信定义文件
# --------------------------------------------------------------------------------------------------------------

function(__aoe_get_ros_1_comm_files result type)
    file(GLOB files ${PROJECT_SOURCE_DIR}/${type}/*.${type})

    foreach (file ${files})
        get_filename_component(file ${file} NAME)
        list(APPEND ${result} ${file})
    endforeach ()

    aoe_output(${result})
endfunction()

# --------------------------------------------------------------------------------------------------------------
# 根据 ros 2 的规则，获取指定类型的 ros 通信定义文件
# --------------------------------------------------------------------------------------------------------------

function(__aoe_get_ros_2_comm_files result type)
    file(GLOB files ${PROJECT_SOURCE_DIR}/${type}/*.${type})

    foreach (file ${files})
        get_filename_component(file ${file} NAME)
        list(APPEND ${result} ${type}/${file})
    endforeach ()

    aoe_output(${result})
endfunction()
