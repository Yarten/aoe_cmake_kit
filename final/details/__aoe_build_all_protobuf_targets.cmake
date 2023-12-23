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
    # Get all protobuf targets
    __aoe_project_property(PROTOBUF_TARGETS GET all_protobuf_targets)

    # -------------------------------------------------------------
    # Scan all protobuf targets and collect their source directories that will be used for protoc
    set(proto_paths "")

    foreach(target ${all_protobuf_targets})
        __aoe_protobuf_property(${target} SOURCE_DIRECTORIES GET source_directories)

        foreach(path ${source_directories})
            set(proto_paths "${proto_paths} -I=${path}")
        endforeach()
    endforeach()

    # -------------------------------------------------------------
    # Iterate over all protobuf targets and compile them one by one
    foreach(target ${all_protobuf_targets})
        # -------------------------------------------------------------
        # Collect the dependencies of this target, while checking if they exist,
        # ${proto_dependencies} will be used in the target's CMakeLists.txt.
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
        # Iterate through the entire directory of source files for this target,
        # take out all the source files and combine them as part of the execution parameters
        set(proto_files "")

        __aoe_protobuf_property(${target} SOURCE_DIRECTORIES GET source_directories)

        foreach(source_directory ${source_directories})
            file(GLOB_RECURSE files FOLLOW_SYMLINKS ${source_directory}/*.proto)
            foreach(file ${files})
                set(proto_files "${proto_files} ${file}")
            endforeach()
        endforeach()

        # -------------------------------------------------------------
        # Prepare the root directory of this target for code generation
        set(target_root "${CMAKE_BINARY_DIR}/.aoe/${PROJECT_NAME}/protobuf-targets/${target}")

        # -------------------------------------------------------------
        # Execute the protoc script
        __aoe_common_property(SCRIPT_DIRECTORY_PATH GET script_directory_path)

        aoe_execute_process(
            "${script_directory_path}/generate_protobuf_package.bash"
            "${target}" "${target_root}" "${proto_paths}" "${proto_files}"
        )

        # -------------------------------------------------------------
        # Set the option for compiling this target as a dynamic library or not
        __aoe_protobuf_property(${target} SHARED GET is_shared)

        if (${is_shared})
            set(shared_or_static "SHARED")
        else()
            set(shared_or_static "STATIC")
        endif ()

        # -------------------------------------------------------------
        # Create CMakeLists.txt in the directory of the created library target
        __aoe_common_property(TEMPLATE_DIRECTORY_PATH GET template_directory_path)

        configure_file(
            "${template_directory_path}/protobuf_target_CMakeLists.txt.in"
            "${target_root}/CMakeLists.txt"
            @ONLY
        )

        # -------------------------------------------------------------
        # Add the directory to the build tree
        add_subdirectory("${target_root}" "${target_root}.out")

        # Complete the generation process for this protobuf target
    endforeach()

    # Complete the process of generating all protobuf targets
endfunction()
