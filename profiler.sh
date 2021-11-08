#!/bin/bash
quit=0
stopProfiler=0

close() {
    stopProfiler=1
    printf "Profiler terminated\n"
    printf "Exiting program\n"
    sleep 2
    exit
}

trap close USR1

mainMenu() {
    clear
    printf " Main menu\n"
    printf " --------------------------------------\n"
    printf "\n"
    printf " 1: Start profiler\n"
    printf " 2: Plot statistics with GNUPlot\n"
    printf " 3: \n"
    printf " 4: \n"
    printf "\n"
    printf " X) Exit\n"
}

profiler() {
    #take time stamp for file creation
    file="`date +"%Y-%m-%d_%T"`"
    timer=1
    while [ $stopProfiler -eq 0 ]; do
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

        #creates a time stamped data file and iteratively writes all data to a new line within file
        echo "$timer    $CPUtemp    $GPUtemp    $clock  $memoryFree $memoryUsed $CPUusage" >> "data_${file}"

        #pause 1 second and reiterate
        ((timer++))
        /bin/sleep 1
    done
}

while [ $quit -eq 0 ] ; do
    mainMenu
    read SELECTION
    case $SELECTION in
        1)
            stopProfiler=0
            profiler
            ;;

        2)
            ;;

        3)
            ;;

        4)
            ;;

        [Xx])
            quit=1
            ;;
        ?)
            printf "Invalid selection"
            sleep 2
            ;;
    esac
done
