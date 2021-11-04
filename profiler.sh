#!/bin/bash
mainMenu() {

}

profiler() {
    timer=1
    while [[ "$timer" -le "100" ]]; do
        #reads current CPU temperature in *C to 2 decimal palces
        CPUtemp=$(($(cat /sys/class/thermal/thermal_zone0/temp) / 1000))
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

        #writes all data to a new line in the data file
        echo "$timer    $CPUtemp    $GPUtemp    $clock  $memoryFree $memoryUsed $CPUusage" >> data

        ((timer++))
        /bin/sleep 1
    done
}
