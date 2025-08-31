#!/bin/bash

# need
# sudo apt install smartmontools
# sudo apt install lm-sensors

source lib/common.lib

function f_compare {
	typeset       val=$1
	typeset threshold=$2
	
	if [ 1 -eq "$(echo "$val > $threshold" | bc)" ]; then
		echo "true"
	else
		echo ""	# empty string is false in bash, if I did "false" that would still resolve to true in an if-statement conditional
	fi
}

typeset diffs_only=false

f_checkAndSetBuildTimestamp "$1"

typeset output_filename=$(f_getRunOutputFilename_Helper "sensors")
{
	while [[ 1 ]]; do
		read core0 core1 nvme < <(sensors | awk '
			/^Core 0:/ {core0=$3+0}
			/^Core 1:/ {core1=$3+0}
			/^Composite:/ {nvme=$2; gsub(/\+|°C/,"",nvme)}
			END {print core0, core1, nvme}')
			
		typeset ssd=$(sudo smartctl -A /dev/sda | awk '/194 Temperature/ {print $10}')
		current="cpus ($core0 / $core1), ssd ($ssd), nvme ($nvme)"
		
		if [[ $diffs_only == false || ($diffs_only == true && "$current" != "$previous") ]]; then		
			f_printDate
			echo $current
		fi
		
		previous=$current
		
		
		if [[   $(f_compare "$core0" "90") || $(f_compare "$core1" "90") || $(f_compare "$ssd" "50") || $(f_compare "$nvme" "60") ]]; then
			sleep 10s;	# hot
		elif [[ $(f_compare "$core0" "75") || $(f_compare "$core1" "75") || $(f_compare "$ssd" "45") || $(f_compare "$nvme" "45") ]]; then
			sleep 20s;	# warming up
		else
			sleep 60s;	# tame
		fi
	done
} 2>&1 | tee $output_filename
