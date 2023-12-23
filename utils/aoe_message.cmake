# --------------------------------------------------------------------------------------------------------------
# 打印带 tag 信息的消息。
# Print message with a tag.
# --------------------------------------------------------------------------------------------------------------
# aoe_message(tag ...
#   [TAB]
#   [MAYBE_EMPTY]
# )
#
# tag: 信息的标签。
#      The tag of message.
#
# ...: 需要打印的信息。
#      The message to be printed.
# --------------------------------------------------------------------------------------------------------------
# TAB: 是否缩进。
#      Idents if set.
#
#
# MAYBE_EMPTY: 允许消息为空时打印。
#              Allow printing when the message is empty.
# --------------------------------------------------------------------------------------------------------------

function(aoe_message tag)
    cmake_parse_arguments(config "TAB;MAYBE_EMPTY" "" "" ${ARGN})

    # If the content is empty and MAYBE_EMPTY parameter isn't set, we print nothing
    if (${config_MAYBE_EMPTY} OR NOT "${config_UNPARSED_ARGUMENTS}" STREQUAL "")
        set(enable_print ON)
    else()
        set(enable_print OFF)
    endif ()

    # Do print
    if (${enable_print})
        if (${config_TAB})
            set(head "  ++")
        else()
            set(head "--")
        endif()

        message("${head} [${tag}] ${config_UNPARSED_ARGUMENTS}")
    endif ()
endfunction()
