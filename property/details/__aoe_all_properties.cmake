# --------------------------------------------------------------------------------------------------------------
# 获得记录指定类型的 aoe cmake kit 属性的变量名称。
# Get name of the variable that records the aoe cmake kit's properties of the specified type.
# --------------------------------------------------------------------------------------------------------------
# __aoe_name_of_properties_list(result type)
#
# result: 接受输出的变量。
#         The output variable.
#
# type: 属性类型。
#       Type of the properties.
# --------------------------------------------------------------------------------------------------------------

function(__aoe_name_of_properties_list result type)
    aoe_disable_extra_params()
    aoe_output(${result} __AOE_CMAKE_KIT_${type}_PROPERTIES)
endfunction()


# --------------------------------------------------------------------------------------------------------------
# 注册 aoe cmake kit 的属性。
# Register aoe cmake kit's properties.
# --------------------------------------------------------------------------------------------------------------
# __aoe_register_properties(type ...)
#
# type: 属性类型。
#       Type of the property.
#
# ...: 该类别下的全部属性条目。
#      All properties of this kind.
# --------------------------------------------------------------------------------------------------------------

function(__aoe_register_properties type)
    # 获取记录该类型属性列表的变量名称
    __aoe_name_of_properties_list(var ${type})

    # 定义该属性
    define_property(GLOBAL PROPERTY ${var})

    # 将剩下的参数去重后，作为该类型属性的值，设置给它
    list(REMOVE_DUPLICATES ARGN)
    set_property(GLOBAL PROPERTY ${var} ${ARGN})
endfunction()


# --------------------------------------------------------------------------------------------------------------
# 获取指定类型的所有属性。
# Get all properties of the specified type.
# --------------------------------------------------------------------------------------------------------------
# __aoe_all_properties(result type)
#
# result: 接收输出的变量。
#         The output variable.
#
# type: 指定的属性类型
#       The specified type.
# --------------------------------------------------------------------------------------------------------------

function(__aoe_all_properties result type)
    # 获取记录该类型属性列表的变量名称
    __aoe_name_of_properties_list(var ${type})

    # 从注册的属性中取出该类别全部属性的条目列表
    get_property(${result} GLOBAL PROPERTY ${var})

    # 输出该结果
    aoe_output(${result})
endfunction()


# --------------------------------------------------------------------------------------------------------------
# 注册 aoe cmake kit 的公共属性。
# Register aoe cmake kit common properties.
# --------------------------------------------------------------------------------------------------------------

__aoe_register_properties(COMMON
    TEMPLATE_DIRECTORY_PATH
    SCRIPT_DIRECTORY_PATH
    META_VERSION_NAME
)

# --------------------------------------------------------------------------------------------------------------
# 注册 aoe project 属性。
# Register aoe project's properties.
# --------------------------------------------------------------------------------------------------------------

__aoe_register_properties(PROJECT
    VERSION_NAME
    ROS_VERSION
    TARGETS
    PROTOBUF_TARGETS
    INSTALL_LAYOUT
    TARGET_LAYOUT
    ALL_INSTALL_LAYOUTS
    ALL_TARGET_LAYOUTS
    INSTALLED_LIBRARIES
    BASIC_EXPORTED_COMPONENTS
    DEFAULT_EXPORTED_COMPONENTS
)

# --------------------------------------------------------------------------------------------------------------
# 注册 aoe target 属性。
# Register aoe target's properties.
# --------------------------------------------------------------------------------------------------------------

__aoe_register_properties(TARGET
    EGO_INCLUDES
    DEPENDENCIES
    THIRD_PARTIES
    THIRD_PARTIES_COMPONENTS
)

# --------------------------------------------------------------------------------------------------------------
# 注册 aoe protobuf target 属性。
# Register aoe protobuf target's properties.
# --------------------------------------------------------------------------------------------------------------

__aoe_register_properties(PROTOBUF
    SOURCE_DIRECTORIES
    DEPENDENCIES
    SHARED
)

# --------------------------------------------------------------------------------------------------------------
# 注册 aoe layout 属性。
# Register aoe layout's properties.
# --------------------------------------------------------------------------------------------------------------

__aoe_register_properties(LAYOUT
    INSTALL_INCLUDE
    INSTALL_LIB
    INSTALL_BIN
    INSTALL_CMAKE
    TARGET_INCLUDES
    TARGET_SOURCES
    TARGET_PROTOS
    TARGET_TESTS
    TARGET_TESTS_OF_CASE
)
