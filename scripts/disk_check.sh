#!/bin/bash

source lib/common.lib

typeset diffs_only=true

f_checkAndSetBuildTimestamp "$1"

typeset output_filename=$(f_getRunOutputFilename_Helper "disk")
{
	while [[ 1 ]]; do
		current=`df -H | grep sda2`
		if [[ $diffs_only == false || ($diffs_only == true && "$current" != "$previous") ]]; then		
			f_printDate
			echo $current
		fi
		
		previous=$current
		sleep 1m;
	done
} 2>&1 | tee $output_filename
