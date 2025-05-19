#!/bin/bash

source lib/common.lib

f_checkAndSetBuildTimestamp ""

typeset output_filename=$(f_getRunOutputFilename_Helper "val_participation_check")
{
	# cmdline param
	typeset num_epochs_to_check=$1

	if [[ -z $num_epochs_to_check ]]; then
		echo "need a number!"
		echo "num_epochs_to_check=$num_epochs_to_check"
		exit
	fi

	typeset sealed_epoch=$(f_opera_getSealedEpoch)
	typeset stop_epoch=$((sealed_epoch-num_epochs_to_check))
	
	for ((epoch=$sealed_epoch; epoch>$stop_epoch; epoch--)); do 
		typeset validator_id_list=$(f_opera_getEpochValidatorIds "$epoch")
		echo "|$epoch| $validator_id_list"
	done

} 2>&1 | tee $output_filename
