#!/bin/bash

source ./common.lib

# https://www.theunixschool.com/2012/05/different-ways-to-print-next-few-lines.html
# https://stackoverflow.com/questions/2702564/how-can-i-quickly-sum-all-numbers-in-a-file

function f_print {
	text=$1
	value=$2
	
	printf "%-9s: %s\n" "$text" "$value"
}

function f_sumLineCount {
	lines=$1
	
	echo `echo "$lines" | sed "s#,##" | paste -sd+ | bc` # bc doesn't like having commas
}

function f_printTen {
	ten=$1
	direction=$2
	totalLemx=$3
	
	tenCount=$(f_sumLineCount "$ten")
	tenPercentRound=$(f_round $(f_compute "$tenCount / $totalLemx * 100"))
	echo
	echo "$direction Ten (${tenCount}lemx | ${tenPercentRound}%)"
	echo "$ten"
}

vals=`grep -A1 Delegation dashboard-validator-info.txt | grep LEMX | sed s#LEMX##`
numvals=`echo "$vals" | wc -l`
myStake=`echo "$vals" | tail -n 1`
#myStake=21
totalLemxWithMineTwice=$(f_sumLineCount "$vals")
totalLemx=$((totalLemxWithMineTwice-myStake))
myPercent=$(f_compute "$myStake / $totalLemx")

f_print "# of vals" $numvals
f_print "# of lemx" $totalLemx
f_print "# my lemx" $myStake
f_print "my %" $myPercent

oneBillion=1000000000
myEarning=$(f_compute "$oneBillion *.01 * $myPercent")
myEarningRound=$(f_round "$myEarning")
echo
echo "Assuming 
- 1B USD transaction
- 1% fees to vals"
echo
f_print "return" "\$${myEarningRound} (1B*1%*$myPercent)"

lemxValue=60
totalInvestment=$(f_compute "$lemxValue * $myStake")
roiMultiple=$(f_compute "$myEarning / $totalInvestment")
roiPercent=$(f_compute "($roiMultiple - 1) * 100")
roiMultipleRound=$(f_round "$roiMultiple")
roiPercentRound=$(f_round "$roiPercent")
f_print "initial" "\$${totalInvestment}"
f_print "ROI" "${roiMultipleRound}x (${roiPercentRound}%)"

f_print "# of vals < 50 lemx" "`echo "$vals" | grep -E ^10 | grep -v 100 | wc -l`"

topTen=`echo "$vals" | sort -rn | head -n 10`
f_printTen "$topTen" "Top" "$totalLemx"

bottomTen=`echo "$vals" | sort -n | head -n 10`
f_printTen "$bottomTen" "Bottom" "$totalLemx"
