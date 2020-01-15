CMAKE_MINIMUM_REQUIRED(VERSION 3.16)

project(swig_simple)

include_directories(include)
set(header_files include/example.h)
set(src_files source/example.cpp)

add_library(cppex SHARED ${header_files} ${src_files})
add_definitions(-DBUILDING_CPPEX)


# SWIG code
FIND_PACKAGE(SWIG REQUIRED)
include(UseSWIG)

FIND_PACKAGE(Python3 COMPONENTS Interpreter Development)
INCLUDE_DIRECTORIES(${Python3_INCLUDE_DIRS})
INCLUDE_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR}/include)

# Remove python debug libraries if they are found
list(FIND Python3_LIBRARIES "debug" debug_index)
if(${debug_index} GREATER -1)
    message("Python3_LIBRARIES: ${Python3_LIBRARIES}")
    math(EXPR debug_lib_file_index "${debug_index}+1")
    list(REMOVE_AT Python3_LIBRARIES ${debug_index} ${debug_lib_file_index})
    message("After remove: ${Python3_LIBRARIES}")
endif()

list(FIND Python3_LIBRARIES "optimized" optimized_index)
if(${optimized_index} GREATER -1)
    list(REMOVE_AT Python3_LIBRARIES ${optimized_index})
endif()

set(CMAKE_SWIG_FLAGS "")

SET_SOURCE_FILES_PROPERTIES(python/example.i PROPERTIES CPLUSPLUS ON)
SET_SOURCE_FILES_PROPERTIES(python/example.i SWIG_FLAGS "-includeall")
SWIG_ADD_LIBRARY(example
    TYPE SHARED
    LANGUAGE python
    SOURCES python/example.i)
SWIG_LINK_LIBRARIES(example ${Python3_LIBRARIES} cppex)
# set_target_properties(example PROPERTIES DEBUG_POSTFIX "_d")