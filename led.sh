#!/bin/bash
stopScript=0

#record current state of led and trigger
ledRevert=`cat /sys/class/leds/led0/brightness`
triggerRevert=`cat /sys/class/leds/led0/trigger | sed 's/.*\[//g; s/\].*//g'`

#traps kill -USR2 signal
trap 'stopScript=1' USR2

#set state of led trigger to "none"
sudo sh -c "echo none > /sys/class/leds/led0/trigger"

while [ ${stopScript} -eq 0 ]; do
    #record CPU uptime
    ledOn=`echo "$(awk '{print $9}' <(uptime))" | sed 's/,//'`
    ledOff=`echo "1 - ${ledOn}" | bc`
    #turn led on for portion of second based on CPU uptime
    sudo sh -c "echo 1 > /sys/class/leds/led0/brightness"
    sleep ${ledOn}
    #turn led off for remainder of second
    sudo sh -c "echo 0 > /sys/class/leds/led0/brightness"
    sleep ${ledOff}
done

#turn off led
sudo sh -c "echo 1 > /sys/class/leds/led0/brightness"

#revert led and trigger to starting state
sudo sh -c "echo ${ledRevert} > /sys/class/leds/led0/brightness"
sudo sh -c "echo ${triggerRevert} > /sys/class/leds/led0/trigger"
