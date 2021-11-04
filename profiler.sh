#!/bin/bash
counter=1
while [[ "$counter" -le "10" ]]; do
    cat /sys/class/thermal/thermal_zone0/temp >> data
    ((counter++))
done
