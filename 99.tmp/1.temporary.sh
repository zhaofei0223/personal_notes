#!/bin/bash

# 记录开始时间
start_time=$(date +%s)

# 模拟任务执行（这里可以替换为实际要执行的命令）
echo "任务开始执行..."
sleep 2
echo "任务执行完毕"

# 记录结束时间
end_time=$(date +%s)

# 计算任务耗时
elapsed_time=$((end_time - start_time))

# 输出结果
echo "任务执行耗时: ${elapsed_time} 秒"