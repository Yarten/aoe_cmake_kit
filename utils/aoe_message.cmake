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
    # 解析参数，多余的参数将被认为是输出内容
    cmake_parse_arguments(config "TAB;MAYBE_EMPTY" "" "" ${ARGN})

    # 除非有 MAYBE_EMPTY 参数设置，若传入的消息为空，则不打印。
    if (${config_MAYBE_EMPTY} OR NOT "${config_UNPARSED_ARGUMENTS}" STREQUAL "")
        set(enable_print ON)
    else()
        set(enable_print OFF)
    endif ()

    # 打印信息
    if (${enable_print})
        # 设置打印头
        if (${config_TAB})
            set(head "  ++")
        else()
            set(head "--")
        endif()

        message("${head} [${tag}] ${config_UNPARSED_ARGUMENTS}")
    endif ()
endfunction()
