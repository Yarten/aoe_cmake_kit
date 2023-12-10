# --------------------------------------------------------------------------------------------------------------
# 处理全部在工程内定义的 protobuf 目标，执行生成，并创建对应的库目标。
# Process all protobuf targets defined within the project,
# perform generation, and create the corresponding library targets.
# --------------------------------------------------------------------------------------------------------------
# __aoe_build_all_protobuf_targets()
#
# This function is used by aoe_project_complete().
# --------------------------------------------------------------------------------------------------------------

function(__aoe_build_all_protobuf_targets)
    # -------------------------------------------------------------
    # 获取全部 protobuf 目标
    __aoe_project_property(PROTOBUF_TARGETS GET all_protobuf_targets)

    # -------------------------------------------------------------
    # 扫描全部 protobuf 目标，整合他们的目录，将用于 protoc
    set(proto_paths "")

    foreach(target ${all_protobuf_targets})
        __aoe_protobuf_property(${target} SOURCE_DIRECTORIES GET source_directories)

        foreach(path ${source_directories})
            set(proto_paths "${proto_paths} -I=${path}")
        endforeach()
    endforeach()

    # -------------------------------------------------------------
    # 遍历所有 protobuf 目标，进行逐一的 protobuf 编译生成
    foreach(target ${all_protobuf_targets})
        # -------------------------------------------------------------
        # 整合该目标的全部依赖，同时检查这些依赖是否存在
        set(proto_dependencies "")

        __aoe_protobuf_property(${target} DEPENDENCIES GET dependencies)

        foreach(dependency ${dependencies})
            __aoe_project_property(PROTOBUF_TARGETS CHECK ${dependency} CHECK_STATUS is_existed)

            if (NOT ${is_existed})
                message(FATAL_ERROR "Protobuf target [${target}] depends on [${dependency}] but it is not existed !")
            endif ()

            set(proto_dependencies "${proto_dependencies} ${dependency}")
        endforeach()

        # -------------------------------------------------------------
        # 遍历该目标的全部源文件目录，取出所有的源文件，组合为执行参数的一部分
        set(proto_files "")

        __aoe_protobuf_property(${target} SOURCE_DIRECTORIES GET source_directories)

        foreach(source_directory ${source_directories})
            file(GLOB_RECURSE files FOLLOW_SYMLINKS ${source_directory}/*.proto)
            foreach(file ${files})
                set(proto_files "${proto_files} ${file}")
            endforeach()
        endforeach()

        # -------------------------------------------------------------
        # 准备该目标的根目录，用于代码生成
        set(target_root "${CMAKE_BINARY_DIR}/.aoe/${PROJECT_NAME}/protobuf-targets/${target}")

        # -------------------------------------------------------------
        # 执行 protoc 脚本
        __aoe_common_property(SCRIPT_DIRECTORY_PATH GET script_directory_path)

        aoe_execute_process(
            "${script_directory_path}/generate_protobuf_package.bash"
            "${target}" "${target_root}" "${proto_paths}" "${proto_files}"
        )

        message("${script_directory_path}/generate_protobuf_package.bash \\")
        message("${target} \\")
        message("${target_root} \\")
        message("${proto_paths} \\")
        message("${proto_files}")

        # -------------------------------------------------------------
        # 设置该目标编译为动态库的选项
        __aoe_protobuf_property(${target} SHARED GET is_shared)

        if (${is_shared})
            set(shared_or_static "SHARED")
        else()
            set(shared_or_static "STATIC")
        endif ()

        # -------------------------------------------------------------
        # 在创建出来的库目标目录下，创建 CMakeLists.txt
        __aoe_common_property(TEMPLATE_DIRECTORY_PATH GET template_directory_path)

        configure_file(
            "${template_directory_path}/protobuf_target_CMakeLists.txt.in"
            "${target_root}/CMakeLists.txt"
            @ONLY
        )

        # -------------------------------------------------------------
        # 添加该目录到构建树中
        add_subdirectory("${target_root}" "${target_root}.out")

        # 完成本目标的生成过程。
    endforeach()

    # 完成全部 protobuf 目标的生成过程
endfunction()
