#!/bin/bash

source lib/common.lib

f_checkAndSetBuildTimestamp ""

typeset output_filename=$(f_getRunOutputFilename_Helper "daily_rewards_total_all")
{
	# cmdline param
	typeset filename=$1
	typeset current_epoch=$2
	
	if [[ -z $filename ]]; then
		echo "filename needs to be set! AND it needs to be a 'rewards_check_active_vals.out' file to parse!"
		echo "filename=$filename"
		exit
	fi
	
	filename=$(f_resolveFilename "$filename")
	
	if [[ -z $current_epoch ]]; then
		current_epoch=0
	fi
	
	typeset staked_pool=25000
	typeset locked_pool=250000
	typeset yearly_expected=$((staked_pool+locked_pool))
	typeset daily_expected=$(f_compute "$yearly_expected/365")
	
	echo "========== Expected =========="
	echo "$yearly_expected"
	echo "$daily_expected"
	
	while [[ 1 ]]; do
		typeset total_daily=`f_getRewardsPayoutTotal "$filename" "$current_epoch"`
		typeset vals_staked=$(f_opera_getTotalValStake) # FIXME: this doesn't really work for passed in epochs b/c it doesn't go back in time capture what the amount was, it'll get maybe an accurate val list at the time, but it'll use those vals to then get the current delegation for those vals not the delegation at that epoch
		typeset total_staked=$(f_convertLemNumber $(f_opera_getTotalStake))

		echo "val   stake: $vals_staked"
		echo "total stake: $total_staked"
		typeset total_delegated=`f_compute "$total_staked - $vals_staked"`
		typeset percent_vals_get_of_delegators=.35
		typeset total_coin_power=`f_compute "$total_delegated*$percent_vals_get_of_delegators + $vals_staked"`
		typeset total_coin_power_percentage=`f_compute "$total_coin_power / $total_staked"`
		echo 
		
		total_daily=`f_compute "$total_daily/$total_coin_power_percentage"`	# divide by total_power b/c X rewards went to X% vals, so then X/X% = what went to ALL, i.e. if 100 lemx went to vals and vals are 60% power, then 100/.6 = 166.67 went to everyone
		typeset total_yearly=`f_compute "$total_daily*365"`
		
		typeset diff_daily=$(f_compute "$total_daily-$daily_expected")
		typeset diff_yearly=$(f_compute "$total_yearly-$yearly_expected")
		
		f_printDate
		printf "|%-4s| %7.3f %10.3f (%6.2f %9.2f)\n" "$current_epoch" "$total_daily" "$total_yearly" "$diff_daily" "$diff_yearly"
		
		current_epoch=`grep -F -- '---' "$filename" | tail -n 1 | cut -d ' ' -f3 | tr -d '|'`
		
		sleep 24h;
	done
	
} 2>&1 | tee $output_filename
