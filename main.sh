#!/bin/bash
#!/usr/bin/gnuplot
quit=0

mainMenu() {
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

plotter() {
    clear
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
    echo "Graphs created from data file"
    else
        echo "No data file, please run the profiler first to create one"
    fi
    sleep 2
    clear
}

#menu functions
while [ $quit -eq 0 ] ; do
    mainMenu
    read SELECTION
    case $SELECTION in
        1)
            ./profiler.sh
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
