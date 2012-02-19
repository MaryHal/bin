#!/bin/zsh

#Layout
BAR_H=8
BIGBAR_W=60
SMABAR_W=27
WIDTH=1280
HEIGHT=16
X_POS=0
Y_POS=0
FONT="-*-montecarlo-medium-r-normal-*-11-*-*-*-*-*-*-*"

#Colors
CRIT="#d74b73"
BAR_FG="#60a0c0"
BAR_BG="#363636"
DZEN_FG="#9d9d9d"
DZEN_FG2="#5f656b"
DZEN_BG="#050505"
COLOR_ICON="#60a0c0"
COLOR_SEP="#007b8c"

#Initialized variables
IFS='|' #internal field separator (conky)
ICONPATH="/home/nnoell/.icons/subtlexbm"
INTERVAL=1
CPUTemp=0
GPUTemp=0
CPULoad0=0
CPULoad1=0
NetUp=0
NetDown=0

printVolInfo() {
	perc=$(amixer get Master | grep "Mono:" | awk '{print $4}' | tr -d '[]%')
	mute=$(amixer get Master | grep "Mono:" | awk '{print $6}')
	if [[ $mute == "[off]" ]]; then
		echo -n "^fg($COLOR_ICON)^i($ICONPATH/volume_off.xbm)^fg()^fg($BAR_FG)^fg() off ^fg()$(echo $perc |gdbar -fg $CRIT -bg $BAR_BG -h $BAR_H -w $BIGBAR_W -ss 1 -sw 4 -nonl)"
		return
	else
		echo -n "^fg($COLOR_ICON)^i($ICONPATH/volume_on.xbm)^fg()^fg($BAR_FG)^fg() ${perc}% ^fg()$(echo $perc |gdbar -fg $BAR_FG -bg $BAR_BG -h $BAR_H -w $BIGBAR_W -ss 1 -sw 4 -nonl)"
	fi
	return
}

printCPUInfo() {
	echo -n "^fg($COLOR_ICON)^i($ICONPATH/cpu.xbm) ^fg()${CPULoad0}% ^fg()"$(echo $CPULoad0 | gdbar -fg $BAR_FG -bg $BAR_BG -h $BAR_H -w $SMABAR_W)" ^fg()${CPULoad1}% ^fg()$(echo $CPULoad1 | gdbar -fg $BAR_FG -bg $BAR_BG -h $BAR_H -w $SMABAR_W ) ${CPUFreq}GHz"
	return
}

printTempInfo() {
	CPUTemp=$(acpi --thermal | awk '{print substr($4,0,2)}')
	GPUTemp=$(nvidia-settings -q gpucoretemp |grep '):' | cut -d ' ' -f 6,6 | sed -e 's/.\{1\}$//')
	if [[ $((CPUTemp)) -gt 70 ]]; then
		CPUTemp="^fg($CRIT)"$CPUTemp"^fg()" 
	fi
	if [[ $((GPUTemp)) -gt 70 ]]; then
		GPUTemp="^fg($CRIT)"$GPUTemp"^fg()" 
	fi
	echo -n "^fg($COLOR_ICON)^i($ICONPATH/temp.xbm) ^fg($DZEN_FG2)cpu ^fg()${CPUTemp}c ^fg($DZEN_FG2)gpu ^fg()${GPUTemp}c"
	return
}

printMemInfo() {
	MemUsed=$(echo -n $MemUsed | tr -d 'i')
	echo -n "^fg($COLOR_ICON)^i($ICONPATH/memory.xbm) ^fg($BAR_FG)^fg()${MemUsed} $(echo $MemPerc | gdbar -fg $BAR_FG -bg $BAR_BG -h $BAR_H -w $SMABAR_W)"
	return
}

printFileInfo() {
	NPKGS=$(pacman -Q | wc -l)
	NPROC=$(expr $(ps -A | wc -l) - 1)
	echo -n "^fg($COLOR_ICON)^i($ICONPATH/pc.xbm) ^fg($DZEN_FG2)proc ^fg()$NPROC ^fg($DZEN_FG2)pkgs ^fg()$NPKGS"
	return
}

printBattery() {
	BatPresent=$(acpi -b | wc -l)
	ACPresent=$(acpi -a | grep on-line | wc -l)
	if [[ $ACPresent == "1" ]]; then
		echo -n "^fg($COLOR_ICON)^i($ICONPATH/ac1.xbm)"
	else
		echo -n "^fg($COLOR_ICON)^i($ICONPATH/battery_vert3.xbm)"
	fi
	if [[ $BatPresent == "0" ]]; then
		echo -n " ^fg($DZEN_FG2)AC ^fg()on ^fg($DZEN_FG2)Bat ^fg()off"
		return
	else
		RPERC=$(acpi -b | awk '{print $4}' | tr -d "%,")
#		RSTATE=$(acpi -b | awk '{print $3}' | tr -d ",")
		if [[ $ACPresent == "1" ]]; then
			echo -n "^fg() $RPERC% $(echo $RPERC | gdbar -fg $BAR_FG -bg $BAR_BG -h $BAR_H -w $BIGBAR_W -ss 1 -sw 4 -nonl)"
		else
			echo -n "^fg() $RPERC% $(echo $RPERC | gdbar -fg $CRIT -bg $BAR_BG -h $BAR_H -w $BIGBAR_W -ss 1 -sw 4 -nonl)"
		fi
	fi
	return
}

printDiskInfo() {
	RFSP=$(df -h / | tail -1 | awk -F' ' '{ print $5 }' | tr -d '%')
	BFSP=$(df -h /boot | tail -1 | awk -F' ' '{ print $5 }' | tr -d '%')
	if [[ $((RFSP)) -gt 70 ]]; then
		RFSP="^fg($CRIT)"$RFSP"^fg()"
	fi
	if [[ $((BFSP)) -gt 70 ]]; then
		BFSP="^fg($CRIT)"$BFSP"^fg()"
	fi
	echo -n "^fg($COLOR_ICON)^i($ICONPATH/file1.xbm) ^fg($DZEN_FG2)root ^fg()${RFSP}% ^fg($DZEN_FG2)boot ^fg()${BFSP}%"
}

printKerInfo() {
#	uptime=$(cut -d'.' -f1 /proc/uptime)
#	secs=$((${uptime}%60))
#	mins=$((${uptime}/60%60))
#	hours=$((${uptime}/3600%24))
#	days=$((${uptime}/86400))
#	uptime="^fg()${mins}^fg(#444)m ^fg()${secs}^fg(#444)s"
#	if [ "${hours}" -ne "0" ]; then
#	  uptime="^fg()${hours}^fg(#444)h ^fg()${uptime}"
#	fi
#	if [ "${days}" -ne "0" ]; then
#	  uptime="^fg()${days}^fg(#444)d ^fg()${uptime}"
#	fi
	echo -n " ^fg()$(uname -r)^fg(#007b8c)/^fg(#5f656b)$(uname -m) ^fg(#a488d9)| ^fg()$Uptime"
	return
}

printDateInfo() {
	echo -n "^fg()$(date '+%Y^fg(#444).^fg()%m^fg(#444).^fg()%d^fg(#007b8c)/^fg(#5f656b)%a ^fg(#a488d9)| ^fg()%H^fg(#444):^fg()%M^fg(#444):^fg()%S')"
	return
}

printSpace() {
	echo -n " ^fg($COLOR_SEP)|^fg() "
	return
}

printArrow() {
	echo -n " ^fg(#a488d9)>^fg(#007b8c)>^fg(#444444)> "
	return
}

printBar() {
	while true; do
		read CPULoad0 CPULoad1 CPUFreq MemUsed MemPerc Uptime
		printKerInfo
		printSpace
		printCPUInfo
		printSpace
		printMemInfo
		printArrow
		echo -n "^pa(492)"
		printDiskInfo
		printSpace
		printFileInfo
		printSpace
		printTempInfo
		printSpace
		printBattery
		printSpace
		printVolInfo
		printArrow
		echo -n "^pa(1125)"
		printDateInfo
		echo
	done
	return
}

#Print all and pipe into dzen
#conky -c /home/nnoell/.conky/conkyrc -u $INTERVAL | printBar | dzen2 -x $X_POS -y $Y_POS -w $WIDTH -h $HEIGHT -fn $FONT -ta 'l' -bg $DZEN_BG -fg $DZEN_FG -p -e ''
conky -c -u $INTERVAL | printBar | dzen2 -x $X_POS -y $Y_POS -w $WIDTH -h $HEIGHT -fn $FONT -ta 'l' -bg $DZEN_BG -fg $DZEN_FG -p -e ''
