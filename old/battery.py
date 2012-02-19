#!/usr/bin/env/python2
import sys
#A simple script to get informations about your battery
#It takes a format string and substitutes some characters
#with informations from /proc/acpi/battery/BAT#/*
#
#I think, a simple example describes it best
#battery "%S: %t at %r, health: %h"
#becomes: discharging: 0h,23m at: 12W, health: 45%
#for a list of all substitutions see the dictionary "substitutions" 
#near the end of this code

settings = { "battery" : "BAT0"}
if len(sys.argv) != 2:
    print "ERROR: exactly one argument expected"
    sys.exit(1)

target_string = sys.argv[1]


def extractValue(battery_line):
    #this looks uglier than it is
    return int(battery_line.split(':')[1].strip().split(' ')[0].strip())

#many of the variables below won't be used, but it doesn't hurt to have them anyway

#extract informations from battery info file
batfile = open("/proc/acpi/battery/%s/info" % settings['battery'] )
for line in batfile:
    if 'present' in line:
        present = line.split(':')[1].strip()
    elif 'design capacity' in line:
        design_capacity = extractValue(line)
    elif 'last full capacity' in line:
        last_full_capacity = extractValue(line)
    elif 'battery technology' in line:
        battery_techology = line.split(':')[1].strip()
    elif 'design voltage' in line:
        design_voltage = extractValue(line)
    elif 'design capacity warning' in line:
        design_capacity_warning = extractValue(line)
    elif 'design capacity low' in line:
        design_capacity_low = extractValue(line)
    elif 'capacity granularity 1' in line:
        capacity_granularity_1 = extractValue(line)
    elif 'capacity_granularity_2' in line:
        capacity_granularity_2 = extractValue(line)
    elif 'model number' in line:
        model_number = line.split(':')[1].strip()
    elif 'serial number' in line:
        serial_number = line.split(':')[1].strip()
    elif 'battery type' in line:
        battery_type = line.split(':')[1].strip()
    elif 'OEM info' in line:
        OEM_info = line.split(':')[1].strip()
batfile.close()        

#extract informations from battery alarm file
batfile = open("/proc/acpi/battery/%s/alarm" % settings['battery'])
for line in batfile:
    if 'alarm' in line:
        alarm = extractValue(line)
batfile.close()

#extract informations from battery state file
batfile = open("/proc/acpi/battery/%s/state" % settings['battery'])
for line in batfile:
    if 'capacity state' in line:
        capacity_state = line.split(':')[1].strip()
    elif 'charging state' in line:
        charging_state = line.split(':')[1].strip()
    elif 'present rate' in line:
        present_rate = extractValue(line)
    elif 'remaining capacity' in line:
        remaining_capacity = extractValue(line)
    elif 'present voltage' in line:
        present_voltage = extractValue(line)

#Derive some informations
if charging_state == 'discharging':
    time_remaining = 1.00*remaining_capacity/present_rate
    #change time_remaining into a (hh,mm)tuple
    hours = 0
    while(time_remaining >= 1):
        hours += 1
        time_remaining -= 1
    minutes = int(time_remaining * 60)
    time_remaining = (hours, minutes)

elif charging_state == 'charging':
    time_remaining = 1.00*last_full_capacity/present_rate
    hours = 0
    while(time_remaining >= 1):
        hours += 1
        time_remaining -= 1
    minutes = int(time_remaining * 60)
    time_remaining = (hours, minutes)
else:
    time_remaining = ''

battery_health = (last_full_capacity/design_capacity)


#Create return string

#You can add your own substitutions into this dictionary.
#the value must be a string
substitutions = { 'S' : str(charging_state),
                  't' : "%sh,%sm" % (time_remaining[0], time_remaining[1]),
                  'R' : str(remaining_capacity),
                  'v' : str(present_voltage),
                  'V' : str(design_voltage),
                  'r' : str(int(present_rate/1000)) + 'W',
                  'h' : str(battery_health) + '%',
                  }
#The real substitution happens here
substitute_next = False
escaped = False
result = ""
for i in xrange(0,len(target_string)):
    if substitute_next:
        substitute_next = False
        if substitutions.has_key(target_string[i]):
            result += substitutions[target_string[i]]
        else:
            print "Can't parse your string"
            print "maybe you haven't escaped the '%' sign? Escape it with '\\%'"
            sys.exit(1)
    elif target_string[i] == '%' and not escaped:
        substitute_next = True
    else:
        escaped = False
        if target_string[i] == '\\':
            escaped = True
        else:
            result += target_string[i]

print result
