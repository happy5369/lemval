#!/bin/bash

source lib/common.lib

f_checkAndSetBuildTimestamp ""

typeset output_filename=$(f_getRunOutputFilename_Helper "consensus_check")
{
	typeset num_epochs_to_check=$1

	typeset sealed_epoch=$(f_opera_getSealedEpoch)
	typeset stop_epoch=$((sealed_epoch-num_epochs_to_check))
	
	for ((i=$sealed_epoch; i>$stop_epoch; i--)); do 
		typeset validator_id_list=$(f_opera_getEpochValidatorIds "$i")
		echo "|$i| $validator_id_list"
	done

} 2>&1 | tee $output_filename
