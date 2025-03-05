#!/bin/bash

source lib/common.lib

f_checkAndSetBuildTimestamp ""

typeset output_filename=$(f_getRunOutputFilename_Helper "rewards_total_all")
{
	# cmdline param
	typeset filename=$1
	typeset epoch_number=$2

	f_getRewardsPayoutTotal "$LEM_TMP_AREA/$filename" "$epoch_number" "true"
	
} 2>&1 | tee $output_filename
