#!/bin/bash

source lib/common.lib

f_checkAndSetBuildTimestamp "$1"

typeset output_filename=$(f_getRunOutputFilename_Helper "rewards2")
{
	typeset decimal_places=4
	typeset previous_rewards=0
	typeset previous_epoch=0

	if [[ -z $LEM_ADDRESS || -z $LEM_VALIDATOR_ID ]]; then
		echo "LEM_ADDRESS AND LEM_VALIDATOR_ID BOTH need to be set!"
		echo "LEM_ADDRESS=$LEM_ADDRESS"
		echo "LEM_VALIDATOR_ID=$LEM_VALIDATOR_ID"
		exit
	fi
	
	while [[ 1 ]]; do
		current_epoch=$(f_opera_getEpoch)
		
		if [[ $previousEpoch != $current_epoch ]]; then
			pending_rewards=$(f_opera_getRewards $LEM_ADDRESS $LEM_VALIDATOR_ID)
			
			typeset         getStake=$(f_opera_getStake $LEM_ADDRESS $LEM_VALIDATOR_ID)
			typeset getUnlockedStake=$(f_opera_getUnlockedStake $LEM_ADDRESS $LEM_VALIDATOR_ID)
			typeset   getLockedStake=$(f_opera_getLockedStake $LEM_ADDRESS $LEM_VALIDATOR_ID)
			typeset     getDelegated=$(f_opera_getDelegated $LEM_VALIDATOR_ID)
			
			f_printRewards "$LEM_VALIDATOR_ID" "$pending_rewards" "$previous_rewards" "$previous_epoch" "$getStake" "$getUnlockedStake" "$getLockedStake" "$getDelegated" "$decimal_places" "true"
			
			previous_rewards=$pending_rewards
			previous_epoch=$current_epoch
		fi
		
		sleep 1m;
	done
} 2>&1 | tee $output_filename
