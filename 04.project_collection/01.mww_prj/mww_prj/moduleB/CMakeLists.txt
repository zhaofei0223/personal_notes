cmake_minimum_required(VERSION 3.10)

project(moduleb)

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include)
include_directories(${HEAD_PATH})

set(SRC_MODULE_B ${CMAKE_CURRENT_SOURCE_DIR}/src/module_b.cpp)

set(LIBRARY_OUTPUT_PATH ${LIB_PATH})

add_library(${MODULEB_SHARED_LIB} SHARED ${SRC_MODULE_B})
add_library(${MODULEB_STATIC_LIB} STATIC ${SRC_MODULE_B})