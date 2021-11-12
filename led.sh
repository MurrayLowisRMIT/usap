#!/bin/bash
stopScript=0

#kill signal handling
close() {
    stopScript=1
}

#traps kill -USR2 signal
trap close USR2

ledManipulator() {
    while [ $stopScript -eq 0 ]; do
        ledOn=`echo "scale=2; $(awk '{print $12}' <(uptime)) / 5" | bc`
        #echo $ledOn
        #ledOff=`echo "scale=2; (1 - $ledOn)" | bc`
        #sudo sh -c "echo 1 > /sys/class/leds/led0/brightness"
        #sleep=$ledOn
        #echo $ledOn
        #sudo sh -c "echo 0 > /sys/class/leds/led0/brightness"
        sleep=1
        #echo $ledOff
    done
}

ledManipulator
