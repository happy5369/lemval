#!/bin/bash

source lib/common.lib

ADDRESS=0x
VALIDATOR_ID=

decimalPlaces=4
previousRewards=0	# need to set this to something can't leave blank, b/c it messes with param list below if empty (one less param into f_printRewards, even if you quote it -- "$var"), altho it's just the first go round so doesn't really matter honestly, since on 2nd round it catches up...

while [[ 1 ]]; do
	pendingRewards=$(f_getRewards $ADDRESS $VALIDATOR_ID)
	f_printRewards $pendingRewards $previousRewards $decimalPlaces ""
	previousRewards=$pendingRewards
	sleep 1h;
done
