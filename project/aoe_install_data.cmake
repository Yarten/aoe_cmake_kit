# --------------------------------------------------------------------------------------------------------------
# 安装给定的文件或文件夹。
# Installs the given files or directories.
# --------------------------------------------------------------------------------------------------------------
# aoe_install_data(destination ...)
#
# destination: 相对于安装根目录的目录。
#              Path relative to the installation root directory.
#
# ...: 被安装的文件或文件夹。
#      Installed files or directories.
# --------------------------------------------------------------------------------------------------------------

function(aoe_install_data destination)
    foreach(path ${ARGN})
        if (IS_DIRECTORY ${path})
            list(APPEND directories ${path})
        elseif(EXISTS ${path})
            list(APPEND files ${path})
        else()
            message(FATAL_ERROR "Custom installed data ${path} is not existed !")
        endif()
    endforeach()

    if (NOT "${directories}" STREQUAL "")
        install(
            DIRECTORY   ${directories}
            DESTINATION ${destination}
        )
    endif()

    if (NOT "${files}" STREQUAL "")
        install(
            FILES       ${files}
            DESTINATION ${destination}
        )
    endif()
endfunction()
