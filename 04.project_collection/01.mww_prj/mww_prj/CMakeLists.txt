# 设置cmake要求的最小版本
cmake_minimum_required(VERSION 3.10)

# 设置工程名称，这里与后面生产的应用名称是两个概念，不相干。
project(test1)

# 定义变量
# 动/静态库生产的路径
set(LIB_PATH ${CMAKE_CURRENT_SOURCE_DIR}/lib)
# 定义测试程序生产的路径
set(EXEC_PATH ${CMAKE_CURRENT_SOURCE_DIR}/bin)

# 头文件目录
set(HEAD_PATH ${CMAKE_CURRENT_SOURCE_DIR}/include)

# 库的名字
set(MODULEA_SHARED_LIB modulea_shared)
set(MODULEA_STATIC_LIB modulea_static)
set(MODULEB_SHARED_LIB moduleb_shared)
set(MODULEB_STATIC_LIB moduleb_static)

# 可执行程序的名字
set(TESTA_SHARED testa_shared)
set(TESTA_STATIC testa_static)
set(TESTB_SHARED testb_shared)
set(TESTB_STATIC testb_static)

# 添加子目录
add_subdirectory(moduleA)
add_subdirectory(moduleB)
add_subdirectory(testA)
add_subdirectory(testB)