#!/bin/bash

source lib/common.lib

f_checkAndSetBuildTimestamp "$1"

# sample is 207: [1, 1731593222, 500, 0, 349, 1729363734, "0xb67d4160090c1810cb6aaf062e1178de58691117"]
# which I think ... 0=active/dead[1,8], 1=timestamp_dead, 2=epoch_dead, 3=tokens_staked, 4=epoch_alive, 5=timestamp_alive, 6=address

typeset output_filename=$(f_getRunOutputFilename_Helper "get_all_vals_stats")
{
	typeset last_id=$(f_opera_getLastValidatorId)

	for val_id in $(seq 1 $last_id); do 
		typeset validator=$(f_opera_getValidator "$val_id")
		echo "$val_id: $validator"
	done
} 2>&1 | tee $output_filename
