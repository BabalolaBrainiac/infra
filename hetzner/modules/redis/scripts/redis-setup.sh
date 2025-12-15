#!/bin/bash
set -euo pipefail

redis_password='${redis_password}'
redis_port='${redis_port}'
redis_maxmemory_mb='${redis_maxmemory_mb}'
redis_maxmemory_policy='${redis_maxmemory_policy}'
enable_persistence='${enable_persistence}'

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get upgrade -y
apt-get install -y redis-server

conf="/etc/redis/redis.conf"

sed -i "s/^#\\? bind .*/bind 0.0.0.0 ::1/" "$conf"
sed -i "s/^protected-mode .*/protected-mode yes/" "$conf"
sed -i "s/^#\\? requirepass .*/requirepass ${redis_password}/" "$conf"
sed -i "s/^port .*/port ${redis_port}/" "$conf"
sed -i "s/^#\\? tcp-keepalive .*/tcp-keepalive 300/" "$conf"
sed -i "s/^timeout .*/timeout 0/" "$conf"

if [ "${redis_maxmemory_mb}" != "0" ]; then
  if grep -q '^maxmemory ' "$conf"; then
    sed -i "s/^maxmemory .*/maxmemory ${redis_maxmemory_mb}mb/" "$conf"
  else
    echo "maxmemory ${redis_maxmemory_mb}mb" >> "$conf"
  fi
fi

if grep -q '^maxmemory-policy ' "$conf"; then
  sed -i "s/^maxmemory-policy .*/maxmemory-policy ${redis_maxmemory_policy}/" "$conf"
else
  echo "maxmemory-policy ${redis_maxmemory_policy}" >> "$conf"
fi

if [ "${enable_persistence}" = "true" ]; then
  if grep -q '^appendonly ' "$conf"; then
    sed -i "s/^appendonly .*/appendonly yes/" "$conf"
  else
    echo "appendonly yes" >> "$conf"
  fi
  if grep -q '^save ' "$conf"; then
    :
  else
    echo "save 900 1" >> "$conf"
    echo "save 300 10" >> "$conf"
    echo "save 60 10000" >> "$conf"
  fi
else
  if grep -q '^appendonly ' "$conf"; then
    sed -i "s/^appendonly .*/appendonly no/" "$conf"
  else
    echo "appendonly no" >> "$conf"
  fi
fi

systemctl enable redis-server
systemctl restart redis-server
systemctl status redis-server --no-pager


