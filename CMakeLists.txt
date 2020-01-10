project(gtableparser)
cmake_minimum_required(VERSION 2.8)
set (Tutorial_VERSION_MAJOR 1)
set (Tutorial_VERSION_MINOR 0)
set (VERSION_MAJOR 1)
set (VERSION_MINOR 0)
configure_file (
    "${PROJECT_SOURCE_DIR}/config.h.in"
    "${PROJECT_SOURCE_DIR}/include/config.h"
)
#set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,-Bsymbolic")
message("CMAKE_SHARED_LINKER_FLAGS: ${CMAKE_SHARED_LINKER_FLAGS}")
find_package(LibXml2 REQUIRED)
include_directories(${LIBXML2_INCLUDE_DIR})

#https://cmake.org/cmake/help/latest/module/FindPythonLibs.html
find_package(PythonInterp 2.7 REQUIRED)
find_package(PythonLibs 2.7 REQUIRED)
include_directories("${PYTHON_INCLUDE_PATH}")

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -g")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -g")
set(CMAKE_CXX_FLAGS_DEBUG "$ENV{CXXFLAGS} -O0 -Wall -g -ggdb -std=c++17 -fno-strict-aliasing -Wno-register")
set(CMAKE_CXX_FLAGS_RELEASE "$ENV{CXXFLAGS} -O3 -Wall -std=c++17 -fno-strict-aliasing -Wno-register")
set(CMAKE_BUILD_TYPE "Release")
#set(CMAKE_BUILD_TYPE "Debug")

set(CMAKE_SHARED_LIBRARY_PREFIX "")
set(CMAKE_SHARED_LIBRARY_SUFFIX ".so")

include_directories("${PROJECT_SOURCE_DIR}/common/util/include")
include_directories("${PROJECT_SOURCE_DIR}/common/include")
include_directories("${PROJECT_SOURCE_DIR}/include")
include_directories("${CMAKE_CURRENT_BINARY_DIR}")


# ddl2xml
execute_process(COMMAND flex "${PROJECT_SOURCE_DIR}/ddl.l")
execute_process(COMMAND bison "${PROJECT_SOURCE_DIR}/ddl.y")
set(DDL2XML_SRCS
"${CMAKE_CURRENT_BINARY_DIR}/ddl.l.cc" 
"${CMAKE_CURRENT_BINARY_DIR}/ddl.y.cc" 
"${PROJECT_SOURCE_DIR}/src/ddl2xml.cpp" 
"${PROJECT_SOURCE_DIR}/src/ddl2xml_xml_generator.cpp" 
"${PROJECT_SOURCE_DIR}/src/parser-common.cpp" 
)

add_executable(ddl2xml ${DDL2XML_SRCS} "${PROJECT_SOURCE_DIR}/src/ddl2xml_main.cpp")
target_link_libraries(ddl2xml ${LIBXML2_LIBRARIES})

add_library(pyddl2xml SHARED ${DDL2XML_SRCS} 
"${PROJECT_SOURCE_DIR}/common/util/src/python_bind.cpp"
"${PROJECT_SOURCE_DIR}/src/ddl2xml_python_main.cpp")
target_link_libraries(pyddl2xml ${LIBXML2_LIBRARIES} ${PYTHON_LIBRARIES})

# gql2xml 
execute_process(COMMAND flex "${PROJECT_SOURCE_DIR}/gql.l")
execute_process(COMMAND bison "${PROJECT_SOURCE_DIR}/gql.y")
set(GQL2XML_SRCS
"${CMAKE_CURRENT_BINARY_DIR}/gql.l.cc" 
"${CMAKE_CURRENT_BINARY_DIR}/gql.y.cc" 
"${PROJECT_SOURCE_DIR}/src/gql2xml.cpp" 
"${PROJECT_SOURCE_DIR}/src/gql2xml_xml_generator.cpp" 
"${PROJECT_SOURCE_DIR}/src/parser-common.cpp" 
)

add_executable(gql2xml ${GQL2XML_SRCS} "${PROJECT_SOURCE_DIR}/src/gql2xml_main.cpp")
target_link_libraries(gql2xml ${LIBXML2_LIBRARIES})

add_library(pygql2xml SHARED ${GQL2XML_SRCS} 
"${PROJECT_SOURCE_DIR}/common/util/src/python_bind.cpp"
"${PROJECT_SOURCE_DIR}/src/gql2xml_python_main.cpp")
target_link_libraries(pygql2xml ${LIBXML2_LIBRARIES} ${PYTHON_LIBRARIES})