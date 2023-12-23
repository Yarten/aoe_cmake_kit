# --------------------------------------------------------------------------------------------------------------
# 检查指定类型的属性是否合法，若无效，将报错。
# Check if the given property is legal, and if not, raise an error.
# --------------------------------------------------------------------------------------------------------------
# __aoe_check_property(type property_name)
#
# type: 指定的类别。
#       The specified type.
#
# property_name: 被检查的属性名称。
#                Name of the property being checked.
# --------------------------------------------------------------------------------------------------------------

function(__aoe_check_property type property_name)
    aoe_disable_extra_params()

    __aoe_all_properties(properties ${type})

    list(FIND properties ${property_name} property_name_is_valid)

    if (${property_name_is_valid} EQUAL -1)
        message(FATAL_ERROR "aoe ${type} property [${property_name}] is undefined !")
    endif()
endfunction()
