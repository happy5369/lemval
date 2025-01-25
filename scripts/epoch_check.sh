#!/bin/bash

source lib/common.lib

f_checkAndSetBuildTimestamp "$1"

typeset output_filename=$(f_getRunOutputFilename_Helper "epoch")
{
	while [[ 1 ]]; do
		current_epoch=$(~/go-opera/build/opera attach --preload /extra/preload.js --datadir=/extra/lemon/data --exec "sfcc.currentEpoch();")
		current_time=`date +%s`
		
		if [[ $previous_epoch != $current_epoch ]]; then
			current_block=$(~/go-opera/build/opera attach --preload /extra/preload.js --datadir=/extra/lemon/data --exec "ftm.blockNumber;")
			blocks=$((current_block-previous_block))
			previous_block=$current_block
		
			epoch_time_length=$(((current_time-previous_time)/60))
		
			echo "$previous_epoch: $blocks ${epoch_time_length}m"
			
			previous_epoch=$current_epoch
			previous_time=$current_time
		fi
		
		sleep 1m;
	done
} 2>&1 | tee $output_filename
