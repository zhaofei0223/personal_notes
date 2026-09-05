
cmake_minimum_required(VERSION 3.10)

project(TESTA)

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include)
include_directories(${HEAD_PATH})

set(SRC_TEST_A ${CMAKE_CURRENT_SOURCE_DIR}/src/test_a.cpp)

# 设置程序输出的路径
set(EXECUTABLE_OUTPUT_PATH ${EXEC_PATH})

link_directories(${LIB_PATH})

add_executable(${TESTA_SHARED} ${SRC_TEST_A})
target_link_libraries(${TESTA_SHARED} ${MODULEA_SHARED_LIB})

add_executable(${TESTA_STATIC} ${SRC_TEST_A})
target_link_libraries(${TESTA_STATIC} ${MODULEA_STATIC_LIB})