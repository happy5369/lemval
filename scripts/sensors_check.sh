#!/bin/bash

source lib/common.lib

typeset diffs_only=true

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
		sleep 10s;
	done
} 2>&1 | tee $output_filename
