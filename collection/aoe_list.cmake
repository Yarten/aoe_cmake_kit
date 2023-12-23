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
    # Parse parameters
    cmake_parse_arguments(__aoe_list_config "UNSET" "LENGTH" "APPEND;GET" ${ARGN})
    aoe_disable_unknown_params(__aoe_list_config)
    aoe_expect_one_of_params(__aoe_list_config UNSET LENGTH APPEND GET)

    # ---------------------------------------------------
    # Check if the variable to record the length of the list exists, if not, initialize it to 0.

    if (NOT DEFINED __AOE_LIST_LENGTH_${name})
        set(__AOE_LIST_LENGTH_${name} 0)
    endif ()

    # ---------------------------------------------------
    # Get the length of the list

    if (DEFINED __aoe_list_config_LENGTH)
        set(${__aoe_list_config_LENGTH} ${__AOE_LIST_LENGTH_${name}})
    endif ()

    # ---------------------------------------------------
    # Do element appending

    if (DEFINED __aoe_list_config_APPEND)
        # Record the new element to the new location
        set(__AOE_LIST_AT_${__AOE_LIST_LENGTH_${name}}_OF_${name} ${__aoe_list_config_APPEND})

        # Increasing number of elements
        math(EXPR __AOE_LIST_LENGTH_${name} "${__AOE_LIST_LENGTH_${name}} + 1")
    endif ()

    # ---------------------------------------------------
    # Do element accessing.
    # An error will be raised if it is out of bound, or mismatches for structure binding

    if (DEFINED __aoe_list_config_GET)
        # Take the first argument given, which is the index of the queried element
        list(GET __aoe_list_config_GET 0 __aoe_list_config_index)

        # Check if this parameter is a reasonable index value
        if (NOT ${__aoe_list_config_index} MATCHES "^[0-9]+$")
            message(FATAL_ERROR "aoe_list(GET) error: The given index '${__aoe_list_config_index}' is NOT a number !")
        endif ()

        # Check if the index is out of bound
        if (${__aoe_list_config_index} LESS 0 OR  ${__aoe_list_config_index} GREATER_EQUAL ${__AOE_LIST_LENGTH_${name}})
            message(FATAL_ERROR
                "aoe_list(GET) error: The given index '${__aoe_list_config_index}' is OUT OF BOUND ! "
                "[0..${__AOE_LIST_LENGTH_${name}}]")
        endif ()

        # Get the number of output parameters used to bind tuple content
        list(LENGTH __aoe_list_config_GET __aoe_list_config_GET_result_length)
        math(EXPR __aoe_list_config_GET_result_length "${__aoe_list_config_GET_result_length} - 1")

        # Get the size of the tuple at the specified index
        list(LENGTH __AOE_LIST_AT_${__aoe_list_config_index}_OF_${name} __aoe_list_config_GET_tuple_length)

        # Check if the given parameters count matches the size of the tuple
        if (NOT ${__aoe_list_config_GET_result_length} EQUAL ${__aoe_list_config_GET_tuple_length})
            message(FATAL_ERROR
                "aoe_list(GET) error: Fail to bind tuple, expect ${__aoe_list_config_GET_tuple_length} output variables.")
        endif ()

        # Iterate through each field of the tuple and output them one by one
        foreach (i RANGE 1 ${__aoe_list_config_GET_tuple_length})
            # Specify the corresponding output parameter
            list(GET __aoe_list_config_GET ${i} __aoe_list_output_element)

            # Specify the element in the tuple
            math(EXPR i "${i} - 1")
            list(GET __AOE_LIST_AT_${__aoe_list_config_index}_OF_${name} ${i} __aoe_list_tuple_element)

            # Output the element
            set(${__aoe_list_output_element} ${__aoe_list_tuple_element})
            unset(__aoe_list_tuple_element)
            unset(__aoe_list_output_element)
        endforeach ()
    endif ()

    # ---------------------------------------------------
    # Do list clearing

    if (${__aoe_list_config_UNSET})
        foreach (i RANGE 0 ${__AOE_LIST_LENGTH_${name}})
            unset(__AOE_LIST_AT_${i}_OF_${name})
        endforeach ()

        unset(__AOE_LIST_LENGTH_${name})
    endif ()
endmacro()
