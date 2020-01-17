# Build c++ library
set(CMAKE_CXX_STANDARD 17)

include_directories(include)
set(header_files include/example.h)
set(src_files source/example.cpp)

add_library(cppex ${header_files} ${src_files})
add_definitions(-DBUILDING_CPPEX)
