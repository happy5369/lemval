#!/bin/bash

source lib/common.lib

f_checkAndSetBuildTimestamp "$1"

typeset output_filename=$(f_getRunOutputFilename_Helper "rewards2")
{
	typeset decimal_places=4
	typeset previous_rewards=0
	typeset previous_epoch=0

	while [[ 1 ]]; do
		current_epoch=$(~/go-opera/build/opera attach --preload /extra/preload.js --datadir=/extra/lemon/data --exec "sfcc.currentEpoch();")
		
		if [[ $previousEpoch != $current_epoch ]]; then
			pending_rewards=$(f_getRewards $LEM_ADDRESS $LEM_VALIDATOR_ID)
			f_printRewards $pending_rewards $previous_rewards $previous_epoch $decimal_places "true"
			
			previous_rewards=$pending_rewards
			previous_epoch=$current_epoch
		fi
		
		sleep 1m;
	done
} 2>&1 | tee $output_filename
