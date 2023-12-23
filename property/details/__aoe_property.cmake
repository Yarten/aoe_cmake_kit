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
#     CHECK_STATUS <result>
#   | GET          <result>
#   | UNSET
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
#
# UNSET: 将指定属性的值清空。
#        Set empty value to the property.
# --------------------------------------------------------------------------------------------------------------

macro(__aoe_property type property)
    # Parse parameters
    __aeo_cmake_parse_nullable_arguments(config "UNSET" "INSTANCE;CHECK_STATUS;GET" "SET;APPEND;REMOVE;CHECK" ${ARGN})
    aoe_disable_unknown_params(config)
    aoe_expect_one_of_params(config UNSET SET APPEND REMOVE CHECK GET)
    aoe_expect_related_param(config CHECK CHECK_STATUS)

    # Check if the given property exists, and if not, an error will be raised
    __aoe_check_property(${type} ${property})

    # Get the property's real name and its content
    set(__property_variable __AOE_${type}_PROPERTY_${config_INSTANCE}_${property})

    get_property(__property_content GLOBAL PROPERTY ${__property_variable})

    # Do set
    if (DEFINED config_SET)
        set(__property_content ${config_SET})
    endif ()

    # Do append
    if (DEFINED config_APPEND)
        list(APPEND __property_content ${config_APPEND})
    endif ()

    # Do item removing
    if (DEFINED config_REMOVE)
        list(REMOVE_ITEM ${__property_content} ${config_REMOVE})
    endif ()

    # Do items existence checking
    if (DEFINED config_CHECK)
        set(${config_CHECK_STATUS} True)

        # Fails if any of the checked items are missing
        foreach (value ${config_CHECK})
            list(FIND __property_content ${value} __property_found_index)

            if (${__property_found_index} EQUAL -1)
                set(${config_CHECK_STATUS} False)
                break()
            endif()
        endforeach ()

        # Output the checking result
        aoe_output(${config_CHECK_STATUS})
    endif ()

    # Do get
    if (DEFINED config_GET)
        aoe_output(${config_GET} ${__property_content})
    endif ()

    # Do unset
    if (${config_UNSET})
        set(__property_content "")
    endif ()

    # Update the property's content and clear temporary variables
    set_property(GLOBAL PROPERTY ${__property_variable} ${__property_content})
    unset(__property_variable)
    unset(__property_content)
endmacro()
