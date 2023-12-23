# --------------------------------------------------------------------------------------------------------------
# 为 aoe project 初始化 aoe cmake kit，需要在 project() 之后使用。
# Initialize the aoe cmake kit for aoe project, which needs to be used after project().
# --------------------------------------------------------------------------------------------------------------
# aoe_project_init(
#   [DEFAULT_BUILD_OPTIONS]
# )
# --------------------------------------------------------------------------------------------------------------
# DEFAULT_BUILD_OPTIONS: 使用默认的编译选项（够用了）。
#                        Use the default build options (for lazy people).
# --------------------------------------------------------------------------------------------------------------

macro(aoe_project_init)
    cmake_parse_arguments(__aoe_project_init_config "DEFAULT_BUILD_OPTIONS" "" "" ${ARGN})
    aoe_disable_unknown_params(__aoe_project_init_config)

    # Ensure the project() is called
    if ("${PROJECT_NAME}" STREQUAL "")
        message(FATAL_ERROR
            "You should call project() first ! Or directly use aoe_project() which calls this macro correctly !"
        )
    endif ()

    # Record the version name as project property
    __aoe_common_property(META_VERSION_NAME GET __aoe_project_init_config_version_name)

    if ("${__aoe_project_init_config_version_name}" STREQUAL "")
        set(__aoe_project_init_config_version_name ${PROJECT_VERSION})
    endif ()

    if ("${__aoe_project_init_config_version_name}" STREQUAL "")
        __aoe_project_property(VERSION_NAME SET "UNDEFINED")
    else ()
        __aoe_project_property(VERSION_NAME SET "${__aoe_project_init_config_version_name}")
    endif ()

    # Predefine some default layouts
    aoe_define_install_layout(default)
    aoe_define_target_layout(default)

    aoe_use_install_layout(default)
    aoe_use_target_layout(default)

    # Set some build options for lazy users (well, that is me)
    if (${__aoe_project_init_config_DEFAULT_BUILD_OPTIONS})
        if(NOT CMAKE_C_STANDARD)
            set(CMAKE_C_STANDARD 99)
        endif()

        if(NOT CMAKE_CXX_STANDARD)
            set(CMAKE_CXX_STANDARD 17)
        endif()

        if(CMAKE_BUILD_TYPE STREQUAL "Debug")
            set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -g -fconcepts -Werror=return-type -Wall -Wno-pedantic -Wno-missing-field-initializers -pthread -fopenmp -fPIC")
        else()
            set(CMAKE_BUILD_TYPE "Release")
            set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O2 -fconcepts -Werror=return-type -Wall -Wno-pedantic -Wno-missing-field-initializers -pthread -fopenmp -fPIC")
        endif()

        message("Build Type: " ${CMAKE_BUILD_TYPE} ${CMAKE_CXX_FLAGS})
    endif ()
endmacro()
