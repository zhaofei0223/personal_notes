
cmake_minimum_required(VERSION 3.10)

project(TESTB)

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include)
include_directories(${HEAD_PATH})

set(SRC_TEST_B ${CMAKE_CURRENT_SOURCE_DIR}/src/test_b.cpp)

# 设置程序输出的路径
set(EXECUTABLE_OUTPUT_PATH ${EXEC_PATH})

link_directories(${LIB_PATH})

add_executable(${TESTB_SHARED} ${SRC_TEST_B})
target_link_libraries(${TESTB_SHARED} ${MODULEB_SHARED_LIB})

add_executable(${TESTB_STATIC} ${SRC_TEST_B})
target_link_libraries(${TESTB_STATIC} ${MODULEB_STATIC_LIB})