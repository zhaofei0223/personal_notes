#!/bin/bash

eck_command() {
  if ! command -v $1 &> /dev/null; then
    echo "未找到❎✅"
  else
    echo "have"
  fi
}

eck_command $1

