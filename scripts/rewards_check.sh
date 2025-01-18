#!/bin/bash

source ./common.lib

ADDRESS=0x
VALIDATOR_ID=

decimalPlaces=4

while [[ 1 ]]; do
	echo -n "[`date "+%m/%d %T"`] "
	PENDING_REWARDS=$(~/go-opera/build/opera attach --preload /extra/preload.js --datadir=/extra/lemon/data --exec "sfcc.pendingRewards('$ADDRESS', $VALIDATOR_ID);")
	
	diff=$((PENDING_REWARDS-previousRewards))
	computed=$(f_compute "$PENDING_REWARDS / 10^18")
	rounded=$(f_round $computed $decimalPlaces)
	echo "$rounded $PENDING_REWARDS (+$diff)"
	
	previousRewards=$PENDING_REWARDS
	sleep 1h;
done
