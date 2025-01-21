#!/bin/bash

source lib/common.lib

f_checkAndSetBuildTimestamp "$1"

typeset output_filename=$(f_getRunOutputFilename_Helper "rewards2")
{
	typeset decimal_places=4
	typeset previous_rewards=0

	while [[ 1 ]]; do
		current_epoch=$(~/go-opera/build/opera attach --preload /extra/preload.js --datadir=/extra/lemon/data --exec "sfcc.currentEpoch();")
		
		if [[ $previousEpoch != $current_epoch ]]; then
			pending_rewards=$(f_getRewards $ADDRESS $VALIDATOR_ID)
			f_printRewards $pending_rewards $previous_rewards $decimal_places "true"
			previous_rewards=$pending_rewards
		fi
		
		previous_epoch=$current_epoch
		sleep 5m;
	done
} 2>&1 | tee $output_filename
