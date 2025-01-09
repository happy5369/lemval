ADDRESS=0x
VALIDATOR_ID=

while [[ 1 ]]; do
	echo -n "[`date "+%m/%d %T"`] "
	PENDING_REWARDS=$(~/go-opera/build/opera attach --preload /extra/preload.js --datadir=/extra/lemon/data --exec "sfcc.pendingRewards('$ADDRESS', $VALIDATOR_ID);")
	
	diff=$((PENDING_REWARDS-previousRewards))
	echo "$PENDING_REWARDS (+$diff)"
	
	previousRewards=$PENDING_REWARDS
	sleep 1h;
done
