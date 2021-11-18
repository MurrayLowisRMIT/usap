#!/bin/bash
readonly AWK=/usr/bin/awk
readonly BC=/usr/bin/bc
readonly SED=/usr/bin/sed
readonly CAT=/usr/bin/cat
readonly UPTIME=/usr/bin/uptime
readonly BASH=/usr/bin/bash

stopScript=0

#record current state of led and trigger
ledRevert=`${CAT} /sys/class/leds/led0/brightness`
triggerRevert=`${CAT} /sys/class/leds/led0/trigger | ${SED} 's/.*\[//g; s/\].*//g'`

#traps kill -USR2 signal
trap 'stopScript=1' USR2

#set state of led trigger to "none"
#sudo sh -c "echo none > /sys/class/leds/led0/trigger"
sudo ${BASH} -c "echo none > /sys/class/leds/led0/trigger"

while [ ${stopScript} -eq 0 ]; do
    #record CPU uptime
    ledOn=`echo "$(${AWK} '{print $9}' <(${UPTIME}))" | ${SED} 's/,//'`
    ledOff=`echo "1 - ${ledOn}" | ${BC}`
    #turn led on for portion of second based on CPU uptime
    sudo ${BASH} -c "echo 1 > /sys/class/leds/led0/brightness"
    sleep ${ledOn}
    #turn led off for remainder of second
    sudo ${BASH} -c "echo 0 > /sys/class/leds/led0/brightness"
    sleep ${ledOff}
done

#turn off led
sudo ${BASH} -c "echo 1 > /sys/class/leds/led0/brightness"

#revert led and trigger to starting state
sudo ${BASH} -c "echo ${ledRevert} > /sys/class/leds/led0/brightness"
sudo ${BASH} -c "echo ${triggerRevert} > /sys/class/leds/led0/trigger"
