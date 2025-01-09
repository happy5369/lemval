#!/bin/bash

function f_printUp {
	text=$1
	
	f_colorPrint "${text}_UP" "GREEN"
}

function f_printDown {
	text=$1
	
	f_colorPrint "${text}_DOWN" "RED"
}

function f_colorPrint {
	text=$1
	color=$2
	
	red='\e[31m'
	green='\e[32m'
	no_color='\e[0m'
	
	if [[ $color == "GREEN" ]]; then
		color=$green
	elif [[ $color == "RED" ]]; then
		color=$red
	fi
	
	#echo -en "${color}$text${no_color} "
	printf "${color}%-6s${no_color} " "$text"
}

echo "DATE             P      V      BLOCK BLOCKS_DIFF"
echo "================================================"

num_processes=`ps auxww | grep opera | grep validator | wc -l`

while [[ 1 ]]; do
	#echo -n "`date +"%D %r"` - "
	echo -n "[`date "+%m/%d %T"`] "

	if [[ $num_processes -eq 1 ]]; then
		f_printUp "P"

		 dagSummary=`tail ~/nohup.validator -n 100 | grep "New DAG summary" | wc -l`
		 llrSummary=`tail ~/nohup.validator -n 100 | grep "New LLR summary" | wc -l`
	    	      block=`tail ~/nohup.validator -n 500 | grep "New block"       | wc -l`
		latestBlock=`tail ~/nohup.validator -n 500 | grep "New block"       | tail -n 1 | awk '{print $5}' | sed s#index=##`
		if [[ $dagSummary -ge 1 && $llrSummary -ge 1 && $block -ge 1 ]]; then
			f_printUp "V"
		else
			f_printDown "V"
		fi
		
		blocks=$((latestBlock-secondLatestBlock))
		echo "$latestBlock (+$blocks)"
	else
		f_printDown "P"
	fi
	
	secondLatestBlock=$latestBlock
	sleep 1h;
done
