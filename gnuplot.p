set datafile separator comma
set terminal png size 700,700
set title 'System Temperature'
set xlabel 'Time (s)'
set ylabel 'Temperature (*C)'
set output 'temp.png'
plot "data.csv" using 1:2 with point pt 7 lc rgb "blue" title "CPU","data.csv" using 1:3 with point pt 7 lc rgb "green" title "Video device"
set title 'Memory Usage'
set ylabel 'System memory (GB)'
set output 'memory.png'
plot "data.csv" using 1:5 with point pt 7 lc rgb "blue" title "Free","data.csv" using 1:6 with point pt 7 lc rgb "green" title "In use"
set title 'Clock Speed'
set ylabel 'Clock speed (GHz)'
set output 'clock.png'
plot "data.csv" using 1:4 with point pt 7 lc rgb "blue" title "Clock speed"
set title 'CPU Utilisation'
set ylabel 'CPU utilisation (%)'
set output 'cpu.png'
plot "data.csv" using 1:7 with point pt 7 lc rgb "blue" title "CPU utilisation"
