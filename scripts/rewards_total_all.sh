#!/bin/bash

source lib/common.lib

f_checkAndSetBuildTimestamp ""

typeset output_filename=$(f_getRunOutputFilename_Helper "rewards_total_all")
{
	# cmdline param
	typeset filename=$1
	typeset epoch_number=$2

	if [[ -z $filename || -z $epoch_number ]]; then
		echo "filename AND epoch_number needs to be set!"
		echo "filename=$filename"
		echo "epoch=$epoch_number"
		exit
	fi
	
	filename=$(f_resolveFilename "$filename")

	f_getRewardsPayoutTotal "$filename" "$epoch_number" "true"
	
} 2>&1 | tee $output_filename
