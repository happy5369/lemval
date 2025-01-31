#!/bin/bash

source lib/common.lib

function f_calculateRewards {
	typeset val_id=$1
	typeset val_address=$2
	typeset epoch=$3
	typeset decimal_places=$4
	
### bug ends here
	typeset previous_rewards=`grep "id=$val_id " < $tmp_file1 | awk '{print $6}'`	# if no match, then it's empty, which is 0, for first go around
	if [[ -z $previous_rewards ]]; then
		previous_rewards=0
	fi
	typeset pending_rewards=$(f_opera_getRewards $val_address $val_id)
	
	typeset         getStake=$(f_opera_getStake $val_address $val_id)
	typeset getUnlockedStake=$(f_opera_getUnlockedStake $val_address $val_id)
	typeset   getLockedStake=$(f_opera_getLockedStake $val_address $val_id)
	typeset     getDelegated=$(f_opera_getDelegated $val_id)
	
	
	#echo f_printRewards "$val_id" "$pending_rewards" "$previous_rewards" "$epoch" "$getStake" "$getUnlockedStake" "$getLockedStake" "$getDelegated" "$decimal_places" "true" >> /tmp/test.out
	
	f_printRewards "$val_id" "$pending_rewards" "$previous_rewards" "$epoch" "$getStake" "$getUnlockedStake" "$getLockedStake" "$getDelegated" "$decimal_places" "false"
}

f_checkAndSetBuildTimestamp "$1"

typeset active_vals_file="/tmp/active_vals.out"
typeset tmp_file1="/tmp/rewards_check_active_vals.out"
typeset tmp_file2="${tmp_file1}2"

typeset output_filename=$(f_getRunOutputFilename_Helper "rewards_check_active_vals")
{
	typeset previous_epoch=0
	rm $active_vals_file
	rm $tmp_file1
	rm $tmp_file2
	touch $tmp_file1

	while [[ 1 ]]; do
		current_epoch=$(f_opera_getEpoch)
		
		if [[ $previous_epoch != $current_epoch ]]; then
			f_writeActiveValsList "$active_vals_file"
			
			while IFS= read -r line
			do	
				typeset      val_id=`echo "$line" | awk '{print $1}' | tr -d ":"`
				typeset val_address=`echo "$line" | awk '{print $8}' | tr -d "\"" | tr -d "]"`
	### bug starts here
				typeset rewards=`f_calculateRewards "$val_id" "$val_address" "$previous_epoch" 4`
				echo "$rewards"	# quotes important or else it won't do printf formatting properly
				echo "$rewards" >> $tmp_file2
			done < "$active_vals_file"
			
			echo
			previous_epoch=$current_epoch
			rm $active_vals_file
			rm $tmp_file1
			mv $tmp_file2 $tmp_file1
		fi
		
		sleep 1m;
	done
} 2>&1 | tee $output_filename
