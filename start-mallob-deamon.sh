#!/bin/bash

set -e

if ps aux|grep -q "[b]uild/mallob"; then
	echo "Mallob is already running."
	exit 0
fi

if [ -z $NUM_PROCESSES ]; then
	NUM_PROCESSES=1
	echo "NUM_PROCESSES not provided - using default"
fi
echo "Using NUM_PROCESSES=$NUM_PROCESSES"

if [ -z $NUM_THREADS_PER_PROCESS ]; then
	NUM_THREADS_PER_PROCESS=4
	echo "NUM_THREADS_PER_PROCESS not provided - using default"
fi
echo "Using NUM_THREADS_PER_PROCESS=$NUM_THREADS_PER_PROCESS"

outfile="../mallob-deamon-out.txt"
cd mallob
echo "" >> $outfile
echo "*****************************************************" >> $outfile
echo "Run at $(date)" >> $outfile
echo "*****************************************************" >> $outfile
nohup mpirun -np $NUM_PROCESSES -map-by numa:PE=$NUM_THREADS_PER_PROCESS -bind-to core build/mallob -t=$NUM_THREADS_PER_PROCESS -v=4 $@ >> $outfile 2>&1 &
sleep 1
echo "Mallob started; printing output to $outfile"

