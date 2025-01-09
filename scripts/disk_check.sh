#!/bin/bash

while [[ 1 ]]; do
	echo -n "[`date "+%m/%d %T"`] "
	df -H | grep sda2
	
	sleep 1h;
done
