#!/bin/bash

LEMON_DATA_DIR="/extra/lemon/data/"

KEY_FROM_DATA="0x$(basename $LEMON_DATA_DIR/keystore/validator/*)"
KEY_FROM_FILE=$(grep 'public_key=' ~/start_node.bash | sed 's#public_key=##')

echo "Comparing Addresses"
if [ "$KEY_FROM_DATA" = "$KEY_FROM_FILE" ]; then
	echo "MATCH"
else
	echo "**MISMATCH**"
fi
echo -e "\t$KEY_FROM_DATA"
echo -e "\t$KEY_FROM_FILE"

ADDRESS="0x$(ls -l $LEMON_DATA_DIR/keystore/ | awk '/UTC--/ { split($9, arr, "--"); print arr[length(arr)] }')"

# can't use ~/go-opera... for whatever reason you'll get "~/go-opera/build/opera: No such file or directory"
# also don't quote "$operaCmd" you'll get the same thing
operaCmd="$HOME/lemon/val-install/go-opera/build/opera attach --preload /extra/preload.js --datadir=$LEMON_DATA_DIR --exec"

   VALIDATOR_ID=`$operaCmd "sfcc.getValidatorID('$ADDRESS');"`	# quotes - single or double is important around $ADDRESS!
          STATS=`$operaCmd "sfcc.getValidator($VALIDATOR_ID);"`
 KEY_FROM_CHAIN=`$operaCmd "sfcc.getValidatorPubkey($VALIDATOR_ID);"`
PENDING_REWARDS=`$operaCmd "sfcc.pendingRewards('$ADDRESS', $VALIDATOR_ID);"`
        SLASHED=`$operaCmd "sfcc.isSlashed($VALIDATOR_ID);"`
        LAST_ID=`$operaCmd "sfcc.lastValidatorID();"`
  CURRENT_EPOCH=`$operaCmd "sfcc.currentEpoch();"`
 CURRENT_SEPOCH=`$operaCmd "sfcc.currentSealedEpoch();"`
 CURRENT_DEPOCH=`$operaCmd "sfcc.delegationLockPeriodEpochs();"`
 stake=`$operaCmd "sfcc.minSelfStake('$ADDRESS');"`

echo
echo "Wallet:          $ADDRESS"
echo "ValidatorId:     $VALIDATOR_ID"
echo "Key_data:        $KEY_FROM_DATA"
echo "Key_file:        $KEY_FROM_FILE"
echo "Key_chain:       $KEY_FROM_CHAIN"
echo "Stats:           $STATS"
echo "Pending rewards: $PENDING_REWARDS"
echo "Slashed?:        $SLASHED"
echo "LastValidatorId: $LAST_ID"
echo "Current Epoch:   $CURRENT_EPOCH"
echo "Current SEpoch:  $CURRENT_SEPOCH"
echo "Current DEpoch:  $CURRENT_DEPOCH"
echo "mss:  $stake"
