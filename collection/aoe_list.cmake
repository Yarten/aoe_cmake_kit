# --------------------------------------------------------------------------------------------------------------
# 定义并操作一个 tuple 的列表变量。
# Define and operate a tuple list variable.
# --------------------------------------------------------------------------------------------------------------
# aoe_list(name
#   < LENGTH  <result>
#   | APPEND  <value> ...
#   | GET     <index> <result> ...
#   | UNSET
#   >
# )
#
# name: 该 tuple 列表变量的名称。
#       Name of the tuple list variable.
# --------------------------------------------------------------------------------------------------------------
# LENGTH: 获取列表中的元素个数。
#         Get the number of elements in the list.
#
# APPEND: 追加一个新的 tuple 元素。
#         Append a new tuple element to the list.
#
# GET: 获取指定索引（从 0 开始）的 tuple 元素，需要给定多个输出变量，结构化绑定这个 tuple 的内容。
#      Get a tuple element at a specified index (starting at 0) ,
#      several result variables are needed for structured binding to this tuple.
#
# UNSET: 删除这个 tuple 列表变量。
#        Delete this tuple list variable.
# --------------------------------------------------------------------------------------------------------------

macro(aoe_list name)
    # 解析参数
    cmake_parse_arguments(__aoe_list_config "UNSET" "LENGTH" "APPEND;GET" ${ARGN})
    aoe_disable_unknown_params(__aoe_list_config)
    aoe_expect_one_of_params(__aoe_list_config UNSET LENGTH APPEND GET)

    # ---------------------------------------------------
    # 检查记录该 list 的长度的变量是否存在，若不存在，将初始化其为 0

    if (NOT DEFINED __AOE_LIST_LENGTH_${name})
        set(__AOE_LIST_LENGTH_${name} 0)
    endif ()

    # ---------------------------------------------------
    # 获取列表长度的获取

    if (DEFINED __aoe_list_config_LENGTH)
        set(${__aoe_list_config_LENGTH} ${__AOE_LIST_LENGTH_${name}})
    endif ()

    # ---------------------------------------------------
    # 处理元素的追加

    if (DEFINED __aoe_list_config_APPEND)
        # 将新元素的内容记录到新的位置上
        set(__AOE_LIST_AT_${__AOE_LIST_LENGTH_${name}}_OF_${name} ${__aoe_list_config_APPEND})

        # 元素数量递增 1
        math(EXPR __AOE_LIST_LENGTH_${name} "${__AOE_LIST_LENGTH_${name}} + 1")
    endif ()

    # ---------------------------------------------------
    # 处理元素的访问。如果越界、或者结构绑定不对应，将报错。

    if (DEFINED __aoe_list_config_GET)
        # 取出给定的第一个参数，他是需要获取的元素的索引
        list(GET __aoe_list_config_GET 0 __aoe_list_config_index)

        # 检查该参数是否为合理的索引值
        if (NOT ${__aoe_list_config_index} MATCHES "^[0-9]+$")
            message(FATAL_ERROR "aoe_list(GET) error: The given index '${__aoe_list_config_index}' is NOT a number !")
        endif ()

        # 检查索引是否越界
        if (${__aoe_list_config_index} LESS 0 OR  ${__aoe_list_config_index} GREATER_EQUAL ${__AOE_LIST_LENGTH_${name}})
            message(FATAL_ERROR
                "aoe_list(GET) error: The given index '${__aoe_list_config_index}' is OUT OF BOUND ! "
                "[0..${__AOE_LIST_LENGTH_${name}}]")
        endif ()

        # 获取用于绑定 tuple 内容的输出参数的数量
        list(LENGTH __aoe_list_config_GET __aoe_list_config_GET_result_length)
        math(EXPR __aoe_list_config_GET_result_length "${__aoe_list_config_GET_result_length} - 1")

        # 获取指定索引处的 tuple 的大小
        list(LENGTH __AOE_LIST_AT_${__aoe_list_config_index}_OF_${name} __aoe_list_config_GET_tuple_length)

        # 若给定的输出参数与存放的 tuple 大小不一致，则报错
        if (NOT ${__aoe_list_config_GET_result_length} EQUAL ${__aoe_list_config_GET_tuple_length})
            message(FATAL_ERROR
                "aoe_list(GET) error: Fail to bind tuple, expect ${__aoe_list_config_GET_tuple_length} output variables.")
        endif ()

        # 遍历该 tuple 每一个字段，并逐一输出
        foreach (i RANGE 1 ${__aoe_list_config_GET_tuple_length})
            # 指定对应的输出参数
            list(GET __aoe_list_config_GET ${i} __aoe_list_output_element)

            # 指定 tuple 中的元素
            math(EXPR i "${i} - 1")
            list(GET __AOE_LIST_AT_${__aoe_list_config_index}_OF_${name} ${i} __aoe_list_tuple_element)

            # 设置输出
            set(${__aoe_list_output_element} ${__aoe_list_tuple_element})
            unset(__aoe_list_tuple_element)
            unset(__aoe_list_output_element)
        endforeach ()
    endif ()

    # ---------------------------------------------------
    # 处理整个列表变量的删除

    if (${__aoe_list_config_UNSET})
        foreach (i RANGE 0 ${__AOE_LIST_LENGTH_${name}})
            unset(__AOE_LIST_AT_${i}_OF_${name})
        endforeach ()

        unset(__AOE_LIST_LENGTH_${name})
    endif ()
endmacro()
