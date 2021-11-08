#!/bin/bash
clear
echo "Profiler running"
echo "To close profiler, in another terminal window enter command: 'kill -USR1 $$'"

stopProfiler=0

#kill signal handling
close() {
    stopProfiler=1
}

#traps kill -USR1 signal
trap close USR1

timer=1
while [ $stopProfiler -eq 0 ]; do
    #reads current CPU temperature in *C to 2 decimal palces
    CPUtemp=`echo "scale=2; $(cat /sys/class/thermal/thermal_zone0/temp) / 1000" | bc`
    #reads GPU temp to 2 decimal places and removes other characters
    GPUtemp=`vcgencmd measure_temp | sed -En "s/temp=(.*)'C/\10/p"`
    #reads current clock speed in GHz to 2 decimal places
    clock=`echo "scale=2; $(vcgencmd measure_clock core | cut -c 14-) / 1000000000" | bc`
    #reads free memory in gigabytes from 'free' command
    memoryFree=`echo "scale=2; $(awk '/^Mem:/ {print $4}' <(free -b)) / 1000000000" | bc`
    #reads used memory in gigabytes from 'free' command
    memoryUsed=`echo "scale=2; $(awk '/^Mem:/ {print $3}' <(free -b)) / 1000000000" | bc`
    #reads combined CPU usage for user and system as a percentage
    CPUusage=`awk '/all/ {print $3 + $5}' <(mpstat -u)`

    #creates a time stamped data file and iteratively writes all data to a new line within file
    echo "${timer},${CPUtemp},${GPUtemp},${clock},${memoryFree},${memoryUsed},${CPUusage}" >> data.csv

    #pause 1 second and reiterate
    ((timer++))
    sleep 1
done
echo "Profiler terminated"
echo "Returning to menu"
sleep 2
clear
exit
