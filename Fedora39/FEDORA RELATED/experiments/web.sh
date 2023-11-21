#!/bin/bash

while true
do
  clear
  current_time=$(./clock.sh)  # Run clock.sh and capture its output
  notify-send "The time is:   $current_time  ⏰"
  sleep 5
done
