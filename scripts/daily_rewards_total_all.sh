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
	
	typeset percent_vals_get_of_delegators=.35
	
	echo "========== Expected =========="
	echo "$yearly_expected"
	echo "$daily_expected"
	
	while [[ 1 ]]; do
		typeset total_vals=`f_getRewardsPayoutTotal "$filename" "$current_epoch"`
		typeset total_coin_power=`f_getTotalCoinPower "$filename" "$current_epoch"`
		typeset total_staked=`f_getTotalStaked "$filename" "$current_epoch"`
		typeset total_coin_power_fraction=`f_compute "$total_coin_power / $total_staked"`
		
		typeset total_daily=`f_compute "$total_vals/$total_coin_power_fraction"`	# divide by total_power b/c X rewards went to X% vals, so then X/X% = what went to ALL, i.e. if 100 lemx went to vals and vals are 60% power, then 100/.6 = 166.67 went to everyone		
		# *** Note the payouts here WOULD include gas fees, so for a more accurate payout from pools, you would want to then subtract last 24 hours of gas fees from total_daily
		
		typeset total_dels=`f_compute "$total_daily - $total_vals"`
		
		typeset total_yearly=`f_compute "$total_daily*365"`
		
		typeset diff_daily=$(f_compute "$total_daily-$daily_expected")
		typeset diff_yearly=$(f_compute "$total_yearly-$yearly_expected")
		
		typeset total_val_percentage=`f_compute "$total_coin_power_fraction * 100"`
		typeset total_delegation_percentage=`f_compute "100 - $total_val_percentage"`
		
		f_printDate
		printf "|%-4s| %7.3f[%.0f %.0f] %10.3f (%6.2f %9.2f) %s:%s\n" "$current_epoch" "$total_daily" "$total_vals" "$total_dels" "$total_yearly" "$diff_daily" "$diff_yearly" "$total_val_percentage" "$total_delegation_percentage"
		
		current_epoch=`grep -F -- '---' "$filename" | tail -n 1 | cut -d ' ' -f3 | tr -d '|'`
		
		sleep 24h;
	done
	
} 2>&1 | tee $output_filename
