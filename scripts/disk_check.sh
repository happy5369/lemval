#!/bin/bash

source lib/common.lib

diffsOnly=true

while [[ 1 ]]; do
	current=`df -H | grep sda2`
	if [[ $diffsOnly == false || ($diffsOnly == true && "$current" != "$previous") ]]; then		
		f_printDate
		echo $current
	fi
	
	previous=$current
	sleep 1m;
done
