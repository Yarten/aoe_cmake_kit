# --------------------------------------------------------------------------------------------------------------
# 操作给定的属性（部分实现）。
# Operate on the given property (part of impl).
# --------------------------------------------------------------------------------------------------------------
# __aoe_property(type property
#   [INSTANCE <name>]
#   < SET          [<value> ...]
#   | APPEND       [<value> ...]
#   | REMOVE       [<value> ...]
#   | CHECK        [<value> ...]
#   | CHECK_STATUS <result>
#   | GET          <result>
#   >
# )
#
# type: 属性的类别。
#       Type of the property.
#
# property: 指定的属性。
#           The specified property.
# --------------------------------------------------------------------------------------------------------------
# INSTANCE: 属性所属的某个实例。
#           Instance that the property is belonged to.
#
# SET: 将指定属性设置为指定值。
#      Set the given values to the property.
#
# APPEND: 为指定属性添加新的值。
#         Append the given values to the property.
#
# REMOVE: 删除指定属性中指定的值。
#         Remove the given values from the property.
#
# CHECK: 检查指定属性中是否记录了指定值，将结果写到参数 CHECK_STATUS 指定的变量中。
#        Check if the given values are set to the property, the checking result is output to CHECK_STATUS.
#
# CHECK_STATUS: 存放参数 CHECK 的结果。
#               Take the result of CHECK.
#
# GET: 获取指定属性的值，并写入到指定变量中。
#      Take values of the property.
# --------------------------------------------------------------------------------------------------------------

macro(__aoe_property type property)
    # 解析可选参数
    cmake_parse_arguments(config "" "INSTANCE;CHECK_STATUS;GET" "SET;APPEND;REMOVE;CHECK" ${ARGN})
    aoe_disable_unknown_params(config)

    # 只允许执行一种操作
    aoe_expect_one_of_params(config SET APPEND REMOVE CHECK GET)

    # 若给定了 CHECK 参数，却没有给定 CHECK_STATUS 参数，则报错
    aoe_expect_related_param(config CHECK CHECK_STATUS)

    # 检查该属性是否存在
    __aoe_check_property(${type} ${property})

    # 获取属性变量
    set(__property_variable __AOE_${type}_PROPERTY_${config_INSTANCE}_${property})

    # 先取出该属性的内容，方便后续流程使用
    get_property(__property_content GLOBAL PROPERTY ${__property_variable})

    # 若给定了 SET 参数，则用相关的值覆盖已有的值
    if (DEFINED config_SET)
        set(__property_content ${config_SET})
    endif ()

    # 若给定了 APPEND 参数，则向该属性追加新值
    if (DEFINED config_APPEND)
        list(APPEND __property_content ${config_APPEND})
    endif ()

    # 若给定了 REMOVE 参数，则删除该属性中对应的值
    if (DEFINED config_REMOVE)
        list(REMOVE_ITEM ${__property_content} ${config_REMOVE})
    endif ()

    # 若给定了 CHECK 参数，则查找该属性是否记录指定的值
    if (DEFINED config_CHECK)
        set(${config_CHECK_STATUS} True)

        # 遍历所有需要检查的值，逐一查找，只要有一个值不存在，则认为检查失败
        foreach (value ${config_CHECK})
            list(FIND ${__property_content} ${value} ${config_CHECK_STATUS})

            if (${${config_CHECK_STATUS}} EQUAL -1)
                set(${config_CHECK_STATUS} False)
            else()
                set(${config_CHECK_STATUS} True)
                break()
            endif()
        endforeach ()

        # 输出检查结果
        aoe_output(${config_CHECK_STATUS})
    endif ()

    # 若设置了 GET 参数，则获取该属性值
    if (DEFINED config_GET)
        aoe_output(${config_GET} ${__property_content})
    endif ()

    # 更新属性值，并删除临时变量
    set_property(GLOBAL PROPERTY ${__property_variable} ${__property_content})
    unset(__property_variable)
    unset(__property_content)
endmacro()
