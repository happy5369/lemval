#!/bin/bash

source lib/common.lib

ADDRESS=0x
VALIDATOR_ID=

decimalPlaces=4
previousRewards=0

while [[ 1 ]]; do
	CURRENT_EPOCH=$(~/go-opera/build/opera attach --preload /extra/preload.js --datadir=/extra/lemon/data --exec "sfcc.currentEpoch();")
	
	if [[ $previousEpoch != $CURRENT_EPOCH ]]; then
		pendingRewards=$(f_getRewards $ADDRESS $VALIDATOR_ID)
		f_printRewards $pendingRewards $previousRewards $decimalPlaces "true"
		previousRewards=$pendingRewards
	fi
	
	previousEpoch=$CURRENT_EPOCH
	sleep 5m;
done
