#!/bin/bash

source lib/common.lib

function f_calculateRewards {
	typeset val_id=$1
	typeset val_address=$2
	typeset epoch=$3
	typeset decimal_places=$4
	
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

function f_touchupFile {
	typeset file=$1
	
	sed -i 's#id=#xxxx#' $file
	sed -i 's#=# #g' $file
}

f_checkAndSetBuildTimestamp "$1"

typeset active_vals_file="/tmp/active_vals.out"
typeset tmp_file1="/tmp/rewards_check_active_vals.out"
typeset tmp_file2="${tmp_file1}2"
typeset tmp_file3="${tmp_file1}3"

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
				typeset rewards=`f_calculateRewards "$val_id" "$val_address" "$previous_epoch" 4`
				echo "$rewards"	# quotes important or else it won't do printf formatting properly 
				echo "$rewards" >> $tmp_file2
			done < "$active_vals_file"
			
			cp $tmp_file2 $tmp_file3
			f_touchupFile "$tmp_file3"
			typeset       total_sum=`awk '{s+=$5}END{print s}'  $tmp_file3`
			typeset       epoch_sum=`awk '{s+=$8}END{print s}'  $tmp_file3`
			typeset    total_staked=`awk '{s+=$12}END{print s}' $tmp_file3`
			typeset  total_unlocked=`awk '{s+=$14}END{print s}' $tmp_file3`
			typeset    total_locked=`awk '{s+=$16}END{print s}' $tmp_file3`
			typeset total_delegated=`awk '{s+=$18}END{print s}' $tmp_file3`
			typeset    total_shared=`awk '{s+=$20}END{print s}' $tmp_file3`
			#printf "rewards: total=%s, epoch=%s\n" "$total_sum" "$epoch_sum"
			typeset rewardsPrintoutFormat=`f_getRewardsPrintoutFormat`
			echo -n "---------------- "
			printf "$rewardsPrintoutFormat" "|$previous_epoch|" "" "$total_sum" "" "$epoch_sum" "" "$total_staked" "$total_unlocked" "$total_locked" "$total_delegated" "$total_shared"
			#printf "rewards: total=%s, epoch=%s\n" "$total_sum" "$epoch_sum" >> $tmp_file3
			#printf "staked:  total=%s, delegated=%s\n" "$total_staked" "$total_delegated"
			
			rm $tmp_file3
			
			echo
			previous_epoch=$current_epoch
			rm $active_vals_file
			rm $tmp_file1
			mv $tmp_file2 $tmp_file1
		fi
		
		sleep 1m;
	done
} 2>&1 | tee $output_filename
