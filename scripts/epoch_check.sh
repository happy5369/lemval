#!/bin/bash

source lib/common.lib

f_checkAndSetBuildTimestamp "$1"

typeset output_filename=$(f_getRunOutputFilename_Helper "epoch")
{
	while [[ 1 ]]; do
		current_epoch=$(f_opera_getEpoch)
		current_time=`date +%s`
		
		if [[ $previous_epoch != $current_epoch ]]; then
			# time
			epoch_time_length=$(((current_time-previous_time)/60))
			previous_time=$current_time
			
			# blocks
			current_block=$(f_runOpera "ftm.blockNumber;")
			blocks=$((current_block-previous_block))
			previous_block=$current_block
			
			# staked
			current_staked=$(f_runOpera "sfcc.totalStake();")
			current_staked=$(f_convertLemNumber "$current_staked")
			current_staked=$(f_round "$current_staked" "0")	# no decimals 
			staked=$((current_staked-previous_staked))
			previous_staked=$current_staked
			
			# vals
			current_vals=$(f_getTotalActiveVals)
			vals=$((current_vals-previous_vals))
			previous_vals=$current_vals
			if [[ $vals -eq 0 ]]; then
				vals=""
			fi
		
			f_printDate
			printf "|%-4s| %3sm %-4s %-4s $vals\n" "$previous_epoch" "$epoch_time_length" "$blocks" "$staked"
			
			previous_epoch=$current_epoch
		fi
		
		sleep 1m;
	done
} 2>&1 | tee $output_filename
