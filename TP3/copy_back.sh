#!/bin/bash

# script to quickly copy my nginx working files to somewhere else (a.k.a extract them to the host)

# Default output directory
output=""
include_logs=0

# Parse command-line arguments
while getopts ":o:l" opt; do
    case ${opt} in
        o )
            output=$OPTARG
            ;;
	l )
	    include_logs=1
	    ;;
        \? )
	    echo "script to quickly copy my nginx working files to somewhere else (a.k.a extract them to the host)"
            echo "Usage: $0 -o output_directory"
            exit 1
            ;;
    esac
done
shift $((OPTIND -1))

# Check if output directory is set
if [[ -z "$output" ]]; then
    echo "Output directory is required."
    exit 1
fi

# remove '/' from output directory argument
output="${output%/}"

cp /etc/nginx/nginx.conf $output/nginx.conf
cp -r /usr/html $output/
if [[ $include_logs -eq 1 ]]; then
	if [ ! -d "$output/log" ]; then
		mkdir $output/log
	fi
	cp /var/log/nginx/* $output/log/
fi
