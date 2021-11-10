
# Kernel Compilation Profiling Report

## Foreword

This report provides brief commentary on the various metrics recorded by my Raspberry Pi while compiling a kernel. Each of the graphs below relate to the same instance of a kernel being compiled over the course of about 1 hour.  

## Temperature

This image shows the plot of the temperature for both the CPU (blue) and video device (green). The temperature of both devices was quite similar throughout.  

![Temperature profile during kernel compilation](/KernelCompilationProfile/temp.png)

The temperature started at around 45 degrees and rapidly rose to a maximum of about 63 degrees over the course of the compilation. There are 3 instances where the temperature dropped during the profiling process. The first drop (at around 600 seconds) was the result of me placing my hand on the heatsink for about 1 minute to see if it would cause any observable change (so... success I guess!).  

The short drop at around 2800 seconds I believe is when the compilation actually completed. The temperature then rises again as the installation starts almost immediately after.  

The final drop at around 3300 seconds is when the full process was completed and the profiler script was stopped.  

## CPU clock

The CPU clock started at around 0.19GHz while running idle processes before spiking up to 0.49 to 0.50 GHz where it stayed thoughout the compilation process.  

![CPU clock profile during kernel compilation](/KernelCompilationProfile/clock.png)

The same drop that was found in the temperature plot at around 3300 seconds can be seen in the CPU clock plot when the profiler script was terminated.  

Otherwise it seems the Pi had no real issues with workload or overheating during the compilation.  

## CPU utilisation

![CPU utilisation profile during kernel compilation](/KernelCompilationProfile/cpu.png)

This one is genuinely vexxing... By all means my script *appears* to be taking readings correctly, though this plot shows CPU utilisation increasing linearly over the compilation so I'm uncertain of the correctness.  

After terminating the profiler the CPU utilisation seemed to stay around the maximum value (tested by simply entering 'mpstat' several times over several minutes after completing the compilation).  

## Memory

![System memory profile during kernel compilation](/KernelCompilationProfile/memory.png)

System memory seems to have been largely unaffected by the compilation process. There does appear to be a minor jump around the 2800 second mark when the compilation finished and the installation began.
