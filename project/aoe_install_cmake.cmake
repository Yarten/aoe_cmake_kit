# --------------------------------------------------------------------------------------------------------------
# 安装 cmake 文件。
# Install cmake files.
# --------------------------------------------------------------------------------------------------------------
# aoe_install_cmake(
#   [TARGET <target>        ]
#   [PREFIX <cmake file> ...]
#   [POST   <cmake file> ...]
# )
# --------------------------------------------------------------------------------------------------------------
# TARGET: 将 cmake 文件安装到指定目标下，而非工程下；若该目标没有被加载，则这些 cmake 文件也不会被加载。
#         Install the cmake files under the specified target, not the project;
#         if the target is not loaded, these cmake files will not be loaded either.
#
# PREFIX: 安装将在目标或工程加载前执行的 cmake 文件。
#         Install the cmake files that will be executed before the target or project is loaded.
#
# POST: 安装将在目标或工程加载后执行的 cmake 文件。
#       Install the cmake files that will be executed after the target or project is loaded.
# --------------------------------------------------------------------------------------------------------------

function(aoe_install_cmake)
    cmake_parse_arguments(config "" "TARGET" "PREFIX;POST" ${ARGN})
    aoe_disable_unknown_params(config)

    # Checks if the given file are *.cmake files
    foreach(path ${config_PREFIX} ${config_POST})
        get_filename_component(file_ext ${path} LAST_EXT)

        if (NOT "${file_ext}" STREQUAL ".cmake")
            message(FATAL_ERROR "${path} is not a *.cmake file !")
        endif ()
    endforeach()

    # Get the cmake files install root
    __aoe_load_current_install_layout(_ _ _ cmake _)

    if (DEFINED config_TARGET)
        set(install_root "${cmake}/extra/${config_TARGET}")
    else()
        set(install_root "${cmake}/extra")
    endif()

    # Install the cmake files that will be executed before this project is imported
    install(
        FILES       ${config_PREFIX}
        DESTINATION "${install_root}/prefix"
        COMPONENT   Devel
    )

    # Install the cmake files that will be executed after this project is imported
    install(
        FILES       ${config_POST}
        DESTINATION "${install_root}/post"
        COMPONENT   Devel
    )
endfunction()
