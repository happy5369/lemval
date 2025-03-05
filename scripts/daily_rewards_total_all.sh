#!/bin/bash

source lib/common.lib

f_checkAndSetBuildTimestamp ""

typeset output_filename=$(f_getRunOutputFilename_Helper "daily_rewards_total_all")
{
	# cmdline param
	typeset filename=$1
	if [[ -z $filename ]]; then
		echo "filename needs to be set!"
		echo "filename=$filename"
		exit
	fi
	
	typeset current_epoch=0
	
	while [[ 1 ]]; do
		typeset total=`f_getRewardsPayoutTotal "$LEM_TMP_AREA/$filename" "$current_epoch"`
		
		f_printDate
		printf "|%-4s| %4s\n" "$current_epoch" "$total"
		
		current_epoch=`grep -F '-' $LEM_TMP_AREA/$filename | tail -n 1 | cut -d ' ' -f3 | tr -d '|'`
		
		sleep 24h;
	done
	
} 2>&1 | tee $output_filename
