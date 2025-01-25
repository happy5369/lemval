#!/bin/bash

source lib/common.lib

f_checkAndSetBuildTimestamp "$1"

typeset output_filename=$(f_getRunOutputFilename_Helper "rewards")
{
	typeset decimal_places=4
	typeset previous_rewards=0	# need to set this to something can't leave blank, b/c it messes with param list below if empty (one less param into f_printRewards, even if you quote it -- "$var"), altho it's just the first go round so doesn't really matter honestly, since on 2nd round it catches up...

	while [[ 1 ]]; do
		pending_rewards=$(f_getRewards $ADDRESS $VALIDATOR_ID)
		f_printRewards $pending_rewards $previous_rewards "." $decimal_places "false"
		
		previous_rewards=$pending_rewards
		
		sleep 1h;
	done
} 2>&1 | tee $output_filename
