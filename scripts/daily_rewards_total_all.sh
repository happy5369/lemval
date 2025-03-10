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
	
	typeset staked_pool=20000
	typeset locked_pool=200000
	typeset yearly_expected=$((staked_pool+locked_pool))
	typeset daily_expected=$(f_compute "$yearly_expected/365")
	
	echo "========== Expected =========="
	echo "$yearly_expected"
	echo "$daily_expected"
	
	while [[ 1 ]]; do
		typeset total_daily=`f_getRewardsPayoutTotal "$LEM_TMP_AREA/$filename" "$current_epoch"`
		total_daily=`f_compute "$total_daily/.65"`	# add in delegators as well
		typeset total_yearly=`f_compute "$total_daily*365"`
		
		typeset diff_daily=$(f_compute "$total_daily-$daily_expected")
		typeset diff_yearly=$(f_compute "$total_yearly-$yearly_expected")
		
		f_printDate
		printf "|%-4s| %4.3f %6.3f (%2.2f %s)\n" "$current_epoch" "$total_daily" "$total_yearly" "$diff_daily" "$diff_yearly"
		
		current_epoch=`grep -F '-' $LEM_TMP_AREA/$filename | tail -n 1 | cut -d ' ' -f3 | tr -d '|'`
		
		sleep 24h;
	done
	
} 2>&1 | tee $output_filename
