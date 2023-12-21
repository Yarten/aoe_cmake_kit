# aoe_cmake_kit

Just some cmake tools for lazy people like me :)

Examples and docs (not yet) can be found at [aoe cmake kit tutorial](https://github.com/Yarten/aoe_cmake_kit_tutorial).

## Import the kit

You can use the following codes to import this kit:

```cmake
include(FetchContent)
FetchContent_Declare(aoe_cmake_kit GIT_REPOSITORY https://github.com/Yarten/aoe_cmake_kit.git GIT_TAG main)
FetchContent_MakeAvailable(aoe_cmake_kit)
FetchContent_GetProperties(aoe_cmake_kit SOURCE_DIR aoe_cmake_kit)
include(${aoe_cmake_kit}/main.cmake)
```

## Simple Example

Suppose you have a cmake project as shown below:

```text
.
├── CMakeLists.txt
├── include
│   └── demo
│       └── lib.h
├── src
│   ├── exe
│   │   └── main.cpp
│   └── lib
│       └── lib.cpp
└── test
    └── lib
        └── main.cpp

```

There is a 'lib' target which has its own test executable.
In addition, the 'exe' target depends on the 'lib' target.

Using this kit, the code in CMakeLists.txt could look like this:

```cmake
cmake_minimum_required(VERSION 3.16)

# -------------------------------------------------------------
# Import aoe cmake kit ('main' branch)
include(FetchContent)
FetchContent_Declare(aoe_cmake_kit GIT_REPOSITORY https://github.com/Yarten/aoe_cmake_kit.git GIT_TAG main)
FetchContent_MakeAvailable(aoe_cmake_kit)
FetchContent_GetProperties(aoe_cmake_kit SOURCE_DIR aoe_cmake_kit)
include(${aoe_cmake_kit}/main.cmake)

# -------------------------------------------------------------
# Create the aoe project
aoe_project(NAME SimpleExample VERSION 1.2.3)

# -------------------------------------------------------------
# Create a library target, an executable test target,
# and an executable target that using the library target.

aoe_add_library(lib)
aoe_add_executable_test(lib)
aoe_add_executable(exe DEPEND lib)

# -------------------------------------------------------------
# Complete the project
aoe_project_complete()
```

It is worth mentioning that the **installation** process 
for both the library target and the executable target mentioned above is defined by the kit.
The kit can do a lot for you !
