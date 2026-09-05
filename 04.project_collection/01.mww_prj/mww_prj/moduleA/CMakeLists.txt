cmake_minimum_required(VERSION 3.10)

project(moduleA)

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include)
include_directories(${HEAD_PATH})

set(SRC_MODULE_A ${CMAKE_CURRENT_SOURCE_DIR}/src/module_a.cpp)

set(LIBRARY_OUTPUT_PATH ${LIB_PATH})

add_library(${MODULEA_STATIC_LIB} STATIC ${SRC_MODULE_A})
add_library(${MODULEA_SHARED_LIB} SHARED ${SRC_MODULE_A})