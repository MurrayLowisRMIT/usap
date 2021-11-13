#!/bin/bash
stopProfiler=0

#kill signal handling
close() {
    stopProfiler=1
}

#traps kill -USR1 signal
trap close USR1

#method to run profiler and take readings while script is active
profiler() {
    #timestamp of test
    timestamp="`date +"%Y-%m-%d_%T"`"
    #create new folder using timestamp to store graphs generated
    mkdir -p "Profiles/${timestamp}"
    cd "Profiles/${timestamp}"

    clear
    echo "Profiler running"
    echo "To close profiler, in another terminal window enter either of the following commands:"
    printf "    kill -USR1 $$\n"
    printf "    kill -USR1 \$(pgrep profiler.sh)\n"

    #creates data file and overwrites existing contents if it already exists
    printf "" > data.csv

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

        #iteratively writes all data to a new line in file each second
        printf "${timer},${CPUtemp},${GPUtemp},${clock},${memoryFree},${memoryUsed},${CPUusage}\n" >> data.csv

        #pause 1 second and reiterate
        ((timer++))
        sleep 1
    done
}

#method to run gnuplot to generate graphs
plotter() {
    #check data file was created successfully then import into gnuplot to generate graphs
    if [[ -e data.csv ]] ;
    then
    #create and format gnuplot file and write with contents of data file
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
    #plot graphs using gnuplot based on contents of above gnuplot.p file
    gnuplot "gnuplot.p"
    #remove no longer needed gnuplot.p file
    rm gnuplot.p
    clear
    echo "Graphs created from data file and exported as .png files"
    echo "Files saved to newly created folder 'Profiles/${timestamp}'"
    else
        #I don't know what you'd have to do to get here, but just in case...
        echo "An error occured, could not read data.csv file"
    fi
    echo "Terminating..."
    sleep 4
    clear
}

#call methods and run led script in background
./led.sh &
profiler
plotter
