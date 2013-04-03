#!/bin/bash
# Default acpi script that takes an entry for all actions

minspeed=`cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_min_freq`
maxspeed=`cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq`
setspeed="/sys/devices/system/cpu/cpu0/cpufreq/scaling_setspeed"

set $*

# List of modules to unload, space seperated. Edit depending on your hardware and preferences.
modlist="uvcvideo btusb bluetooth"
# Bus list for runtime pm. Probably shouldn't touch this.
buslist="pci spi i2c"

if [ $1 == 0 ] ; then

    #echo -n $minspeed >$setspeed

    # Enable some power saving settings while on battery
    # Enable laptop mode
    echo "5" > /proc/sys/vm/laptop_mode

    # Less VM disk activity. Suggested by powertop
    echo 1500 > /proc/sys/vm/dirty_writeback_centisecs

    echo vegas >    /proc/sys/net/ipv4/tcp_congestion_control
    echo 30 >       /proc/sys/vm/dirty_ratio
    echo deadline > /sys/block/sda/queue/scheduler
    echo 5 >        /proc/sys/vm/swappiness

    echo 0 > /proc/sys/kernel/nmi_watchdog
    echo 1 > /sys/devices/system/cpu/sched_mc_power_savings
    echo 1 > /sys/devices/system/cpu/sched_smt_power_savings

    # Intel sound power saving
    echo Y > /sys/module/snd_hda_intel/parameters/power_save_controller
    echo 1 > /sys/module/snd_hda_intel/parameters/power_save

    # USB powersaving
    for i in /sys/bus/usb/devices/*/power/autosuspend; do
        echo 1 > $i
    done
    # SATA power saving
    for i in /sys/class/scsi_host/host*/link_power_management_policy; do
        echo min_power > $i
    done
    # Disable hardware modules to save power
    for mod in $modlist; do
        grep $mod /proc/modules >/dev/null || continue
        modprobe -r $mod 2>/dev/null
    done
    # Enable runtime power management. Suggested by powertop.
    for bus in $buslist; do
        for i in /sys/bus/$bus/devices/*/power/control; do
            echo auto > $i
        done
    done
else
    logger "AC Adapter plugged"
    #echo -n $maxspeed >$setspeed

    #Return settings to default on AC power
    echo 0 > /proc/sys/vm/laptop_mode
    echo 500 > /proc/sys/vm/dirty_writeback_centisecs

    echo cubic >    /proc/sys/net/ipv4/tcp_congestion_control
    echo 20 >       /proc/sys/vm/dirty_ratio
    echo deadline > /sys/block/sda/queue/scheduler
    echo 60 >       /proc/sys/vm/swappiness

    echo 1 > /proc/sys/kernel/nmi_watchdog
    echo 1 > /sys/devices/system/cpu/sched_mc_power_savings
    echo 1 > /sys/devices/system/cpu/sched_smt_power_savings

    echo Y > /sys/module/snd_hda_intel/parameters/power_save_controller
    echo 0 > /sys/module/snd_hda_intel/parameters/power_save

    for i in /sys/bus/usb/devices/*/power/autosuspend; do
        echo 2 > $i
    done
    for i in /sys/class/scsi_host/host*/link_power_management_policy
    do echo max_performance > $i
    done
    for mod in $modlist; do
        if ! lsmod | grep $mod; then
            modprobe $mod 2>/dev/null
        fi
    done
    for bus in $buslist; do
        for i in /sys/bus/$bus/devices/*/power/control; do
            echo on > $i
        done
    done
fi
