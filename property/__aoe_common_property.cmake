# --------------------------------------------------------------------------------------------------------------
# 操作指定的公共属性。
# Operate on the given common property.
# --------------------------------------------------------------------------------------------------------------
# __aoe_common_property(property
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
# property: 指定的属性。
#           The specified property.
# --------------------------------------------------------------------------------------------------------------
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

function(__aoe_common_property property)
    __aoe_property(COMMON ${property} ${ARGN})
endfunction()
