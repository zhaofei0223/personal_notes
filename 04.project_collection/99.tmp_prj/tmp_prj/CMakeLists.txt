cmake_minimum_required(VERSION 3.10)

project(tmp)

# 定义变量

# 设置使用g++编译
# set(CMAKE_CXX_COMPILER g++)
# set(CMAKE_CXX_STANDARD 11)

# 定义测试程序生产的路径
set(EXEC_PATH ${CMAKE_CURRENT_SOURCE_DIR}/bin)
# 可执行程序的名字
set(TMP_BIN tmp)

# 头文件目录
set(HEAD_PATH ${CMAKE_CURRENT_SOURCE_DIR}/include)

# 设置代码源文件
set(SRC_LIST ${CMAKE_CURRENT_SOURCE_DIR}/src/tmp.cpp)

# 设置包含的头文件
include_directories(${HEAD_PATH})

# 设置程序输出的路径
set(EXECUTABLE_OUTPUT_PATH ${EXEC_PATH})
# 设置生成目标的依赖
add_executable(${TMP_BIN} ${SRC_LIST})