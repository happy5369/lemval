#!/bin/bash

source lib/common.lib

typeset diffs_only=true

typeset output_filename=$(f_getRunOutputFilename_Helper "sensors_hot")
{
	# cmdline param
	typeset filename=$1

	if [[ -z $filename ]]; then
		echo "need a sensors file to check!"
		echo "filename=$filename"
		exit
	fi
	
	tail -f $filename | awk '
	  function red(text) { return "\033[31m" text "\033[0m" }
	  {
	    match($0, /cpus \(([0-9.]+) *\/ *([0-9.]+)\)/, c)
	    match($0, /ssd \(([0-9.]+)\)/, s)
	    match($0, /nvme \(([0-9.]+)\)/, n)

	    cpu1    = c[1] + 0; 
	    cpu2    = c[2] + 0;
	    ssdVal  = s[1] + 0; 
	    nvmeVal = n[1] + 0;

	    line = $0

	    # Color cpu numbers if > 90, preserving space around "/"
	    if (cpu1 > 90)
	      gsub("cpus \\(" c[1], "cpus (" red(c[1]), line)
	    if (cpu2 > 90)
	      gsub("/ *" c[2], "/ " red(c[2]), line)

	    # Color ssd number if > 50
	    if (ssdVal > 50)
	      gsub("ssd \\(" s[1], "ssd (" red(s[1]), line)

	    # Color nvme number if > 60
	    if (nvmeVal > 60)
	      gsub("nvme \\(" n[1], "nvme (" red(n[1]), line)

	    if (cpu1 > 90 || cpu2 > 90 || ssdVal > 50 || nvmeVal > 60)
	      print line
	  }
	'
} 2>&1 | tee $output_filename
