#!/bin/sh
set -e

# Установка vshard, если не установлен
if ! tt rocks list | grep -q vshard; then
  echo "Installing vshard..."
  tt rocks install vshard
fi

# Запуск Tarantool
exec tarantool /opt/tarantool/moscow-replica.lua