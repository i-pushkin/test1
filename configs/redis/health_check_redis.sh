#!/bin/bash

response=$(
  timeout -s 15 5 \
  redis-cli \
  -h localhost \
  -p 6379 \
  -a ozapipass \
  --no-auth-warning \
  ping
)
if [ "$?" -eq "124" ]; then
  echo "Timed out"
  exit 1
fi
if [ "$response" != "PONG" ]; then
  echo "$response"
  exit 1
fi

