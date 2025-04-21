#!/bin/bash

### run this right after midnight, should be able to be run anytime, but b/c of vnstat, we have to run after midnight, if that wasn't there, we could run anytime 

source lib/common.lib

f_checkAndSetBuildTimestamp "$1"

typeset output_filename=$(f_getRunOutputFilename_Helper "daily_stats")
{
	typeset previous_rewards=0

	while [[ 1 ]]; do
		typeset current_epoch=$(f_opera_getEpoch)
		typeset current_block=$(f_opera_getBlock)
		typeset current_staked=$(f_round $(f_convertLemNumber $(f_opera_getTotalStake)) "0")
		typeset current_vals=$(f_getTotalActiveVals)
		typeset current_disk=`du -Shcd 1 /extra 2>/dev/null | grep total | cut -f1 | sed 's#G##'`
		typeset current_rewards=$(f_convertLemNumber $(f_opera_getRewards "$LEM_ADDRESS" "$LEM_VALIDATOR_ID") 4)
		typeset current_peers=$(f_opera_getPeers)
		
		typeset epochs=$((current_epoch-previous_epoch))
		typeset blocks=$((current_block-previous_block))
		typeset staked=$((current_staked-previous_staked))
		typeset vals=$((current_vals-previous_vals))
		typeset peers=$((current_peers-previous_peers))
		typeset isSlashed=$(f_opera_isSlashed "$LEM_VALIDATOR_ID")
		typeset disk=$((current_disk-previous_disk))
		
		 in=`vnstat eno1 | grep yesterday | tr -s ' ' | awk '{print $2}'`
		out=`vnstat eno1 | grep yesterday | tr -s ' ' | awk '{print $5}'`

		blocks_per_epoch="na"
		if [[ $epochs -ne 0 ]]; then
			blocks_per_epoch=$((blocks / epochs))
		fi
		epochs_per_hour=$((epochs / 24))
		blocks_per_disk="na"
		days_till_disk_full="na"
		if [[ $disk -ne 0 ]]; then
			blocks_per_disk=$((blocks / disk))
			total_disk=`df -BG | tr -s ' ' | grep $LEM_STORAGE_DRIVE | cut -f2 -d ' ' | sed 's#G##'`	#cut -f4 would be disk_left not disk_total
			days_till_disk_full=$(((total_disk-current_disk) / disk))
		fi

		typeset rewards=$(f_compute "$current_rewards - $previous_rewards")
		typeset rewards_per_month=$(f_compute "$rewards * 30")
		typeset rewards_per_year=$(f_compute "$rewards_per_month * 12")
		typeset stake=$(f_convertLemNumber $(f_opera_getStake "$LEM_ADDRESS" "$LEM_VALIDATOR_ID") 0)
		typeset roi=$(f_round $(f_compute "$rewards_per_year / $stake"))
		
		typeset lemx_price=$(f_getLemxPrice)
		typeset rewards_dollars=$(f_round $(f_compute "$rewards * $lemx_price"))
		
		f_printDate
		printf "%5s(e) %7s(b) %3s(b/e) %3s(e/h) | %6s(lemx) %3s(v) %2s(p) %5s %3s(lemx) | %3s(G) %6s(b/d) %3s(dtf) | %6s(i) %6s(o) | \$\$ %6s($) %6s(lemx) %6s(mo) %6s(yr) %6sx(roi)\n" "$epochs" "$blocks" "$blocks_per_epoch" "$epochs_per_hour" "$staked" "$vals" "$peers" "$isSlashed" "$stake" "$disk" "$blocks_per_disk" "$days_till_disk_full" "$in" "$out" "$rewards_dollars" "$rewards" "$rewards_per_month" "$rewards_per_year" "$roi"
		
		previous_epoch=$current_epoch
		previous_block=$current_block
		previous_staked=$current_staked
		previous_vals=$current_vals
		previous_peers=$current_peers
		previous_disk=$current_disk
		previous_rewards=$current_rewards
			
		sleep 24h;
	done
} 2>&1 | tee $output_filename
