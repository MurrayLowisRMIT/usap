#!/bin/bash

stopProfiler=0
quit=0

#kill signal handling
close() {
    stopProfiler=1
}

#traps kill -USR1 signal
trap close USR1

profiler() {
    clear
    echo "Profiler running"
    echo "To close profiler, in another terminal window enter command: 'kill -USR1 $$'"
    stopProfiler=0
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
}

plotter() {
    if [[ -e data.csv ]] ;
    then
cat > gnuplot.p << END
set datafile separator comma
set terminal png size 700,700
set title 'System Temperature'
set xlabel 'Time (s)'
set ylabel 'Temperature (*C)'
set output 'temp.png'
plot "data.csv" using 1:2 with point pt 7 lc rgb "blue" title "CPU",\
"data.csv" using 1:3 with point pt 7 lc rgb "green" title "Video device"
set title 'Memory Usage'
set ylabel 'System memory (GB)'
set output 'memory.png'
plot "data.csv" using 1:5 with point pt 7 lc rgb "blue" title "Free",\
"data.csv" using 1:6 with point pt 7 lc rgb "green" title "In use"
set title 'Clock Speed'
set ylabel 'Clock speed (GHz)'
set output 'clock.png'
plot "data.csv" using 1:4 with point pt 7 lc rgb "blue" title "Clock speed"
set title 'CPU Utilisation'
set ylabel 'CPU utilisation (%)'
set output 'cpu.png'
plot "data.csv" using 1:7 with point pt 7 lc rgb "blue" title "CPU utilisation"
END
    gnuplot "gnuplot.p"
    clear
    echo "Graphs created from data file"
    else
        echo "No data file, please run the profiler first to create one"
    fi
    sleep 2
    clear
}

profilerMenu() {
    clear
    printf " Profiler menu\n"
    printf " --------------------------------------\n"
    printf "\n"
    printf " 1: Start profiler\n"
    printf " 2: Plot statistics with GNUPlot\n"
    printf " 3: \n"
    printf " 4: \n"
    printf "\n"
    printf " X) Exit\n"
}

#menu functions
while [ $quit -eq 0 ] ; do
    profilerMenu
    read SELECTION
    case $SELECTION in
        1)
            profiler
            ;;

        2)
            plotter
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
    clear
done
